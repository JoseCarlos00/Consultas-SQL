"""
generate_catalog.py

Recorre el repositorio de consultas SQL, empareja cada archivo .sql con su
.yml de metadata (mismo nombre base), extrae los @headers del propio SQL,
calcula la fecha de última modificación vía git, valida los campos
obligatorios y escribe un catalog.json listo para consumir desde la web.

Uso:
    py generate_catalog.py                # genera web/catalog.json
    py generate_catalog.py --check         # solo valida, no escribe nada
    py generate_catalog.py --include-private  # incluye publicar: false

Requiere: PyYAML  (pip install pyyaml --break-system-packages)
"""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from dataclasses import dataclass, field
from pathlib import Path

import yaml

# --------------------------------------------------------------------------
# Configuración
# --------------------------------------------------------------------------

REPO_ROOT = Path(__file__).resolve().parent
CONFIG_FILE = REPO_ROOT / "catalog.config.yml"
DEFAULT_CATALOG_OUTPUT = REPO_ROOT / "web" / "catalog.json"
PENDING_YML_SUFFIX = ".PENDIENTE.yml"

# Carpetas que nunca se recorren buscando .sql
IGNORE_DIRS = {".git", "web", "node_modules", ".github"}

# Campos obligatorios en cada .yml
REQUIRED_FIELDS = ["id", "nombre", "descripcion", "database", "tablas"]

# Valores permitidos para "estatus"
VALID_ESTATUS = {"estable", "experimental", "en_proceso", "con_errores", "obsoleta"}

HEADERS_PATTERN = re.compile(r"--\s*@headers:\s*(.+)", re.IGNORECASE)


# --------------------------------------------------------------------------
# Modelos
# --------------------------------------------------------------------------

@dataclass
class ValidationError:
    archivo: str
    mensaje: str


@dataclass
class CatalogBuilder:
    entries: list = field(default_factory=list)
    errors: list = field(default_factory=list)

    def add_error(self, archivo: Path, mensaje: str) -> None:
        self.errors.append(ValidationError(str(archivo.relative_to(REPO_ROOT)), mensaje))


# --------------------------------------------------------------------------
# Utilidades
# --------------------------------------------------------------------------

def load_config() -> dict:
    if not CONFIG_FILE.exists():
        print(
            f"⚠️  No se encontró {CONFIG_FILE.name}. Usando valores por defecto "
            f"(los enlaces a GitHub no funcionarán). Crea catalog.config.yml con "
            f"'repo' y 'branch'.",
            file=sys.stderr,
        )
        return {"repo": "usuario/repo", "branch": "main"}
    with open(CONFIG_FILE, "r", encoding="utf-8") as f:
        return yaml.safe_load(f) or {}


def find_sql_files(root: Path) -> list[Path]:
    sql_files = []
    for path in root.rglob("*.sql"):
        if any(part in IGNORE_DIRS for part in path.relative_to(root).parts):
            continue
        sql_files.append(path)
    return sorted(sql_files)


def extract_headers(sql_text: str) -> list[str]:
    """Busca la línea '-- @headers: col1, col2, ...' y devuelve la lista de columnas."""
    match = HEADERS_PATTERN.search(sql_text)
    if not match:
        return []
    raw = match.group(1).strip()
    return [col.strip() for col in raw.split(",") if col.strip()]


def get_last_modified_date(path: Path) -> str | None:
    """Fecha (YYYY-MM-DD) del último commit que tocó el archivo. None si no hay git."""
    try:
        result = subprocess.run(
            ["git", "log", "-1", "--format=%ad", "--date=short", "--", str(path)],
            cwd=REPO_ROOT,
            capture_output=True,
            text=True,
            timeout=5,
        )
        date = result.stdout.strip()
        return date or None
    except (subprocess.SubprocessError, FileNotFoundError):
        return None


def guess_category(sql_path: Path) -> str:
    """Categoría = primera carpeta relativa a la raíz del repo."""
    rel_parts = sql_path.relative_to(REPO_ROOT).parts
    return rel_parts[0] if len(rel_parts) > 1 else "general"


def validate_metadata(meta: dict, sql_path: Path, builder: CatalogBuilder) -> bool:
    ok = True
    
    for field_name in REQUIRED_FIELDS:
        value = meta.get(field_name)
        if value in (None, "", []):
            builder.add_error(sql_path, f"falta el campo obligatorio '{field_name}'")
            ok = False

    estatus = meta.get("estatus", "estable")
    if estatus not in VALID_ESTATUS:
        builder.add_error(
            sql_path,
            f"'estatus: {estatus}' no es válido. Usa uno de: {', '.join(sorted(VALID_ESTATUS))}",
        )
        ok = False

    return ok

def get_pending_yml_path(sql_path: Path) -> Path:
    """Ruta del .yml temporal para un .sql dado."""
    return sql_path.with_name(f"{sql_path.stem}{PENDING_YML_SUFFIX}")


def get_sql_path_from_pending_yml(yml_path: Path) -> Path:
    """Inverso de get_pending_yml_path: del .PENDIENTE.yml al .sql que documenta."""
    sql_name = yml_path.name[: -len(PENDING_YML_SUFFIX)] + ".sql"
    return yml_path.with_name(sql_name)


def create_pending_metadata_file(sql_path: Path) -> Path:
    """Crea un YAML temporal indicando que requiere completar metadata."""
    yml_path = get_pending_yml_path(sql_path)

    metadata_template = f"""id: {sql_path.stem}
nombre: 
descripcion:
proposito:
database: sql-server
tablas: []
parametros: []
tags: []
alias: []
ultima_verificacion:
estatus: estable
publicar: false
notas: ""
"""
    yml_path.write_text(metadata_template, encoding="utf-8")
    return yml_path

# --------------------------------------------------------------------------
# Construcción del catálogo
# --------------------------------------------------------------------------

def build_catalog(include_private: bool) -> CatalogBuilder:
    builder = CatalogBuilder()
    sql_files = find_sql_files(REPO_ROOT)

    for sql_path in sql_files:
        yml_path = sql_path.with_suffix(".yml")
        pending_path = get_pending_yml_path(sql_path)

        if not yml_path.exists():
            if pending_path.exists():
                continue
            create_pending_metadata_file(sql_path)
            builder.add_error(
                sql_path,
                f"metadata faltante. Se creó '{pending_path.name}'",
            )
            continue

        try:
            with open(yml_path, "r", encoding="utf-8") as f:
                meta = yaml.safe_load(f) or {}
        except yaml.YAMLError as e:
            builder.add_error(yml_path, f"YAML inválido: {e}")
            continue

        publicar = meta.get("publicar", False)
        will_include = publicar or include_private

        # Solo exigimos los campos obligatorios si la consulta va a
        # terminar en el catálogo. Una consulta con publicar: false que
        # nunca se incluye no necesita estar completa.
        if not will_include:
            continue

        if not validate_metadata(meta, sql_path, builder):
            continue

        sql_text = sql_path.read_text(encoding="utf-8")
        headers = extract_headers(sql_text)
        ultima_modificacion = get_last_modified_date(sql_path)

        entry = {
            "id": meta["id"],
            "nombre": meta["nombre"],
            "descripcion": meta["descripcion"],
            "proposito": meta.get("proposito", ""),
            "database": meta["database"],
            "tablas": meta["tablas"],
            "parametros": meta.get("parametros", []),
            "tags": meta.get("tags", []),
            "alias": meta.get("alias", []),
            "headers": headers,
            "estatus": meta.get("estatus", "estable"),
            "publicar": publicar,
            "ultima_verificacion": str(meta["ultima_verificacion"]) if meta.get("ultima_verificacion") else None,
            "ultima_modificacion": ultima_modificacion,
            "notas": meta.get("notas", ""),
            "categoria": meta.get("categoria", guess_category(sql_path)),
            "ruta": str(sql_path.relative_to(REPO_ROOT)).replace("\\", "/"),
        }
        builder.entries.append(entry)

    # Chequeo extra: .yml huérfanos (sin .sql correspondiente)
    for yml_path in REPO_ROOT.rglob("*.yml"):
        if yml_path == CONFIG_FILE:
            continue

        if any(part in IGNORE_DIRS for part in yml_path.relative_to(REPO_ROOT).parts):
            continue

        # Metadata temporal pendiente de completar.
        if yml_path.name.endswith(PENDING_YML_SUFFIX):
            sql_path = get_sql_path_from_pending_yml(yml_path)
        
            if not sql_path.exists():
                builder.add_error(yml_path, "archivo .yml sin .sql correspondiente (huérfano)")
            else:
                builder.add_error(yml_path, "metadata pendiente de completar")
            continue
            
            
                        
        if not yml_path.with_suffix(".sql").exists():
            builder.add_error(
                yml_path,
                "archivo .yml sin .sql correspondiente (huérfano)"
            )

    return builder


# --------------------------------------------------------------------------
# Main
# --------------------------------------------------------------------------

def main() -> int:
    parser = argparse.ArgumentParser(description="Genera el catálogo de la biblioteca de consultas SQL.")
    parser.add_argument("--check", action="store_true", help="Solo valida, no escribe catalog.json. Útil en CI.")
    parser.add_argument("--include-private", action="store_true", help="Incluye consultas con publicar: false.")
    parser.add_argument("--output", type=Path, default=DEFAULT_CATALOG_OUTPUT, help="Ruta de salida del catalog.json.")
    args = parser.parse_args()

    config = load_config()
    builder = build_catalog(include_private=args.include_private)

    if builder.errors:
        print(f"\n❌ {len(builder.errors)} problema(s) encontrado(s):\n", file=sys.stderr)
        for err in builder.errors:
            print(f"  - {err.archivo}: {err.mensaje}", file=sys.stderr)
        print("", file=sys.stderr)

    print(f"✓ {len(builder.entries)} consulta(s) válida(s) procesada(s).")

    if args.check:
        return 1 if builder.errors else 0

    output = {
        "generado": True,
        "repo": config.get("repo", "usuario/repo"),
        "branch": config.get("branch", "main"),
        "total": len(builder.entries),
        "consultas": builder.entries,
    }

    args.output.parent.mkdir(parents=True, exist_ok=True)
    with open(args.output, "w", encoding="utf-8") as f:
        json.dump(output, f, ensure_ascii=False, indent=2)

    print(f"✓ Catálogo escrito en: {args.output.relative_to(REPO_ROOT)}")

    # Los errores de validación (yml faltante, huérfanos) no detienen la
    # generación normal, pero sí queremos que sean visibles en CI si se corre
    # sin --check por error.
    return 1 if builder.errors else 0


if __name__ == "__main__":
    sys.exit(main())

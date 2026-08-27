from __future__ import annotations

from datetime import datetime
from pathlib import Path

import yaml

from generate_catalog import (
    REPO_ROOT,
    CONFIG_FILE,
    IGNORE_DIRS,
    PENDING_YML_SUFFIX,
    find_sql_files,
)


def find_yml_files(root: Path) -> list[Path]:
    """Todos los .yml 'reales' del repo (excluye config, .PENDIENTE.yml y carpetas ignoradas)."""
    yml_files = []
    for path in root.rglob("*.yml"):
        if path == CONFIG_FILE:
            continue
        if path.name.endswith(PENDING_YML_SUFFIX):
            continue
        if any(part in IGNORE_DIRS for part in path.relative_to(root).parts):
            continue
        yml_files.append(path)
    return sorted(yml_files)


def classify_date(value) -> str:
    """Clasifica un valor de 'ultima_verificacion' en 'vacio', 'formato_invalido' o 'valido'."""
    if value in (None, ""):
        return "vacio"
    try:
        datetime.strptime(str(value), "%Y-%m-%d")
        return "valido"
    except ValueError:
        return "formato_invalido"


def main() -> None:
    sql_files = find_sql_files(REPO_ROOT)
    yml_files = find_yml_files(REPO_ROOT)

    publicar_true = 0
    publicar_false = 0
    verificacion_vacia: list[Path] = []
    verificacion_formato_invalido: list[tuple[Path, str]] = []
    yml_invalidos: list[tuple[Path, str]] = []

    for yml_path in yml_files:
        try:
            with open(yml_path, "r", encoding="utf-8") as f:
                meta = yaml.safe_load(f) or {}
        except yaml.YAMLError as e:
            yml_invalidos.append((yml_path, str(e)))
            continue

        publicar = meta.get("publicar", False)
        if publicar:
            publicar_true += 1
        else:
            publicar_false += 1

        # Solo nos importa 'ultima_verificacion' en las que se publican.
        if not publicar:
            continue

        valor = meta.get("ultima_verificacion")
        estado = classify_date(valor)
        rel_path = yml_path.relative_to(REPO_ROOT)

        if estado == "vacio":
            verificacion_vacia.append(rel_path)
        elif estado == "formato_invalido":
            verificacion_formato_invalido.append((rel_path, str(valor)))

    print(f"Archivos .sql encontrados:          {len(sql_files)}")
    print(f"Archivos .yml (total):               {len(yml_files)}")
    print(f"  con publicar: true  ->             {publicar_true}")
    print(f"  con publicar: false ->             {publicar_false}")

    if yml_invalidos:
        print(f"\n⚠️  {len(yml_invalidos)} archivo(s) .yml con YAML inválido (no se pudieron leer):")
        for path, err in yml_invalidos:
            print(f"  - {path.relative_to(REPO_ROOT)}: {err}")

    total_problemas = len(verificacion_vacia) + len(verificacion_formato_invalido)
    print(
        f"\n.yml con publicar: true y 'ultima_verificacion' con problema: "
        f"{total_problemas}"
    )

    print(f"\n  Vacía / nula ({len(verificacion_vacia)}):")
    for path in verificacion_vacia:
        print(f"    - {path}")

    print(f"\n  Formato inválido, no es YYYY-MM-DD ({len(verificacion_formato_invalido)}):")
    for path, valor in verificacion_formato_invalido:
        print(f"    - {path}  (valor: {valor!r})")


if __name__ == "__main__":
    main()

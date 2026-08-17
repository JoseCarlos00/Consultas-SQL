import { state } from './state.js';

export async function loadCatalog() {
  const res = await fetch('catalog.json', { cache: 'no-store' });
  if (!res.ok) throw new Error('No se pudo cargar catalog.json');

  state.catalog = await res.json();
  state.all = state.catalog.consultas || [];
  state.repo = state.catalog.repo || state.repo;
  state.branch = state.catalog.branch || state.branch;

  state.fuse = new Fuse(state.all, {
    includeScore: false,
    threshold: 0.35,
    ignoreLocation: true,
    keys: [
      { name: 'nombre', weight: 0.35 },
      { name: 'descripcion', weight: 0.2 },
      { name: 'tags', weight: 0.2 },
      { name: 'alias', weight: 0.15 },
      { name: 'tablas', weight: 0.1 },
    ],
  });
}

export function getFiltered(favorites) {
  let base = state.query.trim()
    ? state.fuse.search(state.query.trim()).map((r) => r.item)
    : state.all;

  if (state.showFavoritesOnly) {
    base = base.filter((q) => favorites.has(q.id));
  }
  if (state.activeCategory) {
    base = base.filter((q) => q.categoria === state.activeCategory);
  }
  if (state.activeTag) {
    base = base.filter((q) => (q.tags || []).includes(state.activeTag));
  }
  return base;
}

// Estado compartido, mutado por los distintos módulos e importado donde se
// necesite leerlo. Es deliberadamente un objeto simple (no una clase) porque
// no hay lógica de negocio aquí, solo datos que varios módulos leen/escriben.
export const state = {
  catalog: null,
  repo: 'usuario/repo',
  branch: 'main',
  all: [],
  fuse: null,

  activeCategory: null,
  activeTag: null,
  showFavoritesOnly: false,
  query: '',
};

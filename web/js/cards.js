import { state } from './state.js';
import { escapeHtml, isStale } from './utils.js';
import { getFiltered } from './catalog.js';

const ESTATUS_LABEL = {
  estable: 'Estable',
  experimental: 'Experimental',
  en_proceso: 'En proceso',
  con_errores: 'Con errores',
  obsoleta: 'Obsoleta',
};

export function renderCards(els, favorites, { onOpenDetail, onToggleFavorite }) {
  const results = getFiltered(favorites);
  els.resultCount.textContent = `${results.length} de ${state.all.length}`;

  if (results.length === 0) {
    els.cardGrid.innerHTML = `<div class="empty-state">${
      state.showFavoritesOnly
        ? 'Aún no marcaste ninguna consulta como favorita.'
        : 'Sin resultados. Prueba con otra palabra, etiqueta o categoría.'
    }</div>`;
    return;
  }

  els.cardGrid.innerHTML = results.map((q) => cardTemplate(q, favorites.has(q.id))).join('');

  els.cardGrid.querySelectorAll('.query-card').forEach((el) => {
    el.addEventListener('click', () => onOpenDetail(el.dataset.id));
    el.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); onOpenDetail(el.dataset.id); }
    });
  });

  els.cardGrid.querySelectorAll('.star-btn').forEach((btn) => {
    btn.addEventListener('click', (e) => {
      e.stopPropagation(); // no abrir el detalle al marcar favorito
      onToggleFavorite(btn.dataset.id);
    });
  });
}

function cardTemplate(q, favorited) {
  const stale = isStale(q);
  return `
    <article class="query-card" data-id="${escapeHtml(q.id)}" tabindex="0" role="button" aria-label="Ver detalle de ${escapeHtml(q.nombre)}">
      <button class="star-btn ${favorited ? 'active' : ''}" data-id="${escapeHtml(q.id)}" aria-label="${favorited ? 'Quitar de favoritos' : 'Agregar a favoritos'}" aria-pressed="${favorited}">${favorited ? '★' : '☆'}</button>
      <p class="card-tab">${escapeHtml(q.categoria)}</p>
      <h3 class="card-title">${escapeHtml(q.nombre)}</h3>
      <p class="card-desc">${escapeHtml(q.descripcion)}</p>
      <div class="card-meta-row">
        <span class="badge badge-db">${escapeHtml(q.database)}</span>
        <span class="badge status-${escapeHtml(q.estatus)}">${escapeHtml(ESTATUS_LABEL[q.estatus] || q.estatus)}</span>
      </div>
      <div class="card-footer">
        <span class="card-tags">${(q.tags || []).slice(0, 3).join(' · ')}</span>
        <span class="card-verified">${q.ultima_verificacion ? 'ver. ' + q.ultima_verificacion : 'sin verificar'}${stale ? ' <span class="stale-flag">⚠</span>' : ''}</span>
      </div>
    </article>
  `;
}

export { ESTATUS_LABEL };

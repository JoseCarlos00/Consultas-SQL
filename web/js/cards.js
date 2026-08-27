import { state } from './state.js';
import { escapeHtml, isStale } from './utils.js';
import { getFiltered } from './catalog.js';
import { copyHeaders, copySQL } from './hooks/sql.js';
import { createActionButton } from './components/buttons.js';

const ESTATUS_LABEL = {
	estable: 'Estable',
	experimental: 'Experimental',
	en_proceso: 'En proceso',
	con_errores: 'Con errores',
	obsoleta: 'Obsoleta',
};

export function renderCards(els, favorites, { showToast, onOpenDetail, onToggleFavorite }) {
	const results = getFiltered(favorites);
	els.resultCount.textContent = `${results.length} de ${state.all.length}`;

	if (results.length === 0) {
		els.cardGrid.innerHTML = /*html*/ `<div class="empty-state">${
			state.showFavoritesOnly
				? 'Aún no marcaste ninguna consulta como favorita.'
				: 'Sin resultados. Prueba con otra palabra, etiqueta o categoría.'
		}</div>`;
		return;
	}

	const cards = results.map((q) =>
		createCard(q, favorites.has(q.id), {
			showToast,
			onOpenDetail,
			onToggleFavorite,
		}),
	);

	els.cardGrid.replaceChildren(...cards);
}

function createCard(q, favorited, { showToast, onOpenDetail, onToggleFavorite }) {
	const stale = isStale(q);

	const card = document.createElement('article');

	card.classList.add('query-card');
	card.dataset.id = q.id;
	card.tabIndex = 0;
	card.setAttribute('role', 'button');
	card.setAttribute('aria-label', `Ver detalle de ${q.nombre}`);

	card.innerHTML = `
        <button
            class="star-btn ${favorited ? 'active' : ''}"
            data-id="${escapeHtml(q.id)}"
            aria-label="${favorited ? 'Quitar de favoritos' : 'Agregar a favoritos'}"
            aria-pressed="${favorited}"
        >
            ${favorited ? '★' : '☆'}
        </button>

        <p class="card-tab">${escapeHtml(q.categoria)}</p>

        <h3 class="card-title">${escapeHtml(q.nombre)}</h3>

        <p class="card-desc">${escapeHtml(q.descripcion)}</p>

        <div class="card-meta-row"></div>

        <div class="card-footer">
            <span class="card-tags">
                ${(q.tags || []).slice(0, 3).map(escapeHtml).join(' · ')}
            </span>

            <span class="card-verified">
                ${q.ultima_verificacion ? 'ver. ' + q.ultima_verificacion : 'sin verificar'}
                ${stale ? ' <span class="stale-flag">⚠</span>' : ''}
            </span>
        </div>
    `;

	const metaRow = card.querySelector('.card-meta-row');

	const btnCopySql = createActionButton('Copiar SQL', async (e) => {
    e.stopPropagation();
		const success = await copySQL(q);

		showToast(success ? 'SQL copiado' : 'No se pudo obtener el SQL');
	});

	const btnCopyHeader = createActionButton(
		'Copiar headers',
		(e) => {
      e.stopPropagation();
      
			const success = copyHeaders(q);

			if (success) {
				showToast('Headers copiados');
			}
		},
		{
			disabled: !q.headers?.length,
			title: 'Esta consulta no tiene @headers',
		},
	);

	metaRow.append(btnCopySql, btnCopyHeader);

	card.addEventListener('click', () => {
		onOpenDetail(q.id);
	});

	card.addEventListener('keydown', (e) => {
		if (e.key === 'Enter' || e.key === ' ') {
			e.preventDefault();
			onOpenDetail(q.id);
		}
	});

	card.querySelector('.star-btn').addEventListener('click', (e) => {
		e.stopPropagation();
		onToggleFavorite(q.id);
	});

	return card;
}

export { ESTATUS_LABEL };

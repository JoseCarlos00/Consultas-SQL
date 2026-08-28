import { state } from './state.js';
import { escapeHtml, isStale } from './utils.js';
import { getFiltered } from './catalog.js';
import { copyHeaders, copySQL, createUrl } from './hooks/sql.js';
import { createActionButton } from './components/buttons.js';
import { openSqlModal } from './sqlModal.js';

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
	const { githubUrl } = createUrl(q);

	const card = document.createElement('article');

	card.classList.add('query-card');
	card.dataset.id = q.id;
	card.tabIndex = 0;
	card.setAttribute('role', 'button');
	card.setAttribute('aria-label', `Ver detalle de ${q.nombre}`);

	card.innerHTML = /*html*/ `
        <button
            class="star-btn ${favorited ? 'active' : ''}"
            data-id="${escapeHtml(q.id)}"
            aria-label="${favorited ? 'Quitar de favoritos' : 'Agregar a favoritos'}"
            aria-pressed="${favorited}"
        >
            ${favorited ? '★' : '☆'}
        </button>

        <p class="card-tab">${escapeHtml(q.categoria)}</p>

        <h3 class="card-title">
					${escapeHtml(q.nombre)}

					<a href="${githubUrl}" target="_blank" rel="noopener">
						<span>
							${arrowSquare}
						</span>
					</a>
				</h3>

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

	const btnViewSql = createActionButton('Ver SQL', (e) => {
		e.stopPropagation();
		openSqlModal(q);
	});

	metaRow.append(btnCopySql, btnCopyHeader, btnViewSql);

	// const panelActionButtons = 

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

	card.querySelector('.card-title a').addEventListener('click', (e) => {
		e.stopPropagation();
	});

	const titleLink = card.querySelector('.card-title a');

	titleLink.addEventListener('click', (e) => {
		e.stopPropagation();
	});

	titleLink.addEventListener('keydown', (e) => {
		e.stopPropagation();
	});

	return card;
}

const arrowSquare = /*html*/ `
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
	<path fill="currentColor" d="M320 0c-17.7 0-32 14.3-32 32s14.3 32 32 32l82.7 0-201.4 201.4c-12.5 12.5-12.5 32.8 0 45.3s32.8 12.5 45.3 0L448 109.3 448 192c0 17.7 14.3 32 32 32s32-14.3 32-32l0-160c0-17.7-14.3-32-32-32L320 0zM80 96C35.8 96 0 131.8 0 176L0 432c0 44.2 35.8 80 80 80l256 0c44.2 0 80-35.8 80-80l0-80c0-17.7-14.3-32-32-32s-32 14.3-32 32l0 80c0 8.8-7.2 16-16 16L80 448c-8.8 0-16-7.2-16-16l0-256c0-8.8 7.2-16 16-16l80 0c17.7 0 32-14.3 32-32s-14.3-32-32-32L80 96z"/>
</svg>
`;


export { ESTATUS_LABEL };

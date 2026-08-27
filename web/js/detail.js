import { state } from './state.js';
import { escapeHtml, isStale } from './utils.js';
import { ESTATUS_LABEL } from './cards.js';
import { createActionButton } from './components/buttons.js';
import { copyHeaders, copySQL, createUrl, fetchSql } from './hooks/sql.js';

export async function viewSQL(q) {
	const { rawUrl, githubUrl } = createUrl(q);

	const preview = document.getElementById('sql-preview');
	preview.classList.toggle('open');

	if (preview.classList.contains('open') && !preview.dataset.loaded) {
		const text = await fetchSql(rawUrl);
		preview.innerHTML =
			text !== null
				? `<pre>${escapeHtml(text)}</pre>`
				: `<p class="sql-error">No se pudo obtener el SQL desde GitHub. Ábrelo directamente: <a href="${githubUrl}" target="_blank" rel="noopener">${githubUrl}</a></p>`;
		preview.dataset.loaded = '1';
	}
}

export function openDetail(els, id, { showToast, isFavorite, onToggleFavorite }) {
	const q = state.all.find((item) => item.id === id);
	if (!q) return;

	const { githubUrl } = createUrl(q);
	const stale = isStale(q);
	const favorited = isFavorite(q.id);

	const btnViewSql = createActionButton('Ver SQL', () => viewSQL(q), { primary: true });

	const btnCopySql = createActionButton('Copiar SQL', async () => {
		const success = await copySQL(q);

		showToast(success ? 'SQL copiado' : 'No se pudo obtener el SQL');
	});

	const btnCopyHeader = createActionButton(
		'Copiar headers',
		() => {
			const success = copyHeaders(q);

			if (success) showToast('Headers copiados');
		},
		{
			disabled: !q.headers?.length,
			title: 'Esta consulta no tiene @headers',
		},
	);

	els.detailPanel.innerHTML = /*html*/ `
    <button class="detail-close" id="detail-close" aria-label="Cerrar">✕</button>
    <button class="star-btn detail-star ${favorited ? 'active' : ''}" id="detail-star" aria-label="${favorited ? 'Quitar de favoritos' : 'Agregar a favoritos'}" aria-pressed="${favorited}">${favorited ? '★' : '☆'}</button>
    <p class="detail-tab">${escapeHtml(q.categoria)} / ${escapeHtml(q.id)}</p>


    <h2 class="detail-title">${escapeHtml(q.nombre)}</h2>
    
    <p class="detail-desc">${escapeHtml(q.descripcion)}</p>

    <div class="detail-section">
      <p class="detail-section-label">Proposito</p>
      <div class="detail-badges">
        ${q.proposito ? `<p style="font-size:13px; color:var(--ink-soft);  margin: 0 0 0.6rem; font-style: italic;">${escapeHtml(q.proposito)}</p>` : ''}
      </div>
    </div>


    <div class="detail-section">
      <p class="detail-section-label">Estado</p>
      <div class="detail-badges">
        <span class="badge badge-db">${escapeHtml(q.database)}</span>
        <span class="badge status-${escapeHtml(q.estatus)}">${escapeHtml(ESTATUS_LABEL[q.estatus] || q.estatus)}</span>
        <span class="badge badge-db">verificada: ${q.ultima_verificacion || 's/f'}</span>
        <span class="badge badge-db ${stale ? 'stale-flag' : ''}">modificada: ${q.ultima_modificacion || 's/f'}${stale ? ' ⚠' : ''}</span>
      </div>
    </div>

    <div class="detail-section">
      <p class="detail-section-label">Tablas</p>
      <div class="detail-badges">${(q.tablas || []).map((t) => `<span class="badge badge-db">${escapeHtml(t)}</span>`).join('')}</div>
    </div>

    ${
			q.tags && q.tags.length
				? /*html*/ `
    <div class="detail-section">
      <p class="detail-section-label">Etiquetas</p>
      <div class="detail-badges">${q.tags.map((t) => `<span class="tag-chip" style="cursor:default">${escapeHtml(t)}</span>`).join('')}</div>
    </div>`
				: ''
		}

    ${
			q.alias && q.alias.length
				? /*html*/ `
    <div class="detail-section">
      <p class="detail-section-label">También conocida como</p>
      <p style="font-size:13px;color:var(--ink-soft);margin:0;">${q.alias.map(escapeHtml).join(' · ')}</p>
    </div>`
				: ''
		}

    ${
			q.parametros && q.parametros.length
				? /*html*/ `
    <div class="detail-section">
      <p class="detail-section-label">Parámetros a editar antes de ejecutar</p>
      <ul class="param-list">
        ${q.parametros
					.map(
						(p) => /*html*/ `
          <li>
            <div>${escapeHtml(p.descripcion || '')}</div>
            ${p.ejemplo !== undefined ? `<div style="color:var(--ink-faint);font-size:12px;margin-top:2px;">ejemplo: <span class="param-loc">${escapeHtml(String(p.ejemplo))}</span></div>` : ''}
            ${p.ubicacion ? `<div style="color:var(--ink-faint);font-size:12px;margin-top:2px;">ubicación: <span class="param-loc">${escapeHtml(p.ubicacion)}</span></div>` : ''}
          </li>`,
					)
					.join('')}
      </ul>
    </div>`
				: ''
		}

    ${
			q.notas
				? /*html*/ `
    <div class="detail-section">
      <p class="detail-section-label">Notas</p>
      <p class="detail-notes">${escapeHtml(q.notas)}</p>
    </div>`
				: ''
		}

    <div class="detail-actions action-buttons">
    </div>

    <div class="sql-preview" id="sql-preview">
      <p class="sql-loading">Cargando SQL…</p>
    </div>
  `;

	els.overlay.classList.add('open');
	document.getElementById('detail-close').addEventListener('click', () => closeDetail(els));

	document.getElementById('detail-star').addEventListener('click', () => {
		onToggleFavorite(q.id);
		openDetail(els, id, { showToast, isFavorite, onToggleFavorite }); // re-render con el nuevo estado
	});

	const panelButtons = els.detailPanel.querySelector('.detail-actions.action-buttons');

	if (panelButtons) {
		panelButtons.append(btnViewSql, btnCopySql, btnCopyHeader);
		panelButtons.insertAdjacentHTML(
			'beforeend',
			`<a class="action-btn" href="${githubUrl}" target="_blank" rel="noopener">Abrir en GitHub</a>`,
		);
	}
}

export function closeDetail(els) {
	els.overlay.classList.remove('open');
}

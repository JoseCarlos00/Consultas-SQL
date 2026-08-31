import { escapeHtml } from './utils.js';
import { copyHeaders, copySQL, createUrl, fetchSql } from './hooks/sql.js';
import { createActionButton } from './components/buttons.js';


const overlay = document.getElementById('sql-overlay');
const title = document.getElementById('sql-modal-title');
const preview = document.getElementById('sql-modal-preview');
const closeBtn = document.getElementById('sql-modal-close');
const actions = document.getElementById('sql-overlay-modal-actions'); // ver nota abajo sobre el HTML

closeBtn.addEventListener('click', closeSqlModal);

overlay.addEventListener('click', (e) => {
	if (e.target === overlay) closeSqlModal();
});
document.addEventListener('keydown', (e) => {
	if (e.key === 'Escape') closeSqlModal();
});

export function closeSqlModal() {
	overlay.classList.remove('open');
}


export async function openSqlModal(q, showToast) {
	const { rawUrl, githubUrl } = createUrl(q);

	title.textContent = `${q.categoria} / ${q.nombre}`;
	preview.innerHTML = '<p class="sql-loading">Cargando SQL…</p>';
	overlay.classList.add('open');

	renderActionButtons(q, showToast);

	const text = await fetchSql(rawUrl);

	preview.innerHTML =
		text !== null
			? `<pre>${escapeHtml(text)}</pre>`
			: `<p class="sql-error">No se pudo obtener el SQL desde GitHub. Ábrelo directamente: <a href="${githubUrl}" target="_blank" rel="noopener">${githubUrl}</a></p>`;
}

function renderActionButtons(q, showToast) {
	actions.replaceChildren();

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
      showToast(success ? 'Headers copiados' : 'Error al obtener Headers');
		},
		{
			disabled: !q.headers?.length,
			title: 'Esta consulta no tiene @headers',
		},
	);

	actions.append(btnCopySql, btnCopyHeader);
}

import { escapeHtml } from './utils.js';
import { createUrl, fetchSql } from './hooks/sql.js';

const overlay = document.getElementById('sql-overlay');
const panel = document.getElementById('sql-modal-panel');
const title = document.getElementById('sql-modal-title');
const preview = document.getElementById('sql-modal-preview');
const closeBtn = document.getElementById('sql-modal-close');

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

export async function openSqlModal(q) {
  const { rawUrl, githubUrl } = createUrl(q);

  title.textContent = `${q.categoria} / ${q.nombre}`;
  preview.innerHTML = '<p class="sql-loading">Cargando SQL…</p>';
  overlay.classList.add('open');

  const text = await fetchSql(rawUrl);

  preview.innerHTML =
    text !== null
      ? `<pre>${escapeHtml(text)}</pre>`
      : `<p class="sql-error">No se pudo obtener el SQL desde GitHub. Ábrelo directamente: <a href="${githubUrl}" target="_blank" rel="noopener">${githubUrl}</a></p>`;
}

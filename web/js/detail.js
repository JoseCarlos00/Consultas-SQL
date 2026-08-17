import { state } from './state.js';
import { escapeHtml, isStale } from './utils.js';
import { ESTATUS_LABEL } from './cards.js';

export function openDetail(els, id, { showToast, isFavorite, onToggleFavorite }) {
  const q = state.all.find((item) => item.id === id);
  if (!q) return;

  const rawUrl = `https://raw.githubusercontent.com/${state.repo}/${state.branch}/${q.ruta}`;
  const githubUrl = `https://github.com/${state.repo}/blob/${state.branch}/${q.ruta}`;
  const stale = isStale(q);
  const favorited = isFavorite(q.id);

  els.detailPanel.innerHTML = `
    <button class="detail-close" id="detail-close" aria-label="Cerrar">✕</button>
    <button class="star-btn detail-star ${favorited ? 'active' : ''}" id="detail-star" aria-label="${favorited ? 'Quitar de favoritos' : 'Agregar a favoritos'}" aria-pressed="${favorited}">${favorited ? '★' : '☆'}</button>
    <p class="detail-tab">${escapeHtml(q.categoria)} / ${escapeHtml(q.id)}</p>
    <h2 class="detail-title">${escapeHtml(q.nombre)}</h2>
    <p class="detail-desc">${escapeHtml(q.descripcion)}</p>
    ${q.proposito ? `<p class="detail-purpose">${escapeHtml(q.proposito)}</p>` : ''}

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

    ${(q.tags && q.tags.length) ? `
    <div class="detail-section">
      <p class="detail-section-label">Etiquetas</p>
      <div class="detail-badges">${q.tags.map((t) => `<span class="tag-chip" style="cursor:default">${escapeHtml(t)}</span>`).join('')}</div>
    </div>` : ''}

    ${(q.alias && q.alias.length) ? `
    <div class="detail-section">
      <p class="detail-section-label">También conocida como</p>
      <p style="font-size:13px;color:var(--ink-soft);margin:0;">${q.alias.map(escapeHtml).join(' · ')}</p>
    </div>` : ''}

    ${(q.parametros && q.parametros.length) ? `
    <div class="detail-section">
      <p class="detail-section-label">Parámetros a editar antes de ejecutar</p>
      <ul class="param-list">
        ${q.parametros.map((p) => `
          <li>
            <div>${escapeHtml(p.descripcion || '')}</div>
            ${p.ejemplo !== undefined ? `<div style="color:var(--ink-faint);font-size:12px;margin-top:2px;">ejemplo: <span class="param-loc">${escapeHtml(String(p.ejemplo))}</span></div>` : ''}
            ${p.ubicacion ? `<div style="color:var(--ink-faint);font-size:12px;margin-top:2px;">ubicación: <span class="param-loc">${escapeHtml(p.ubicacion)}</span></div>` : ''}
          </li>`).join('')}
      </ul>
    </div>` : ''}

    ${q.notas ? `
    <div class="detail-section">
      <p class="detail-section-label">Notas</p>
      <p class="detail-notes">${escapeHtml(q.notas)}</p>
    </div>` : ''}

    <div class="detail-actions">
      <button class="action-btn primary" id="btn-view-sql"><span>Ver SQL</span></button>
      <button class="action-btn" id="btn-copy-sql">Copiar SQL</button>
      <button class="action-btn" id="btn-copy-headers" ${(!q.headers || !q.headers.length) ? 'disabled title="Esta consulta no tiene @headers"' : ''}>Copiar headers</button>
      <a class="action-btn" href="${githubUrl}" target="_blank" rel="noopener">Abrir en GitHub</a>
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

  document.getElementById('btn-view-sql').addEventListener('click', async () => {
    const preview = document.getElementById('sql-preview');
    preview.classList.toggle('open');
    if (preview.classList.contains('open') && !preview.dataset.loaded) {
      const text = await fetchSql(rawUrl);
      preview.innerHTML = text !== null
        ? `<pre>${escapeHtml(text)}</pre>`
        : `<p class="sql-error">No se pudo obtener el SQL desde GitHub. Ábrelo directamente: <a href="${githubUrl}" target="_blank" rel="noopener">${githubUrl}</a></p>`;
      preview.dataset.loaded = '1';
    }
  });

  document.getElementById('btn-copy-sql').addEventListener('click', async () => {
    const text = await fetchSql(rawUrl);
    if (text !== null) { copyToClipboard(text); showToast('SQL copiado'); }
    else { showToast('No se pudo obtener el SQL'); }
  });

  const headersBtn = document.getElementById('btn-copy-headers');
  if (headersBtn && !headersBtn.disabled) {
    headersBtn.addEventListener('click', () => {
      copyToClipboard(q.headers.join(', '));
      showToast('Headers copiados');
    });
  }
}

export function closeDetail(els) {
  els.overlay.classList.remove('open');
}

async function fetchSql(rawUrl) {
  try {
    const res = await fetch(rawUrl, { cache: 'no-store' });
    if (!res.ok) return null;
    return await res.text();
  } catch {
    return null;
  }
}

function copyToClipboard(text) {
  if (navigator.clipboard && navigator.clipboard.writeText) {
    navigator.clipboard.writeText(text);
  } else {
    const ta = document.createElement('textarea');
    ta.value = text;
    document.body.appendChild(ta);
    ta.select();
    document.execCommand('copy');
    document.body.removeChild(ta);
  }
}

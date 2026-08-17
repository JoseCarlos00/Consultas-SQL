(() => {
	'use strict';

	const state = {
		catalog: null,
		repo: 'usuario/repo',
		branch: 'main',
		all: [],
		activeCategory: null,
		activeTag: null,
		query: '',
		fuse: null,
	};

	const els = {
		searchInput: document.getElementById('search-input'),
		resultCount: document.getElementById('result-count'),
		cardGrid: document.getElementById('card-grid'),
		categoryList: document.getElementById('category-list'),
		tagList: document.getElementById('tag-list'),
		overlay: document.getElementById('detail-overlay'),
		detailPanel: document.getElementById('detail-panel'),
		toast: document.getElementById('toast'),
	};

	const ESTATUS_LABEL = {
		estable: 'Estable',
		experimental: 'Experimental',
		en_proceso: 'En proceso',
		con_errores: 'Con errores',
		obsoleta: 'Obsoleta',
	};

	// ---------------------------------------------------------------------
	// Carga inicial
	// ---------------------------------------------------------------------

	async function init() {
		try {
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

			renderCategories();
			renderTags();
			render();
		} catch (err) {
			els.cardGrid.innerHTML = `<div class="empty-state">No se pudo cargar el catálogo (${escapeHtml(err.message)}). Verifica que catalog.json exista junto a este archivo.</div>`;
		}
	}

	// ---------------------------------------------------------------------
	// Filtrado + búsqueda
	// ---------------------------------------------------------------------

	function getFiltered() {
		let base = state.query.trim() ? state.fuse.search(state.query.trim()).map((r) => r.item) : state.all;

		if (state.activeCategory) {
			base = base.filter((q) => q.categoria === state.activeCategory);
		}
		if (state.activeTag) {
			base = base.filter((q) => (q.tags || []).includes(state.activeTag));
		}
		return base;
	}

	function render() {
		const results = getFiltered();
		els.resultCount.textContent = `${results.length} de ${state.all.length}`;

		if (results.length === 0) {
			els.cardGrid.innerHTML =
				'<div class="empty-state">Sin resultados. Prueba con otra palabra, etiqueta o categoría.</div>';
			return;
		}

		els.cardGrid.innerHTML = results.map(cardTemplate).join('');
		els.cardGrid.querySelectorAll('.query-card').forEach((el) => {
			el.addEventListener('click', () => openDetail(el.dataset.id));
			el.addEventListener('keydown', (e) => {
				if (e.key === 'Enter' || e.key === ' ') {
					e.preventDefault();
					openDetail(el.dataset.id);
				}
			});
		});
	}

	function cardTemplate(q) {
		const stale = isStale(q);
		return `
      <article class="query-card" data-id="${escapeHtml(q.id)}" tabindex="0" role="button" aria-label="Ver detalle de ${escapeHtml(q.nombre)}">
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

	function isStale(q) {
		if (!q.ultima_verificacion || !q.ultima_modificacion) return false;
		return new Date(q.ultima_modificacion) > new Date(q.ultima_verificacion);
	}

	// ---------------------------------------------------------------------
	// Sidebar: categorías y tags
	// ---------------------------------------------------------------------

	function renderCategories() {
		const counts = {};
		state.all.forEach((q) => {
			counts[q.categoria] = (counts[q.categoria] || 0) + 1;
		});
		const categories = Object.keys(counts).sort();

		els.categoryList.innerHTML = [
			`<li><button class="drawer-item ${!state.activeCategory ? 'active' : ''}" data-category="">Todas<span class="count">${state.all.length}</span></button></li>`,
			...categories.map(
				(cat) => `
        <li><button class="drawer-item ${state.activeCategory === cat ? 'active' : ''}" data-category="${escapeHtml(cat)}">${escapeHtml(cat)}<span class="count">${counts[cat]}</span></button></li>
      `,
			),
		].join('');

		els.categoryList.querySelectorAll('[data-category]').forEach((btn) => {
			btn.addEventListener('click', () => {
				state.activeCategory = btn.dataset.category || null;
				renderCategories();
				render();
			});
		});
	}

	function renderTags() {
		const tagSet = new Set();
		state.all.forEach((q) => (q.tags || []).forEach((t) => tagSet.add(t)));
		const tags = [...tagSet].sort();

		els.tagList.innerHTML = tags
			.map(
				(tag) => `
      <button class="tag-chip ${state.activeTag === tag ? 'active' : ''}" data-tag="${escapeHtml(tag)}">${escapeHtml(tag)}</button>
    `,
			)
			.join('');

		els.tagList.querySelectorAll('[data-tag]').forEach((btn) => {
			btn.addEventListener('click', () => {
				state.activeTag = state.activeTag === btn.dataset.tag ? null : btn.dataset.tag;
				renderTags();
				render();
			});
		});
	}

	// ---------------------------------------------------------------------
	// Panel de detalle
	// ---------------------------------------------------------------------

	function openDetail(id) {
		const q = state.all.find((item) => item.id === id);
		if (!q) return;

		const rawUrl = `https://raw.githubusercontent.com/${state.repo}/${state.branch}/${q.ruta}`;
		const githubUrl = `https://github.com/${state.repo}/blob/${state.branch}/${q.ruta}`;
		const stale = isStale(q);

		els.detailPanel.innerHTML = `
      <button class="detail-close" id="detail-close" aria-label="Cerrar">✕</button>
      <p class="detail-tab">${escapeHtml(q.categoria)} / ${escapeHtml(q.id)}</p>
      <h2 class="detail-title">${escapeHtml(q.nombre)}</h2>
      <p class="detail-desc">${escapeHtml(q.descripcion)}</p>
      ${q.proposito ? `<p class="detail-purpose">${escapeHtml(q.proposito)}</p>` : ''}

      <div class="detail-section">
        <p class="detail-section-label">Tablas</p>
        <div class="detail-badges">${(q.tablas || []).map((t) => `<span class="badge badge-db">${escapeHtml(t)}</span>`).join('')}</div>
      </div>

      ${
				q.tags && q.tags.length
					? `
      <div class="detail-section">
        <p class="detail-section-label">Etiquetas</p>
        <div class="detail-badges">${q.tags.map((t) => `<span class="tag-chip" style="cursor:default">${escapeHtml(t)}</span>`).join('')}</div>
      </div>`
					: ''
			}

      ${
				q.alias && q.alias.length
					? `
      <div class="detail-section">
        <p class="detail-section-label">También conocida como</p>
        <p style="font-size:13px;color:var(--ink-soft);margin:0;">${q.alias.map(escapeHtml).join(' · ')}</p>
      </div>`
					: ''
			}

      ${
				q.parametros && q.parametros.length
					? `
      <div class="detail-section">
        <p class="detail-section-label">Parámetros a editar antes de ejecutar</p>
        <ul class="param-list">
          ${q.parametros
						.map(
							(p) => `
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
					? `
      <div class="detail-section">
        <p class="detail-section-label">Notas</p>
        <p class="detail-notes">${escapeHtml(q.notas)}</p>
      </div>`
					: ''
			}

      <div class="detail-actions">
        <button class="action-btn primary" id="btn-view-sql"><span>Ver SQL</span></button>
        <button class="action-btn" id="btn-copy-sql">Copiar SQL</button>
        <button class="action-btn" id="btn-copy-headers" ${!q.headers || !q.headers.length ? 'disabled title="Esta consulta no tiene @headers"' : ''}>Copiar headers</button>
        <a class="action-btn" href="${githubUrl}" target="_blank" rel="noopener">Abrir en GitHub</a>
      </div>

      <div class="sql-preview" id="sql-preview">
        <p class="sql-loading">Cargando SQL…</p>
      </div>
    `;

		els.overlay.classList.add('open');
		document.getElementById('detail-close').addEventListener('click', closeDetail);

		document.getElementById('btn-view-sql').addEventListener('click', async () => {
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
		});

		document.getElementById('btn-copy-sql').addEventListener('click', async () => {
			const text = await fetchSql(rawUrl);
			if (text !== null) {
				copyToClipboard(text);
				showToast('SQL copiado');
			} else {
				showToast('No se pudo obtener el SQL');
			}
		});

		const headersBtn = document.getElementById('btn-copy-headers');
		if (headersBtn && !headersBtn.disabled) {
			headersBtn.addEventListener('click', () => {
				copyToClipboard(q.headers.join(', '));
				showToast('Headers copiados');
			});
		}
	}

	function closeDetail() {
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

	function showToast(msg) {
		els.toast.textContent = msg;
		els.toast.classList.add('show');
		clearTimeout(showToast._t);
		showToast._t = setTimeout(() => els.toast.classList.remove('show'), 1800);
	}

	function escapeHtml(str) {
		return String(str ?? '').replace(
			/[&<>"']/g,
			(c) =>
				({
					'&': '&amp;',
					'<': '&lt;',
					'>': '&gt;',
					'"': '&quot;',
					"'": '&#39;',
				})[c],
		);
	}

	// ---------------------------------------------------------------------
	// Eventos globales
	// ---------------------------------------------------------------------

	els.searchInput.addEventListener('input', (e) => {
		state.query = e.target.value;
		render();
	});

	els.overlay.addEventListener('click', (e) => {
		if (e.target === els.overlay) closeDetail();
	});

	document.addEventListener('keydown', (e) => {
		if (e.key === 'Escape') closeDetail();
	});

	init();
})();

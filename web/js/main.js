import { state } from './state.js';
import { loadCatalog } from './catalog.js';
import { renderFavoritesToggle, renderCategories } from './sidebar.js';
import { renderCards } from './cards.js';
import { openDetail, closeDetail } from './detail.js';
import { initTheme } from './theme.js';
import { getFavorites, toggleFavorite, isFavorite } from './storage.js';
import { showToast } from './toast.js';

const els = {
	searchInput: document.getElementById('search-input'),
	resultCount: document.getElementById('result-count'),
	cardGrid: document.getElementById('card-grid'),
	favoritesToggle: document.getElementById('favorites-toggle'),
	categoryList: document.getElementById('category-list'),
	tagList: document.getElementById('tag-list'),
	overlay: document.getElementById('detail-overlay'),
	detailPanel: document.getElementById('detail-panel'),
	toast: document.getElementById('toast'),
	themeToggle: document.getElementById('theme-toggle'),
};

function renderAll() {
	const favorites = getFavorites();

	renderFavoritesToggle(els, favorites, renderAll);
	renderCategories(els, renderAll);

	renderCards(els, favorites, {
		showToast: (msg) => showToast(els.toast, msg),

		onOpenDetail: (id) =>
			openDetail(els, id, {
				showToast: (msg) => showToast(els.toast, msg),
				isFavorite,
				onToggleFavorite: handleToggleFavorite,
			}),

		onToggleFavorite: handleToggleFavorite,
	});
}

function handleToggleFavorite(id) {
	toggleFavorite(id);
	renderAll();
}

async function init() {
	initTheme(els.themeToggle);

	try {
		await loadCatalog();
		renderAll();
	} catch (err) {
		els.cardGrid.innerHTML = `<div class="empty-state">No se pudo cargar el catálogo (${err.message}). Verifica que catalog.json exista junto a este archivo.</div>`;
	}

	els.searchInput.addEventListener('input', (e) => {
		state.query = e.target.value;

		if (state.query.trim()) {
			state.activeCategory = null;
			state.showFavoritesOnly = false;
      state.activeTag = null;
		}

		renderAll();
	});

	els.overlay.addEventListener('click', (e) => {
		if (e.target === els.overlay) closeDetail(els);
	});

	document.addEventListener('keydown', (e) => {
		if (e.key === 'Escape') closeDetail(els);
	});
}

init();

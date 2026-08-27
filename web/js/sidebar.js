import { state } from './state.js';
import { escapeHtml } from './utils.js';

export function renderFavoritesToggle(els, favorites, onChange) {
  const count = state.all.filter((q) => favorites.has(q.id)).length;

  els.favoritesToggle.innerHTML = `
    <button class="drawer-item drawer-item-star ${state.showFavoritesOnly ? 'active' : ''}" id="favorites-btn">
      <span>★ Favoritos</span><span class="count">${count}</span>
    </button>
  `;

  document.getElementById('favorites-btn').addEventListener('click', () => {
    state.showFavoritesOnly = !state.showFavoritesOnly;
    state.activeCategory = null;
    onChange();
  });
}

export function renderCategories(els, onChange) {
  const counts = {};
  
  state.all.forEach((q) => { counts[q.categoria] = (counts[q.categoria] || 0) + 1; });

  const categories = Object.keys(counts).sort();

  els.categoryList.innerHTML = [
    `<li><button class="drawer-item ${!state.activeCategory ? 'active' : ''}" data-category="">Todas<span class="count">${state.all.length}</span></button></li>`,
    ...categories.map((cat) => `
      <li><button class="drawer-item ${state.activeCategory === cat ? 'active' : ''}" data-category="${escapeHtml(cat)}"> <span class="category-item">${escapeHtml(cat)}</span> <span class="count">${counts[cat]}</span> </button></li>
    `),
  ].join('');

  els.categoryList.querySelectorAll('[data-category]').forEach((btn) => {
    btn.addEventListener('click', () => {
      state.activeCategory = btn.dataset.category || null;
      onChange();
    });
  });
}

export function renderTags(els, onChange) {
  const tagSet = new Set();
  state.all.forEach((q) => (q.tags || []).forEach((t) => tagSet.add(t)));
  const tags = [...tagSet].sort();

  els.tagList.innerHTML = tags.map((tag) => `
    <button class="tag-chip ${state.activeTag === tag ? 'active' : ''}" data-tag="${escapeHtml(tag)}">${escapeHtml(tag)}</button>
  `).join('');

  els.tagList.querySelectorAll('[data-tag]').forEach((btn) => {
    btn.addEventListener('click', () => {
      state.activeTag = state.activeTag === btn.dataset.tag ? null : btn.dataset.tag;
      onChange();
    });
  });
}

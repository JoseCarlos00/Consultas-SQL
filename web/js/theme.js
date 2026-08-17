import { getPreferredTheme, setStoredTheme } from './storage.js';

export function applyTheme(theme) {
  document.documentElement.setAttribute('data-theme', theme);
}

export function initTheme(toggleBtn) {
  let theme = getPreferredTheme();
  applyTheme(theme);
  updateToggleLabel(toggleBtn, theme);

  toggleBtn.addEventListener('click', () => {
    theme = theme === 'dark' ? 'light' : 'dark';
    applyTheme(theme);
    setStoredTheme(theme);
    updateToggleLabel(toggleBtn, theme);
  });
}

function updateToggleLabel(btn, theme) {
  btn.textContent = theme === 'dark' ? '☀︎' : '☾';
  btn.setAttribute('aria-label', theme === 'dark' ? 'Cambiar a tema claro' : 'Cambiar a tema oscuro');
}

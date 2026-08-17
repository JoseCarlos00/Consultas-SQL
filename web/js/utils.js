export function escapeHtml(str) {
  return String(str ?? '').replace(/[&<>"']/g, (c) => ({
    '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;',
  }[c]));
}

export function isStale(q) {
  if (!q.ultima_verificacion || !q.ultima_modificacion) return false;
  return new Date(q.ultima_modificacion) > new Date(q.ultima_verificacion);
}

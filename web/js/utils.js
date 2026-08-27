export function escapeHtml(str) {
  return String(str ?? '').replace(/[&<>"']/g, (c) => ({
    '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;',
  }[c]));
}

export function isStale(q) {
  if (!q.ultima_verificacion || !q.ultima_modificacion) return false;
  return new Date(q.ultima_modificacion) > new Date(q.ultima_verificacion);
}

export function copyToClipboard(text) {
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

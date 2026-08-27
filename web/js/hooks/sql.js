import { state } from '../state.js';
import { copyToClipboard } from '../utils.js';

export const createUrl = (q) => ({
	rawUrl: `https://raw.githubusercontent.com/${state.repo}/${state.branch}/${q.ruta}`,
	githubUrl: `https://github.com/${state.repo}/blob/${state.branch}/${q.ruta}`,
});

export async function fetchSql(rawUrl) {
	try {
		const res = await fetch(rawUrl, { cache: 'no-store' });
		if (!res.ok) return null;

		return await res.text();
	} catch {
		return null;
	}
}

export function copyHeaders(q) {
	copyToClipboard(q.headers.join(','));
  return true;
}

export async function copySQL(q) {
	const { rawUrl } = createUrl(q);
	const text = await fetchSql(rawUrl);

	if (text !== null) {
		copyToClipboard(text);
		return true;
	}

	return false;
}

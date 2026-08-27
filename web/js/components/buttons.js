export function createActionButton(text, onClick, options = {}) {
	const button = document.createElement('button');

	button.classList.add('action-btn');

	if (options.primary) {
		button.classList.add('primary');
	}

	button.textContent = text;

	if (options.disabled) {
		button.disabled = true;
		button.title = options.title ?? '';
	}

	button.addEventListener('click', onClick);

	return button;
}

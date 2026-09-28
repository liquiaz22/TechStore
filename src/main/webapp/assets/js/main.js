document.addEventListener('click', (event) => {
  const button = event.target.closest('[data-confirm]');
  if (button && !window.confirm(button.dataset.confirm)) {
    event.preventDefault();
  }
});

document.querySelectorAll('[data-address-select]').forEach((radio) => {
  radio.addEventListener('change', () => {
    const manual = document.querySelector('[data-manual-address]');
    if (manual) manual.hidden = radio.value !== '';
  });
});

(() => {
  const body = document.body;
  const toggle = document.querySelector('[data-admin-menu-toggle]');
  const closeButtons = document.querySelectorAll('[data-admin-menu-close]');
  const sidebar = document.getElementById('adminSidebar');

  if (!toggle || !sidebar) return;

  const isMobile = () => window.innerWidth <= 820;
  const focusableElements = () => [...sidebar.querySelectorAll('a, button, input, select, textarea, [tabindex]:not([tabindex="-1"])')]
    .filter((element) => !element.disabled && element.getClientRects().length > 0);
  const syncAccessibility = () => {
    const hidden = isMobile() && !body.classList.contains('admin-menu-open');
    sidebar.inert = hidden;
    if (isMobile()) sidebar.setAttribute('aria-hidden', String(hidden));
    else sidebar.removeAttribute('aria-hidden');
  };

  const setOpen = (open, restoreFocus = true) => {
    body.classList.toggle('admin-menu-open', open);
    toggle.setAttribute('aria-expanded', String(open));
    syncAccessibility();
    if (open) {
      const firstLink = sidebar.querySelector('a');
      if (firstLink) firstLink.focus();
    } else if (restoreFocus) {
      toggle.focus();
    }
  };

  toggle.addEventListener('click', () => setOpen(!body.classList.contains('admin-menu-open')));
  closeButtons.forEach((button) => button.addEventListener('click', () => setOpen(false)));
  document.addEventListener('keydown', (event) => {
    if (!body.classList.contains('admin-menu-open')) return;
    if (event.key === 'Escape') {
      setOpen(false);
      return;
    }
    if (event.key === 'Tab') {
      const elements = focusableElements();
      if (!elements.length) return;
      const first = elements[0];
      const last = elements[elements.length - 1];
      if (event.shiftKey && document.activeElement === first) {
        event.preventDefault();
        last.focus();
      } else if (!event.shiftKey && document.activeElement === last) {
        event.preventDefault();
        first.focus();
      }
    }
  });
  window.addEventListener('resize', () => {
    if (window.innerWidth > 820 && body.classList.contains('admin-menu-open')) setOpen(false, false);
    else syncAccessibility();
  });
  syncAccessibility();
})();

(() => {
  const form = document.querySelector('[data-admin-order-status-form]');
  if (!form) return;

  const status = form.querySelector('[data-admin-order-status]');
  const note = form.querySelector('[data-admin-order-note]');
  const optional = form.querySelector('[data-admin-note-optional]');
  const help = form.querySelector('[data-admin-status-help]');
  const warning = form.querySelector('[data-admin-cancel-warning]');
  const submit = form.querySelector('[data-admin-status-submit]');

  const sync = () => {
    const cancelling = status.value === 'CANCELLED';
    note.required = cancelling;
    optional.textContent = cancelling ? 'Bắt buộc' : 'Không bắt buộc';
    help.textContent = cancelling
      ? 'Nhập lý do cụ thể để khách hàng hiểu vì sao đơn bị hủy.'
      : 'Ghi chú sẽ hiển thị trong lịch sử xử lý.';
    warning.hidden = !cancelling;
    submit.classList.toggle('btn-danger', cancelling);
    submit.classList.toggle('btn-primary', !cancelling);
    submit.textContent = cancelling ? 'Xác nhận hủy đơn' : 'Cập nhật trạng thái';
  };

  status.addEventListener('change', sync);
  form.addEventListener('submit', (event) => {
    const label = status.options[status.selectedIndex]?.textContent?.trim() || status.value;
    const message = status.value === 'CANCELLED'
      ? 'Hủy đơn sẽ hoàn lại tồn kho và không thể hoàn tác trực tiếp. Tiếp tục?'
      : `Xác nhận chuyển đơn hàng sang “${label}”?`;
    if (!window.confirm(message)) event.preventDefault();
  });
  sync();
})();

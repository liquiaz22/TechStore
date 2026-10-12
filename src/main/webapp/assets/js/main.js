document.addEventListener('click', (event) => {
  const button = event.target.closest('[data-confirm]');
  if (button && !window.confirm(button.dataset.confirm)) {
    event.preventDefault();
  }
});

(() => {
  const form = document.querySelector('[data-checkout-form]');
  if (!form) return;

  const addressChoices = [...form.querySelectorAll('[data-address-select]')];
  const manualAddress = form.querySelector('[data-manual-address]');
  const manualInputs = [...manualAddress.querySelectorAll('input')];
  const paymentChoices = [...form.querySelectorAll('input[name="paymentMethod"]')];
  const vnpayNotice = form.querySelector('[data-vnpay-notice]');
  const submitButton = form.querySelector('[data-checkout-submit]');

  const showFieldError = (input) => {
    const error = form.querySelector(`[data-field-error="${input.name}"]`);
    if (!error) return;
    let message = '';
    if (input.validity.valueMissing) message = input.dataset.requiredMessage || 'Vui lòng nhập thông tin này.';
    else if (input.validity.patternMismatch) message = input.dataset.patternMessage || 'Thông tin chưa đúng định dạng.';
    error.textContent = message;
    input.closest('.field')?.classList.toggle('field-invalid', Boolean(message));
  };

  const syncAddress = () => {
    const selected = addressChoices.find((choice) => choice.checked);
    const useManualAddress = !selected || selected.value === '';
    addressChoices.forEach((choice) => choice.closest('.address-option')?.classList.toggle('selected', choice === selected));
    manualAddress.hidden = !useManualAddress;
    manualInputs.forEach((input) => {
      input.disabled = !useManualAddress;
      input.required = useManualAddress;
      if (!useManualAddress) {
        input.closest('.field')?.classList.remove('field-invalid');
        const error = form.querySelector(`[data-field-error="${input.name}"]`);
        if (error) error.textContent = '';
      }
    });
  };

  const syncPayment = () => {
    const selected = paymentChoices.find((choice) => choice.checked);
    const isVnpay = selected?.value === 'VNPAY';
    paymentChoices.forEach((choice) => choice.closest('.payment-option')?.classList.toggle('selected', choice === selected));
    if (vnpayNotice) vnpayNotice.hidden = !isVnpay;
    submitButton.textContent = isVnpay ? 'Thanh toán qua VNPay' : 'Đặt hàng COD';
  };

  addressChoices.forEach((choice) => choice.addEventListener('change', syncAddress));
  paymentChoices.forEach((choice) => choice.addEventListener('change', syncPayment));
  manualInputs.forEach((input) => {
    input.addEventListener('invalid', (event) => { event.preventDefault(); showFieldError(input); });
    input.addEventListener('input', () => showFieldError(input));
  });
  form.addEventListener('submit', (event) => {
    if (form.dataset.submitting === 'true') {
      event.preventDefault();
      return;
    }
    form.dataset.submitting = 'true';
    submitButton.disabled = true;
    submitButton.textContent = paymentChoices.find((choice) => choice.checked)?.value === 'VNPAY'
      ? 'Đang chuyển đến VNPay...'
      : 'Đang tạo đơn hàng...';
  });

  syncAddress();
  syncPayment();
})();

(() => {
  const body = document.body;
  const toggle = document.querySelector('[data-store-menu-toggle]');
  const navigation = document.getElementById('storeNavigation');
  const closeButtons = document.querySelectorAll('[data-store-menu-close]');

  if (!toggle || !navigation) return;

  const isMobile = () => window.innerWidth <= 960;
  const focusableElements = () => [...navigation.querySelectorAll('a, button, input, select, textarea, [tabindex]:not([tabindex="-1"])')]
    .filter((element) => !element.disabled && element.getClientRects().length > 0);
  const syncAccessibility = () => {
    const hidden = isMobile() && !body.classList.contains('store-menu-open');
    navigation.inert = hidden;
    if (isMobile()) navigation.setAttribute('aria-hidden', String(hidden));
    else navigation.removeAttribute('aria-hidden');
  };

  const setOpen = (open, restoreFocus = true) => {
    body.classList.toggle('store-menu-open', open);
    toggle.setAttribute('aria-expanded', String(open));
    syncAccessibility();
    if (open) {
      const search = navigation.querySelector('input[type="search"]');
      if (search) search.focus();
    } else if (restoreFocus) {
      toggle.focus();
    }
  };

  toggle.addEventListener('click', () => setOpen(!body.classList.contains('store-menu-open')));
  closeButtons.forEach((button) => button.addEventListener('click', () => setOpen(false)));
  navigation.querySelectorAll('a').forEach((link) => link.addEventListener('click', () => {
    if (window.innerWidth <= 960) setOpen(false, false);
  }));
  document.addEventListener('keydown', (event) => {
    if (!body.classList.contains('store-menu-open')) return;
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
    if (window.innerWidth > 960 && body.classList.contains('store-menu-open')) {
      setOpen(false, false);
    } else {
      syncAccessibility();
    }
  });
  syncAccessibility();
})();

(() => {
  const cart = document.querySelector('[data-cart]');
  if (!cart) return;

  const rows = [...cart.querySelectorAll('[data-cart-item]')];
  const subtotalLabels = [...cart.querySelectorAll('[data-cart-subtotal], [data-cart-total]')];
  const checkout = cart.querySelector('[data-cart-checkout]');
  const dirtyNote = cart.querySelector('[data-cart-dirty-note]');
  const money = new Intl.NumberFormat('vi-VN');

  const moneyText = (value) => `${money.format(value)} ₫`;

  const syncCart = () => {
    let subtotal = 0;
    let hasUnsavedQuantity = false;
    rows.forEach((row) => {
      const input = row.querySelector('[data-cart-quantity]');
      const form = row.querySelector('[data-cart-quantity-form]');
      const minus = row.querySelector('[data-cart-minus]');
      const plus = row.querySelector('[data-cart-plus]');
      const lineTotal = row.querySelector('[data-cart-line-total]');
      const stock = Math.max(0, Number(row.dataset.stock) || 0);
      const unitPrice = Math.max(0, Number(row.dataset.unitPrice) || 0);
      let quantity = Math.max(1, Number(input.value) || 1);
      if (stock > 0) quantity = Math.min(stock, quantity);
      input.value = String(quantity);
      minus.disabled = stock <= 0 || quantity <= 1;
      plus.disabled = stock <= 0 || quantity >= stock;
      const total = unitPrice * quantity;
      lineTotal.textContent = moneyText(total);
      subtotal += total;
      const isDirty = input.value !== form.dataset.initialQuantity;
      form.classList.toggle('dirty', isDirty);
      hasUnsavedQuantity ||= isDirty;
    });
    subtotalLabels.forEach((label) => { label.textContent = moneyText(subtotal); });
    checkout.setAttribute('aria-disabled', String(hasUnsavedQuantity));
    dirtyNote.hidden = !hasUnsavedQuantity;
  };

  rows.forEach((row) => {
    const input = row.querySelector('[data-cart-quantity]');
    const minus = row.querySelector('[data-cart-minus]');
    const plus = row.querySelector('[data-cart-plus]');
    minus.addEventListener('click', () => { input.value = String((Number(input.value) || 1) - 1); syncCart(); });
    plus.addEventListener('click', () => { input.value = String((Number(input.value) || 1) + 1); syncCart(); });
    input.addEventListener('input', syncCart);
    input.addEventListener('change', syncCart);
  });

  checkout.addEventListener('click', (event) => {
    if (checkout.getAttribute('aria-disabled') === 'true') event.preventDefault();
  });

  syncCart();
})();

(() => {
  const purchase = document.querySelector('[data-product-purchase]');
  const mainImage = document.getElementById('productMainImage');
  if (!purchase || !mainImage) return;

  const contextPath = purchase.dataset.contextPath || '';
  const choices = [...purchase.querySelectorAll('[data-variant-choice]')];
  const thumbnails = [...document.querySelectorAll('[data-gallery-thumbnail]')];
  const price = purchase.querySelector('[data-detail-price]');
  const oldPrice = purchase.querySelector('[data-detail-old-price]');
  const discount = purchase.querySelector('[data-detail-discount]');
  const stockText = purchase.querySelector('[data-detail-stock]');
  const quantity = purchase.querySelector('#quantity');
  const minus = purchase.querySelector('[data-quantity-minus]');
  const plus = purchase.querySelector('[data-quantity-plus]');
  const submitButtons = [...purchase.querySelectorAll('button[type="submit"]')];
  const money = new Intl.NumberFormat('vi-VN');

  const publicImageUrl = (imageUrl) => {
    if (!imageUrl) return mainImage.dataset.defaultImage;
    if (/^https?:\/\//i.test(imageUrl)) return imageUrl;
    return `${contextPath}/${imageUrl.replace(/^\/+/, '')}`;
  };

  const selectImage = (imageUrl) => {
    if (!imageUrl) return;
    mainImage.src = imageUrl;
    thumbnails.forEach((thumbnail) => {
      thumbnail.classList.toggle('active', thumbnail.dataset.imageUrl === imageUrl);
    });
  };

  const syncQuantity = () => {
    const max = Math.max(1, Number(quantity.max) || 1);
    let value = Number(quantity.value) || 1;
    value = Math.min(max, Math.max(1, value));
    quantity.value = String(value);
    minus.disabled = value <= 1;
    plus.disabled = value >= max;
  };

  const selectVariant = (choice) => {
    if (!choice) return;
    choices.forEach((item) => item.closest('.variant-option')?.classList.toggle('selected', item === choice));

    const currentPrice = Number(choice.dataset.price) || 0;
    const currentOriginalPrice = Number(choice.dataset.originalPrice) || 0;
    const stock = Math.max(0, Number(choice.dataset.stock) || 0);
    price.textContent = `${money.format(currentPrice)} ₫`;
    oldPrice.hidden = currentOriginalPrice <= currentPrice;
    oldPrice.textContent = currentOriginalPrice > currentPrice ? `${money.format(currentOriginalPrice)} ₫` : '';
    discount.hidden = currentOriginalPrice <= currentPrice;
    discount.textContent = currentOriginalPrice > currentPrice
      ? `Tiết kiệm ${Math.round((currentOriginalPrice - currentPrice) * 100 / currentOriginalPrice)}%`
      : '';
    stockText.textContent = stock > 0 ? `Còn ${money.format(stock)} sản phẩm` : 'Phiên bản đang tạm hết hàng';
    stockText.classList.toggle('out-of-stock', stock <= 0);
    quantity.max = String(Math.max(1, stock));
    quantity.disabled = stock <= 0;
    submitButtons.forEach((button) => { button.disabled = stock <= 0; });
    syncQuantity();
    selectImage(choice.dataset.imageUrl
      ? publicImageUrl(choice.dataset.imageUrl)
      : mainImage.dataset.defaultImage);
  };

  thumbnails.forEach((thumbnail) => thumbnail.addEventListener('click', () => {
    selectImage(thumbnail.dataset.imageUrl);
  }));
  choices.forEach((choice) => choice.addEventListener('change', () => selectVariant(choice)));
  minus?.addEventListener('click', () => { quantity.value = String((Number(quantity.value) || 1) - 1); syncQuantity(); });
  plus?.addEventListener('click', () => { quantity.value = String((Number(quantity.value) || 1) + 1); syncQuantity(); });
  quantity?.addEventListener('input', syncQuantity);
  quantity?.addEventListener('change', syncQuantity);

  selectVariant(choices.find((choice) => choice.checked && !choice.disabled));
})();

document.addEventListener('click', (event) => {
  document.querySelectorAll('.store-account-menu[open]').forEach((menu) => {
    if (!menu.contains(event.target)) menu.removeAttribute('open');
  });
});

(() => {
  const body = document.body;
  const toggle = document.querySelector('[data-filter-toggle]');
  const drawer = document.getElementById('catalogFilter');
  const closeButtons = document.querySelectorAll('[data-filter-close]');

  if (!toggle || !drawer) return;

  const isMobile = () => window.innerWidth <= 960;
  const focusableElements = () => [...drawer.querySelectorAll('a, button, input, select, textarea, [tabindex]:not([tabindex="-1"])')]
    .filter((element) => !element.disabled && element.getClientRects().length > 0);
  const syncAccessibility = () => {
    const hidden = isMobile() && !body.classList.contains('filter-drawer-open');
    drawer.inert = hidden;
    if (isMobile()) drawer.setAttribute('aria-hidden', String(hidden));
    else drawer.removeAttribute('aria-hidden');
  };

  const setOpen = (open, restoreFocus = true) => {
    body.classList.toggle('filter-drawer-open', open);
    toggle.setAttribute('aria-expanded', String(open));
    syncAccessibility();
    if (open) {
      const firstControl = drawer.querySelector('input, select, button');
      if (firstControl) firstControl.focus();
    } else if (restoreFocus) {
      toggle.focus();
    }
  };

  toggle.addEventListener('click', () => setOpen(true));
  closeButtons.forEach((button) => button.addEventListener('click', () => setOpen(false)));
  document.addEventListener('keydown', (event) => {
    if (!body.classList.contains('filter-drawer-open')) return;
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
    if (window.innerWidth > 960 && body.classList.contains('filter-drawer-open')) {
      setOpen(false, false);
    } else {
      syncAccessibility();
    }
  });
  syncAccessibility();
})();

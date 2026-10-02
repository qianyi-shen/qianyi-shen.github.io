/* Priority navigation: move links into the overflow menu when space is limited. */
(() => {
  const nav = document.getElementById('site-nav');
  if (!nav) return;

  const button = nav.querySelector('button');
  const visibleLinks = nav.querySelector('.visible-links');
  const hiddenLinks = nav.querySelector('.hidden-links');
  const themeToggle = document.getElementById('theme-toggle');
  const masthead = document.querySelector('.masthead');
  const breaks = [];

  const closeNav = () => {
    hiddenLinks.classList.add('hidden');
    button.classList.remove('close');
    button.setAttribute('aria-expanded', 'false');
  };

  const availableSpace = (showButton) => {
    const gap = parseFloat(getComputedStyle(nav).columnGap) || 0;
    return nav.getBoundingClientRect().width - themeToggle.getBoundingClientRect().width - gap * 2
      - (showButton ? button.getBoundingClientRect().width : 0);
  };

  const updateNav = () => {
    const focusedElement = document.activeElement;
    let showButton = !button.classList.contains('hidden');
    if (visibleLinks.getBoundingClientRect().width > availableSpace(showButton)) {
      button.classList.remove('hidden');
      while (visibleLinks.getBoundingClientRect().width > availableSpace(true)) {
        const link = visibleLinks.lastElementChild;
        if (!link || link.classList.contains('persist')) break;
        breaks.push(visibleLinks.getBoundingClientRect().width);
        hiddenLinks.prepend(link);
      }
    } else {
      while (breaks.length && availableSpace(breaks.length > 1) > breaks[breaks.length - 1]) {
        visibleLinks.append(hiddenLinks.firstElementChild);
        breaks.pop();
      }
    }

    if (!breaks.length) {
      button.classList.add('hidden');
      closeNav();
    }
    // Moving a focused link can blur it, or place it inside the closed menu.
    if (nav.contains(focusedElement)) {
      if (focusedElement === button && button.classList.contains('hidden')) {
        visibleLinks.querySelector('a').focus({ preventScroll: true });
      } else if (hiddenLinks.contains(focusedElement) && hiddenLinks.classList.contains('hidden')) {
        button.focus({ preventScroll: true });
      } else if (document.activeElement !== focusedElement) {
        focusedElement.focus({ preventScroll: true });
      }
    }

    // CSS uses this value for the fixed masthead and sticky sidebar.
    document.documentElement.style.setProperty('--masthead-height', masthead.getBoundingClientRect().height + 'px');
  };

  let pendingFrame = 0;
  const scheduleNav = () => {
    if (pendingFrame) return;
    pendingFrame = requestAnimationFrame(() => {
      pendingFrame = 0;
      updateNav();
    });
  };
  window.addEventListener('resize', scheduleNav);
  if (window.screen && screen.orientation && screen.orientation.addEventListener) {
    screen.orientation.addEventListener('change', scheduleNav);
  } else {
    window.addEventListener('orientationchange', scheduleNav);
  }

  button.addEventListener('click', () => {
    const open = button.getAttribute('aria-expanded') !== 'true';
    hiddenLinks.classList.toggle('hidden', !open);
    button.classList.toggle('close', open);
    button.setAttribute('aria-expanded', String(open));
  });
  nav.addEventListener('click', (event) => {
    if (event.target.closest('a[href]')) closeNav();
  });
  window.addEventListener('pageshow', () => {
    closeNav();
    scheduleNav();
  });
  document.addEventListener('click', (event) => {
    if (!nav.contains(event.target)) closeNav();
  });
  document.addEventListener('keydown', (event) => {
    if (event.key === 'Escape' && button.getAttribute('aria-expanded') === 'true') {
      closeNav();
      button.focus();
    }
  });

  updateNav();
})();

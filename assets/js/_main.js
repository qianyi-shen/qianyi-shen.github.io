/* ==========================================================================
   Various functions that we want to use within the template
   ========================================================================== */

const browserPref = window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';

const getStoredTheme = () => {
  try {
    const storedTheme = localStorage.getItem('theme');
    return storedTheme === 'light' || storedTheme === 'dark' ? storedTheme : null;
  } catch (error) {
    return null;
  }
};

const storeTheme = (theme) => {
  try {
    localStorage.setItem('theme', theme);
  } catch (error) {
    // The visual theme still changes when storage is unavailable.
  }
};

const updateThemeColor = (theme) => {
  const themeColor = document.getElementById('theme-color');
  if (!themeColor) return;

  const attribute = theme === 'dark' ? 'data-dark' : 'data-light';
  themeColor.setAttribute('content', themeColor.getAttribute(attribute));
};

const setTheme = (theme) => {
  const useTheme = theme || getStoredTheme() || $('html').attr('data-theme') || browserPref;
  const useDarkTheme = useTheme === 'dark';

  if (useDarkTheme) {
    $('html').attr('data-theme', 'dark');
    $('#theme-icon').removeClass('fa-sun').addClass('fa-moon');
    updateThemeColor('dark');
  } else {
    $('html').removeAttr('data-theme');
    $('#theme-icon').removeClass('fa-moon').addClass('fa-sun');
    updateThemeColor('light');
  }

  $('#theme-toggle a').attr('aria-pressed', useDarkTheme ? 'true' : 'false');
};

const toggleTheme = () => {
  const currentTheme = $('html').attr('data-theme');
  const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
  storeTheme(newTheme);
  setTheme(newTheme);
};

const formatVisitCount = (count) => {
  try {
    return new Intl.NumberFormat(document.documentElement.lang || 'en-US').format(count);
  } catch (error) {
    return String(count);
  }
};

const updateVisitCount = () => {
  const counter = document.querySelector('[data-visit-count]');
  if (!counter) return;

  const legacyCount = Number.parseInt(counter.getAttribute('data-legacy-count'), 10) || 0;
  const countUrl = counter.getAttribute('data-count-url');
  counter.textContent = formatVisitCount(legacyCount);

  if (!countUrl || !window.fetch) return;

  window.fetch(countUrl, {
    credentials: 'omit',
    mode: 'cors',
  })
    .then((response) => {
      if (!response.ok) throw new Error('Visit count request failed');
      return response.json();
    })
    .then((data) => {
      const currentCount = Number.parseInt(String(data.count || '').replace(/[^0-9]/g, ''), 10);
      if (Number.isFinite(currentCount)) {
        counter.textContent = formatVisitCount(legacyCount + currentCount);
      }
    })
    .catch(() => {
      // Keep showing the historical count when the service is unavailable or blocked.
    });
};

/* ==========================================================================
   Actions that should occur when the page has been fully loaded
   ========================================================================== */

$(document).ready(function () {
  // SCSS SETTINGS - These should be the same as the settings in the relevant files 
  const scssLarge = 925;  // pixels, from /_sass/_themes.scss

  updateVisitCount();

  // If the user hasn't chosen a theme, follow the OS preference
  setTheme();
  window.matchMedia('(prefers-color-scheme: dark)')
        .addEventListener("change", (e) => {
          if (!getStoredTheme()) {
            setTheme(e.matches ? "dark" : "light");
          }
        });

  // Enable the theme toggle
  $('#theme-toggle').on('click', toggleTheme);
  $('#theme-toggle a').on('keydown', function (event) {
    if (event.key === 'Enter' || event.key === ' ') {
      event.preventDefault();
      toggleTheme();
    }
  });

  // Native button activation supports both Enter and Space.
  const wechatButton = document.querySelector('.author__wechat-trigger');
  const wechatPopover = document.getElementById('wechat-qr');
  const setWechatOpen = (open) => {
    if (!wechatButton || !wechatPopover) return;
    wechatButton.setAttribute('aria-expanded', String(open));
    wechatPopover.hidden = !open;
  };
  if (wechatButton && wechatPopover) {
    const wechatRow = wechatButton.closest('.author__wechat');
    wechatButton.addEventListener('click', () => {
      setWechatOpen(wechatPopover.hidden);
    });
    wechatRow.addEventListener('pointerenter', (event) => {
      if (event.pointerType === 'mouse') setWechatOpen(true);
    });
    wechatRow.addEventListener('pointerleave', () => {
      if (!wechatRow.contains(document.activeElement)) setWechatOpen(false);
    });
    wechatRow.addEventListener('keydown', (event) => {
      if (event.key === 'Escape' && !wechatPopover.hidden) {
        event.preventDefault();
        event.stopPropagation();
        setWechatOpen(false);
      }
    });
    wechatRow.addEventListener('focusout', (event) => {
      if (!wechatRow.contains(event.relatedTarget)) setWechatOpen(false);
    });
    document.addEventListener('click', (event) => {
      if (!wechatRow.contains(event.target)) setWechatOpen(false);
    });
  }

  // Contact links: CSS owns the breakpoint; JS only owns the expanded state.
  const contactButton = document.querySelector('.author__contact-toggle');
  const contactLinks = document.getElementById('author-links');
  if (contactButton && contactLinks) {
    const contactWrapper = contactButton.closest('.author__urls-wrapper');
    const desktopContact = window.matchMedia('(min-width: ' + (scssLarge / 16) + 'em)');
    const setContactOpen = (open, restoreFocus) => {
      contactWrapper.classList.toggle('is-open', open);
      contactButton.setAttribute('aria-expanded', String(open));
      if (!open) setWechatOpen(false);
      if (restoreFocus) contactButton.focus();
    };
    contactButton.addEventListener('click', () => {
      setContactOpen(contactButton.getAttribute('aria-expanded') !== 'true');
    });
    contactWrapper.addEventListener('keydown', (event) => {
      if (event.key === 'Escape' && !desktopContact.matches) {
        event.preventDefault();
        setContactOpen(false, true);
      }
    });
    document.addEventListener('click', (event) => {
      if (!contactWrapper.contains(event.target)) setContactOpen(false);
    });
    contactWrapper.addEventListener('focusout', (event) => {
      if (!contactWrapper.contains(event.relatedTarget)) setContactOpen(false);
    });
    desktopContact.addEventListener('change', () => {
      const activeLink = contactLinks.contains(document.activeElement);
      const activeButton = document.activeElement === contactButton;
      setContactOpen(false, !desktopContact.matches && activeLink);
      if (desktopContact.matches && activeButton) contactLinks.querySelector('a').focus();
    });
  }

});

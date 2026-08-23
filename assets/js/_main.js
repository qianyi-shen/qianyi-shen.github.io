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
  const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

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

  // Enable the sticky footer
  var bumpIt = function () {
    $("body").css("padding-bottom", "0");
    $("body").css("margin-bottom", $(".page__footer").outerHeight(true));
  }
  $(window).resize(function () {
    didResize = true;
  });
  setInterval(function () {
    if (didResize) {
      didResize = false;
      bumpIt();
    }}, 250);
  var didResize = false;
  bumpIt();

  // Follow menu drop down
  $(".author__urls-wrapper button").on("click", function () {
    if (prefersReducedMotion) {
      $(".author__urls").toggle();
    } else {
      $(".author__urls").fadeToggle("fast", function () { });
    }
    $(".author__urls-wrapper button").toggleClass("open");
  });

  // Restore the follow menu if toggled on a window resize
  jQuery(window).on('resize', function () {
    if ($('.author__urls.social-icons').css('display') == 'none' && $(window).width() >= scssLarge) {
      $(".author__urls").css('display', 'block')
    }
  });

});

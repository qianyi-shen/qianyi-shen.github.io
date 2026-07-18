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

/* ==========================================================================
   Actions that should occur when the page has been fully loaded
   ========================================================================== */

$(document).ready(function () {
  // SCSS SETTINGS - These should be the same as the settings in the relevant files 
  const scssLarge = 925;          // pixels, from /_sass/_themes.scss
  const scssMastheadHeight = 70;  // pixels, from the current theme (e.g., /_sass/theme/_default.scss)
  const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

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

  // Init smooth scroll, this needs to be slightly more than then fixed masthead height
  if (!prefersReducedMotion) {
    $("a").smoothScroll({
      offset: -scssMastheadHeight,
      preventDefault: false,
    });
  }

});

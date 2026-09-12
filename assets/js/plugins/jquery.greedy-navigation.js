/*
* Greedy Navigation
*
* http://codepen.io/lukejacksonn/pen/PwmwWV
*
*/

var $nav = $('#site-nav');
var $btn = $('#site-nav button');
var $vlinks = $('#site-nav .visible-links');
var $hlinks = $('#site-nav .hidden-links');
var $themeToggle = $('#theme-toggle');

var breaks = [];

function closeNav() {
  $hlinks.addClass('hidden');
  $btn.removeClass('close').attr('aria-expanded', 'false');
}

function getAvailableSpace(showMenuButton) {
  var columnGap = parseFloat($nav.css('column-gap')) || 0;
  var controlsWidth = $themeToggle.outerWidth(true) + (columnGap * 2);

  if (showMenuButton) {
    controlsWidth += $btn.outerWidth(true);
  }

  return $nav.innerWidth() - controlsWidth;
}

function updateNav() {

  var menuButtonVisible = !$btn.hasClass('hidden');
  var availableSpace = getAvailableSpace(menuButtonVisible);

  // The visible list is overflowing the nav
  if ($vlinks.width() > availableSpace) {

    if (!menuButtonVisible) {
      $btn.removeClass('hidden');
      menuButtonVisible = true;
      availableSpace = getAvailableSpace(true);
    }

    while ($vlinks.width() > availableSpace && $vlinks.children("*:not(.persist)").length > 0) {
      // Record the width of the list
      breaks.push($vlinks.width());

      // Move item to the hidden list
      $vlinks.children("*:not(.persist)").last().prependTo($hlinks);

      availableSpace = getAvailableSpace(true);
    }

    // The visible list is not overflowing
  } else {

    // There is space for another item in the nav
    while (breaks.length > 0) {
      var restoringLastItem = breaks.length === 1;
      var restorationSpace = getAvailableSpace(!restoringLastItem);

      if (restorationSpace <= breaks[breaks.length - 1]) {
        break;
      }

      // Move the item to the visible list
      $hlinks.children().first().appendTo($vlinks);
      breaks.pop();
    }

    // Hide the dropdown btn if hidden list is empty
    if (breaks.length < 1) {
      $btn.addClass('hidden');
      closeNav();
    }
  }

  // Keep counter updated
  $btn.attr("count", breaks.length);

  // Reserve space for the fixed masthead; the sidebar uses CSS sticky positioning.
  var mastheadHeight = $('.masthead').height();
  $('body').css('padding-top', mastheadHeight + 'px');
  document.documentElement.style.setProperty('--masthead-height', mastheadHeight + 'px');

}

// Window listeners

$(window).on('resize', function () {
  updateNav();
});
if (window.screen && screen.orientation && typeof screen.orientation.addEventListener === "function") {
  screen.orientation.addEventListener("change", function () {
    updateNav();
  });
} else {
  $(window).on("orientationchange", function () {
    updateNav();
  });
}

$btn.on('click', function () {
  var isOpen = $btn.attr('aria-expanded') !== 'true';
  $hlinks.toggleClass('hidden', !isOpen);
  $btn.toggleClass('close', isOpen).attr('aria-expanded', String(isOpen));
});

// Do not retain an open dropdown when navigating or restoring a cached page.
$nav.on('click', 'a[href]', closeNav);
$(window).on('pageshow', function () {
  closeNav();
  updateNav();
});
$(document).on('click', function (event) {
  if (!$nav[0].contains(event.target)) closeNav();
}).on('keydown', function (event) {
  if (event.key === 'Escape' && $btn.attr('aria-expanded') === 'true') {
    closeNav();
    $btn.trigger('focus');
  }
});

updateNav();

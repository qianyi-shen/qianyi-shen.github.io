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
      $btn.removeClass('close');
      $hlinks.addClass('hidden');
    }
  }

  // Keep counter updated
  $btn.attr("count", breaks.length);

  // update masthead height and the body/sidebar top padding
  var mastheadHeight = $('.masthead').height();
  $('body').css('padding-top', mastheadHeight + 'px');
  if ($(".author__urls-wrapper button").is(":visible")) {
    $(".sidebar").css("padding-top", "");
  } else {
    $(".sidebar").css("padding-top", mastheadHeight + "px");
  }

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
  $hlinks.toggleClass('hidden');
  $(this).toggleClass('close');
});

updateNav();

$(document).ready(function () {
  // Init Pleasure functions
  Pleasure.init()

  // If the browser not mobile
  if(!(/Android|iPhone|iPad|iPod|BlackBerry|Windows Phone/i).test(navigator.userAgent || navigator.vendor || window.opera)) {
    // Init skrollr plugin for parallax
    skrollr.init({
      forceHeight: false
    })

    // Init typer plugin for retyping text
    $('[data-typer-targets]').typer({
      random: false,
      wholeWord: true
    })
  }

  var $scrolling = false

  function makeWatcher ( element ) {
    var watcher = scrollMonitor.create(element)
    // If the slide in viewport call animatedSelector function
    watcher.fullyEnterViewport(function () {
      animatedSelector(element.data('nav'));
    })
  }

  function animatedSelector (object) {
    if(!$scrolling) {
      $selector = $('.selector')

      // If user reachs to top, remove the selector border
      if(object == 'remove') {
        $selector.removeClass('initialised')
      } else {
        $animatedSelector = $('.navigation [data-anchor="' + object + '"]').parents('.animated-selector')
        if( !$selector.hasClass('initialised'))
          $selector.addClass('initialised')

        $selector.css({'left': $('.navigation [data-anchor="' + object + '"]').position().left + 20, 'width': $('.navigation [data-anchor="' + object + '"]').width() })
      }
    }
  }

  // Monitor for each slide for moving navigation active border
  $('.slide').each(function () {
    makeWatcher($(this))
  })

  // If user clicks the navigation, scroll to related slide.
  $('[data-nav-link]').on('click', function () {
    animatedSelector($(this).data('anchor'))
    $scrolling = true
    setTimeout(function () {
      $scrolling = false
    }, 300)

    $('.header').removeClass('active')
    $('html, body').animate({ scrollTop: $('[data-nav="' + $(this).data('anchor') + '"]').position().top }, 300)
  })

  // If user clicks the logo, scroll to top.
  $('.logo').on('click', function () {
    $('html, body').animate({ scrollTop: 0 }, 'medium')
    $('.header').removeClass('active')
  })

  // Hamburger menu events
  $('.hamburger-btn').on('click', function () {
    $('.header').toggleClass('active')
  })

})

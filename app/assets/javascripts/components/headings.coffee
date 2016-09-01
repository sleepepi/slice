$(window).on('scroll', ->
  $('.header-container').each ->
    pos = $(this).offset().top
    winTop = $(window).scrollTop()
    if pos < winTop
      $(this).addClass 'header-container-offthehook'
      $('.navbar-header').addClass 'navbar-page-title'
    else
      $(this).removeClass 'header-container-offthehook'
      $('.navbar-header').removeClass 'navbar-page-title'
)

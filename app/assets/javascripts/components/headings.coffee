$(window).on('scroll', ->
  $('.header-container').each ->
    pos = $(this).offset().top
    winTop = $(window).scrollTop()
    if pos < winTop
      $(this).addClass 'header-container-offthehook'
      $('#top-menu').addClass('navbar-scrolled')
    else
      $(this).removeClass 'header-container-offthehook'
      $('#top-menu').removeClass('navbar-scrolled')
)

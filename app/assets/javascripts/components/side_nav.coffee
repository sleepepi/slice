$(document)
  .on('click', "[data-object~='toggle-drawer'], .mask-visible", () ->
    $('#side-nav').toggleClass('side-nav-drawer-open')
    $('body').toggleClass('mask-disable-scroll')
    $('.mask-modal').toggleClass('mask-visible')
    false
  )

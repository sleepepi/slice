$(document)
  .on('click touchstart', "[data-object~='toggle-drawer'], .mask-visible", () ->
    $('#side-nav').toggleClass('side-nav-drawer-open')
    $('body').toggleClass('mask-disable-scroll')
    $('.mask-modal').toggleClass('mask-visible')
    false
  )
  .on('click', "[data-object~='toggle-section-links']", () ->
    $(this).closest('.side-nav-section').find('.side-nav-section-links').toggleClass('active')
    false
  )

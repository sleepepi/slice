$(document)
  .on('click', '[data-object~=scroll-anchor]', (event) ->
    # Make sure this.hash has a value before overriding default behavior
    if @hash != '' and $(@hash).length > 0
      $('[data-object~=scroll-anchor]').parent().removeClass('active')
      $(this).parent().addClass('active')
      # Prevent default anchor click behavior
      event.preventDefault()
      # Store hash
      hash = @hash
      $('html, body').animate { scrollTop: $(hash).offset().top }, 400
  )
  .on('click', '[data-object~=scroll-anchor-keep-link]', (event) ->
    # Make sure this.hash has a value before overriding default behavior
    if @hash != '' and $(@hash).length > 0
      # Store hash
      hash = @hash
      event.preventDefault()
      $('html, body').animate { scrollTop: $(hash).offset().top }, 400, -> window.location.hash = hash
  )

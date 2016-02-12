@randomizationsReady = () ->
  $("[data-object~='randomization_subject_search']").each( () ->
    $this = $(this)
    $this.typeahead(
      remote: root_url + "projects/#{$this.data('project-slug')}/randomization_schemes/#{$this.data('randomization-scheme-id')}/subject_search?q=%QUERY"
      template: '<p><span class="label label-{{status_class}}">{{status}}</span> <strong>{{subject_code}}</strong></p>'
      engine: Hogan
    )
  )

@checkRandomizationOption = (element) ->
  $(element).prop('checked', true)
  $(element).closest('.sheet-container').find('.radio').removeClass('selected')
  $(element).closest('.radio').addClass('selected')

$(document)
  .on('typeahead:selected', "[data-object~='randomization_subject_search']", (event, datum) ->
    checkRandomizationOption("#stratification_factors_#{$(this).data('sfo-id')}_#{datum['site_id']}")
    $.each(datum['stratification_factors'], (key, value) ->
      radio_input = "[data-stratification-factor-id=#{key}][data-value=#{value}]"
      checkRandomizationOption(radio_input)
    )
  )

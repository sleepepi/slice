# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  $(document)
    .on('click', '#add_more_domain_options', () ->
      $.post(root_url + 'projects/' + $("#domain_project_id").val() + '/domains/add_option', $("form").serialize() + "&_method=post", null, "script")
      false
    )

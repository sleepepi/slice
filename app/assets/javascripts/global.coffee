@fadeAndRemove = (element) ->
  $(element).fadeOut(500, -> $(element).remove())

@setFocusToField = (element_id) ->
  val = $(element_id).val()
  $(element_id).focus().val("").val(val)

@componentsReady = ->
  aerReady()
  engineReady()
  themesReady()
  cubesReady()
  traysReady()

@extensionsReady = ->
  clipboardReady()
  datepickerReady()
  tooltipsReady()
  textcompleteReady()
  typeaheadReady() # TODO: Deprecate/remove use of typeahead

@globalReady = ->
  window.$isDirty = false
  componentsReady()
  extensionsReady()
  $("[data-object~=form-load]").submit()

# These functions get called on initial page visit and on turbolink page changes
@turbolinksReady = ->
  globalReady()
  designsReady()
  domainsReady()
  reportsReady()
  sheetsReady()
  variablesReady()
  subjectsReady()
  adverseEventsReady()
  projectsReady()
  eventsReady()
  randomizationsReady()
  fileDragReady()
  randomizationSchemesReady()
  signaturesReady()
  timeoutReady()

# These functions only get called on the initial page visit (no turbolinks).
# Browsers that don't support turbolinks will initialize all functions in
# turbolinks on page load. Those that do support Turbolinks won't call these
# methods here, but instead will wait for `turbolinks:load` event to prevent
# running the functions twice.
@initialLoadReady = ->
  turbolinksReady() unless Turbolinks.supported

$(window).onbeforeunload = -> return "You haven't saved your changes." if window.$isDirty
$(document).ready(initialLoadReady)
$(document)
  .on("turbolinks:load", turbolinksReady)
  .on("turbolinks:before-visit", (event) ->
    event.preventDefault() if window.$isDirty and !confirm("You haven't saved your changes.")
  )
  .on("click", "[data-object~=suppress-click]", -> false)
  .on("click", "[data-object~=remove-closest]", ->
    $(this).closest($(this).data("target")).remove()
    false
  )
  .on("click", "[data-object~=remove]", ->
    $($(this).data("target")).remove()
    false
  )
  .on("click", "[data-object~=modal-show]", ->
    $($(this).data("target")).modal({ dynamic: true })
    false
  )
  .on("click", "[data-object~=modal-hide]", ->
    $($(this).data("target")).modal("hide")
    false
  )
  .on("click", "[data-object~=submit]", ->
    $($(this).data("target")).submit()
    false
  )
  .on("click", "[data-object~=submit-and-disable]", ->
    disablerWithSpinner($(this))
    $($(this).data("target")).submit()
    false
  )
  .on("mouseenter", "[data-object~=hover-show]", ->
    return false unless document.documentElement.ontouchstart == undefined
    $("[data-object~=hover-show]").each( (index, element) ->
      $($(element).data("target")).hide()
    )
    $($(this).data("target")).show()
  )
  .on("mouseleave", "[data-object~=hover-show]", ->
    $($(this).data("target")).hide()
  )
  .keydown( (e) ->
    if $("#interactive_design_modal").is(":visible")
      hideInteractiveDesignModal()     if e.which == 27
    if e.which == 77 and not $("input, textarea, select, a").is(":focus")
      if $("#preview-mode").length == 1 and $("#edit-mode").length == 1 and $("#edit-mode").parent().hasClass("active")
        $("#preview-mode").click()
      else
        $("#edit-mode").click()
      e.preventDefault()
      return
  )
  .on("click", "[data-object~=settings-save]", ->
    window.$isDirty = false
    $($(this).data("target")).submit()
    false
  )
  .on("click", "[data-object~=toggle-visibility]", ->
    $($(this).data("target")).toggle()
    false
  )
  .on("change", ":input", ->
    if $("#isdirty").val() == "1"
      window.$isDirty = true
  )
  .on("click", "[data-object~=toggle-delete-buttons]", ->
    $($(this).data("target-show")).show()
    $($(this).data("target-hide")).hide()
    false
  )
  .on("wheel", "input[type=number]", ->
    $(this).blur()
  )

@themes = ->
  [
    "default"
    "night"
    "underwater"
    "love"
    "royal"
    "spring"
    "fall"
    "winter"
  ]

@changeTheme = (theme) ->
  body_classes = themes().map (theme) -> "theme-#{theme}-bg"
  menu_classes = themes().map (theme) -> "menu-#{theme}"
  footer_classes = themes().map (theme) -> "footer-#{theme}"
  $(".theme-bg").removeClass(body_classes.join(" ")).addClass("theme-#{theme}-bg")
  $(".navbar-custom").removeClass(menu_classes.join(" ")).addClass("menu-#{theme}")
  $(".footer-container").removeClass(footer_classes.join(" ")).addClass("footer-#{theme}")

@randomTheme = ->
  index = Math.floor(Math.random() * themes().length)
  changeTheme(themes()[index])

@themesReady = ->
  if $("[data-object~=random-theme]").length > 0
    timeout = setInterval( ->
      randomTheme()
    , 1000 * 1) # In one second

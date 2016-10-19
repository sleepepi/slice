# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# the compiled file.
#
# WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
# GO AFTER THE REQUIRES BELOW.
#
#= require jquery
#= require jquery_ujs
#= require bootstrap-sprockets
#= require turbolinks
#= require jquery-ui/droppable
#= require jquery-ui/sortable

# Compatibility

# Main JS initializer
#= require global

# External
#= require external/bootstrap-datepicker.js
#= require external/clipboard-1.5.12.src.js
#= require external/highcharts-4.2.3.src.js
#= require external/jquery.textcomplete-1.7.3.src.js
#= require external/typeahead-0.11.1.src.js

# Components

# Extensions
#= require extensions/datepicker
#= require extensions/tooltips

# Objects

#= require_tree .

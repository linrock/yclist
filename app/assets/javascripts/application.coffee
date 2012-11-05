#= require jquery
#= require jquery.tablesorter

$ ->

  $("table").tablesorter
    headers:
      4:
        sorter: false

  $("th").each (i,e) ->
    $e = $(e)
    $e.css(width: $e.width())

  $.each ["operating", "exited", "dead"], (i,status) ->

    toggleStatus = ->
      $e = $(".#{status}")
      if $(@).attr('checked') then $e.show() else $e.hide()

    $("#toggle-#{status}").on "change", toggleStatus


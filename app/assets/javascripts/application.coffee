#= require jquery.tablesorter

$ ->

  $("table").tablesorter
    headers:
      5:
        sorter: false

  $.each ["operating", "exited", "dead"], (i,status) ->

    toggleStatus = ->
      $e = $(".#{status}")
      if $(@).attr('checked') then $e.show() else $e.hide()
      $("#companies_count").text $("tbody > tr:visible").length

    $("#toggle-#{status}").on "change", toggleStatus


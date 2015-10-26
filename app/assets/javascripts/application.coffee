#= require jquery.tablesorter


$.tablesorter.addParser
  id: 'name'
  is: -> true
  format: (s) -> s.toLowerCase()
  type: 'text'

$.tablesorter.addParser
  id: 'cohort'
  is: -> true
  format: (s) ->
    "#{s[1..-1]}#{if s[0] == "W" then 0 else 1}"
  type: 'numeric'


$ ->

  $("table").tablesorter
    headers:
      1:
        sorter: 'name'
      3:
        sorter: 'cohort'
      5:
        sorter: false

  updateCompanyCount = ->
    $("#companies_count").text $("tbody > tr:visible").length

  $.each ["operating", "exited", "dead"], (i,status) ->

    toggleStatus = ->
      $e = $(".#{status}")
      if $(@).attr('checked') then $e.show() else $e.hide()
      updateCompanyCount()

    $("#toggle-#{status}").on "change", toggleStatus

  updateCompanyCount()


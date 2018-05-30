/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

const $ = require('jquery')
const tablesorter = require('tablesorter')

$.tablesorter.addParser({
  id: 'name',
  is: () => true,
  format: (s) => s.toLowerCase(),
  type: 'text',
})

$.tablesorter.addParser({
  id: 'cohort',
  is: () => true,
  format: (s) => {
    if (s[0] == "F") {
      return "165"
    } else {
      return `${s.slice(1)}${s[0] === "W" ? 0 : 9}`
    }
  },
  type: 'numeric',
});

$(() => {
  $('table').tablesorter({
    headers: {
      1: { sorter: 'name', },
      3: { sorter: 'cohort' },
      5: { sorter: false }
    }
  })

  updateCompanyCount = () => $("#companies_count").text($("tbody > tr:visible").length)

  $.each(["operating", "exited", "dead"], (i,status) => {
    function toggleStatus() {
      const $e = $(`.${status}`)
      if ($(this).is(":checked")) {
        $e.show()
      } else {
        $e.hide()
      }
      updateCompanyCount()
    }

    $(`#toggle-${status}`).on("change", toggleStatus)
  })

  updateCompanyCount()
})

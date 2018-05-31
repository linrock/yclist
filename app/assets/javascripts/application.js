//= require jquery.tablesorter

$.tablesorter.addParser({
  id: 'name',
  is: function() {
    return true;
  },
  format: function(name) {
    return name.toLowerCase();
  },
  type: 'text'
});

$.tablesorter.addParser({
  id: 'cohort',
  is: function() {
    return true;
  },
  format: function(cohort) {
    if (cohort[0] == 'F') {
      return '165'
    } else {
      return cohort.slice(1) + (cohort[0] === 'W' ? '0' : '9')
    }
  },
  type: 'numeric'
});

$(function() {
  function updateCompanyCount() {
    return $("#companies_count").text($("tbody > tr:visible").length);
  }

  $("table").tablesorter({
    headers: {
      1: { sorter: 'name'   },
      3: { sorter: 'cohort' },
      5: { sorter: false    }
    }
  });

  $.each(["operating", "exited", "dead"], function(i, status) {
    $('#toggle-' + status).on('change', function() {
      const $e = $('.' + status)
      if ($(this).is(':checked')) {
        $e.show();
      } else {
        $e.hide();
      }
      updateCompanyCount();
    });
  });

  updateCompanyCount();
});

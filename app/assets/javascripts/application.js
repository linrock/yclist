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
    $('#companies_count').text($('tbody > tr:visible').length);
  }

  function trackEvent(category, action, label) {
    if (window.ga) {
      window.ga('send', 'event', category, action, label);
    } else {
      console.log('event: ' + category + ', ' + action + ', ' + label);
    }
  }

  $('table').tablesorter({
    headers: {
      1: { sorter: 'name'   },
      3: { sorter: 'cohort' },
      5: { sorter: false    }
    }
  });

  $.each(['operating', 'exited', 'dead'], function(i, status) {
    $('#toggle-' + status).on('change', function() {
      const $e = $('.' + status)
      if ($(this).is(':checked')) {
        $e.show();
        trackEvent('show ' + status, 'on');
      } else {
        $e.hide();
        trackEvent('show ' + status, 'off');
      }
      updateCompanyCount();
    });
  });

  $('a').on('click', function() {
    trackEvent('link', 'click', $(this).attr('href'));
  });

  updateCompanyCount();
});

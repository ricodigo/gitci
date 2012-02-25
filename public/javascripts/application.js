$(function () {
  $('.nav-tabs a:first').tab('show')

  $('a[data-confirm]').click(function() {
    if(!confirm($(this).data('confirm'))) {
    return false;
    }
  });
})

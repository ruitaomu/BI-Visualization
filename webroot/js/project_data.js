(function() {
  $(function() {
    $('#data_container').on('click', '.pdata:first-child', function(e) {
      var $el = $(e.target).closest('.pdata');
      $clone = $el.clone().addClass('fade');
      $el.after($clone);
      $clone.find('select').select2();
      setTimeout(function() { $clone.addClass('in'); }, 250);
    });
  });
})();

$ ->
  $dataFile = $('#datafile_file')
  $progress = $('#progress .bar')
  $form = $('form.datafile')
  $submit = $('#datafile_submit_action input')
  enableSubmit = -> $submit.removeClass('disabled').removeAttr('disabled')
  disableSubmit = -> $submit.addClass('disabled').attr('disabled', true)

  if $dataFile.length == 1
    if $dataFile.val().length > 0
      $progress.css(width: '100%').html('100%')
      enableSubmit()
    else
      disableSubmit()

    $dataFile.change (e) ->
      file = e.target.files[0]
      rand = Math.floor(1000 * Math.random())
      $progress.css(width: '0').html('0%')
      progress = 0.2
      while (parseInt(progress) < 100)
        progress = (parseInt(progress) / 100) + 0.2
        progress = parseInt(progress * 100, 10) + '%'
        $progress.css(width: progress).html(progress)
      $('#datafile_video_id').val($dataFile.data('prefix').split('-')[1])
      enableSubmit()
      $form.submit()

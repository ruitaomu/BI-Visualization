#= require appsignal
#= require active_admin/base
#= require evaporatejs/evaporate
#= require videojs/dist/video-js/video.dev
#= require admin/videos
#= require admin/datafile
#= require jquery.throttledresize
#= require jquery-ui/autocomplete

$ ->
  $videoFile = $('#video_file')
  $progress = $('#progress .bar')
  $form = $('form.video')
  $submit = $('#video_submit_action input')
  $videoUrl = $('#video_url')
  enableSubmit = -> $submit.removeClass('disabled').removeAttr('disabled')
  disableSubmit = -> $submit.addClass('disabled').attr('disabled', true)

  if $videoFile.length == 1
    if $videoUrl.val().length > 0
      $progress.css(width: '100%').html('100%')
      enableSubmit()
    else
      disableSubmit()

    uploader = new Evaporate
      signerUrl: $videoFile.data('signer')
      aws_key: $videoFile.data('s3Key')
      aws_url: $videoFile.data('s3Host')
      bucket: $videoFile.data('s3Bucket')
    $videoFile.change (e) ->
      file = e.target.files[0]
      rand = Math.floor(1000 * Math.random())
      $progress.css(width: '0').html('0%')
      uploader.add
        name: "#{$videoFile.data('prefix')}/#{file.name}"
        file: file
        notSignedHeadersAtInitiate:
          'Cache-Control': 'max-age=3600'
        xAmzHeadersAtInitiate:
          'x-amz-acl': 'public-read'
        beforeSigner: (xhr) ->
          requestDate = (new Date()).toISOString()
          xhr.setRequestHeader 'Request-Header', requestDate
        progress: (progress) ->
          progress = parseInt(progress * 100, 10) + '%'
          $progress.css(width: progress).html(progress)
        complete: (xhr) ->
          $videoUrl.val xhr.responseURL.replace(/\?.+/, '')
          enableSubmit()
          $form.submit()

        $videoFile.val('')

  if $('input.autocomplete').length > 0
    availableTags = $('input.autocomplete').data('prepopulate')
    $('input.autocomplete').autocomplete(
      minLength: 1
      delay: 400
      html: true
      source: availableTags,
      messages:
        noResults: ''
        results: ''
    ).data( "ui-autocomplete" )._renderItem = ( ul, item ) ->
      return $( "<li>" )
        .data( "ui-autocomplete-item", item )
        .append( "<a>" + item.label + "</a>" )
        .appendTo( ul )

$ ->
  $('.video-js').each ->
    id = $(this).attr('id')
    videojs(id).on 'timeupdate', (e) ->
      time = e.target.currentTime

#= require active_admin/base
#= require jquery-file-upload/js/jquery.iframe-transport
#= require jquery-file-upload/js/jquery.fileupload
#= require jquery-file-upload/js/jquery.fileupload-process
#= require jquery-file-upload/js/jquery.fileupload-video

$ ->
  $('#video_file').fileupload
    progressall: (e, data) ->
      progress = parseInt(data.loaded / data.total * 100, 10) + '%'
      $('#progress .bar').css(width: progress).html(progress)

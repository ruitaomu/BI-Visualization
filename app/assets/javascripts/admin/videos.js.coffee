$ ->
  google.load 'visualization', '1.0', 'packages': [ 'timeline' ], callback: ->
    $video = $('.video-js')
    id = $video.attr('id')
    video = videojs(id)
    $chart = $('#tag-chart')

    table = new google.visualization.DataTable()
    table.addColumn 'string', 'Tag'
    table.addColumn 'number', 'Start'
    table.addColumn 'number', 'End'
    table.addRows $chart.data('rows')
    chartOptions = { tooltip: { trigger: 'none' } }
    chart = new google.visualization.Timeline($chart.get(0))
    chart.draw table, chartOptions

    tagButton = video.controlBar.addChild 'button',
      el: videojs.createEl('div', { className:  'tag-button vjs-control', 'role': 'button' })

    $tagButton = $video.find('.tag-button')
    tagStart = 0
    tagButton.on 'click', ->
      if $tagButton.hasClass('end')
        tagEnd = video.currentTime()
        table.addRows([['Eureka!', tagStart * 1000, tagEnd * 1000]])
        chart.draw table, tooltip: { trigger: 'selection' }
        $tagButton.removeClass('end')
      else
        tagStart = video.currentTime()
        $tagButton.addClass('end')

    formatSeconds = (secs) ->
      hours = parseInt(secs / 3600) % 24
      minutes = parseInt(secs / 60) % 60
      seconds = secs % 60
      hours = "0#{hours}" if hours < 10
      minutes = "0#{minutes}" if minutes < 10
      seconds = "0#{seconds}" if seconds < 10
      "#{hours}:#{minutes}:#{seconds}"

    extractSeconds = (string) ->
      p = string.split(':')
      seconds = parseInt(p[0]) * 60 * 60
      seconds += parseInt(p[1]) * 60
      seconds += parseInt(p[2])
      seconds

    google.visualization.events.addListener chart, 'select', ->
      row = chart.getSelection()[0].row
      label = table.Lf[row].c[0].v
      start = table.Lf[row].c[1].v
      end = table.Lf[row].c[2].v
      $dialog.data('row', row)
      $dialog.find('.field.tag input').val label
      $dialog.find('.field.duration input').val formatSeconds((end - start) / 1000)
      $inputStart.val formatSeconds(start / 1000)
      $inputEnd.val formatSeconds(end / 1000)
      $dialog.dialog('open')
      $dialog.find('.field.start input').focus()

    updateRow = ->
      row = $dialog.data('row')
      start = extractSeconds($inputStart.val()) * 1000
      end = extractSeconds($inputEnd.val()) * 1000
      table.Lf[row].c[1].v = start
      table.Lf[row].c[2].v = end
      chart.draw table, chartOptions

    $dialog = $('#dialog').dialog
      autoOpen: false
      closeText: 'x'

    $inputStart = $dialog.find('.field.start input')
    $inputEnd = $dialog.find('.field.end input')

    $dialog.find('button.update').click ->
      updateRow()
    $dialog.find('button.delete').click ->
      table.removeRow($dialog.data('row'))
      chart.draw table, chartOptions
      $dialog.dialog 'close'
    $dialog.find('.field.start input, .field.end input').keydown (e) ->
      # Tabbing inside the dialog makes the window scroll so disable that
      if e.which == 9
        if $inputStart.is(':focus')
          $inputEnd.focus()
        else if $inputEnd.is(':focus')
          $inputStart.focus()
        e.preventDefault()
    $dialog.find('.field.start input, .field.end input').keypress (e) ->
      if e.which == 13
        updateRow()
        $dialog.dialog 'close'

    video.on 'timeupdate', (e) ->
      time = video.currentTime()

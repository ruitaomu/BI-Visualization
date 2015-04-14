$ ->
  google.load 'visualization', '1.0', 'packages': [ 'timeline' ], callback: ->
    $video = $('.video-js')
    id = $video.attr('id')
    video = videojs(id)
    $chart = $('#tag-chart')

    table = new google.visualization.DataTable()
    table.addColumn type: 'string', id: 'Tag'
    table.addColumn type: 'string', id: 'ID', role: 'annotation'
    table.addColumn type: 'number', id: 'Start'
    table.addColumn type: 'number', id: 'End'
    chartOptions = { tooltip: { trigger: 'none' }, allowHtml: true }
    chart = new google.visualization.Timeline($chart.get(0))
    if ($chart.data('rows') || []).length > 0
      table.addRows $chart.data('rows')
      formatter = new google.visualization.PatternFormat('whaaat')
      formatter.format(table, [1])
      chart.draw table, chartOptions

    tagButton = video.controlBar.addChild 'button',
      el: videojs.createEl('div', { className:  'tag-button vjs-control', 'role': 'button' })

    $tagButton = $video.find('.tag-button')
    tagStart = 0
    tagButton.on 'click', ->
      if $tagButton.hasClass('end')
        addRow tagStart, video.currentTime(0)
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
      seconds += parseFloat(p[2])
      seconds

    dialogForRow = (row) ->
      label = table.Lf[row].c[0].v
      id = table.Lf[row].c[1].v
      start = table.Lf[row].c[2].v
      end = table.Lf[row].c[3].v
      $dialog.data('row', row).data('tag-id', id)
      $selectTag.val label
      $dialog.find('.field.duration input').val formatSeconds((end - start) / 1000)
      $inputStart.val formatSeconds(start / 1000)
      $inputEnd.val formatSeconds(end / 1000)
      openDialog()
      $dialog.find('.field.start input').focus()

    google.visualization.events.addListener chart, 'select', ->
      row = chart.getSelection()[0].row
      dialogForRow row

    addRow = (tagStart, tagEnd) ->
      $dialog.data 'row', table.Lf.length # New
      table.addRows [[ '', 'new', tagStart * 1000, tagEnd * 1000 ]]
      dialogForRow $dialog.data('row')
      chart.draw table, chartOptions

    updateRow = ->
      row = $dialog.data('row')
      start = extractSeconds($inputStart.val()) * 1000
      end = extractSeconds($inputEnd.val()) * 1000
      tag = $inputTag.val()
      if tag.length > 0
        table.Lf[row].c[0].v = tag
        $selectTag.append "<option value='#{tag}'>#{tag}</option>"
        $selectTag.val tag
        $inputTag.val ''
        autosizeDialog()
      else
        table.Lf[row].c[0].v = $selectTag.val()
      table.Lf[row].c[2].v = start
      table.Lf[row].c[3].v = end
      chart.draw table, chartOptions

    removeRow = ->
      row = $dialog.data('row')
      id = table.Lf[row].c[1].v
      deletedTags.push id if id != 'new'
      table.removeRow(row)
      chart.draw table, chartOptions

    $dialog = $('#dialog').dialog
      autoOpen: false
      closeText: 'x'

    autosizeDialog = ->
      width = $selectTag.width() + 230
      $dialog.dialog 'option', 'width', width

    openDialog = ->
      $dialog.dialog 'open', autosizeDialog

    $inputStart = $dialog.find('.field.start input')
    $inputEnd = $dialog.find('.field.end input')
    $fieldTag = $dialog.find('.field.tag')
    $selectTag = $dialog.find('.field.tag select')
    $inputTag = $dialog.find('.field.tag input')

    deletedTags = []

    $dialog.find('button.update').click ->
      updateRow()
    $dialog.find('button.delete').click ->
      removeRow()
      $dialog.dialog 'close'

    $controls = $dialog.find('[tabindex]')
    $controls.keydown (e) ->
      # Tabbing inside the dialog makes the window scroll so disable that
      if e.which == 9
        tabindex = parseInt($(this).attr('tabindex'))
        $next = $dialog.find("[tabindex=#{tabindex + 1}]")
        $prev = $dialog.find("[tabindex=#{tabindex - 1}]")
        $first = $dialog.find("[tabindex=1]")
        $last = $dialog.find("[tabindex=#{$controls.length}]")
        if e.shiftKey
          if $prev.length > 0 then $prev.focus() else $last.focus()
        else
          if $next.length > 0 then $next.focus() else $first.focus()
        e.preventDefault()
    $dialog.find('.field.start input, .field.end input').keypress (e) ->
      if e.which == 13
        updateRow()
        $dialog.dialog 'close'

    video.on 'timeupdate', (e) ->
      time = video.currentTime()

    $form = $('form.update-tags')
    $('button', $form).click (e) ->
      e.preventDefault()
      $('input.h', $form).remove()
      prefix = "<input class='h' type='hidden' name='video[tags_attributes]"
      for tag in table.Lf
        id = tag.c[1].v
        if id == 'new'
          id = new Date().getTime().toString()
        else
          $form.append "#{prefix}[#{id}][id]]' value='#{id}'>"
        $form.append "#{prefix}[#{id}][name]]' value='#{tag.c[0].v}'>"
        $form.append "#{prefix}[#{id}][starts]]' value='#{tag.c[2].v}'>"
        $form.append "#{prefix}[#{id}][ends]]' value='#{tag.c[3].v}'>"
      for deleted in deletedTags
        $form.append "#{prefix}[#{deleted}][id]]' value='#{deleted}'>"
        $form.append "#{prefix}[#{deleted}][_destroy]]' value='1'>"

      $.ajax
        type: 'PATCH'
        url: $form.attr('action')
        data: $form.serialize()

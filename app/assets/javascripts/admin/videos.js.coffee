$ ->
  google.load 'visualization', '1.0', 'packages': [ 'timeline' ], callback: ->
    loadTagChart = ->
      $chart = $('#tag-chart')

      table = new google.visualization.DataTable()
      table.addColumn type: 'string', id: 'Tag'
      table.addColumn type: 'string', id: 'ID', role: 'annotation'
      table.addColumn type: 'number', id: 'Start'
      table.addColumn type: 'number', id: 'End'
      table.addRows [[ 'Total', '', 0, video.duration() * 1000 ]]
      chartOptions = {
        hAxis: { format: 'mm:ss' }
      }
      chart = new google.visualization.Timeline($chart.get(0))

      $tracker = $("<div class='tracking-line'></div>")
      $guide = $("<div style='position:absolute;pointer-events:none;overflow:hidden'></div>")
      $firstRowOverlay = $("<div style='position:absolute'></div>")

      drawChart = ->
        chart.draw table, chartOptions
        leftTop = $('svg > g > path:first', $chart).get(0).getBoundingClientRect()
        right = $('svg > g:first > rect:last', $chart).get(0).getBoundingClientRect()
        offsetY = document.body.scrollTop
        offsetX = document.body.scrollLeft
        rect = {
          lt: [ leftTop.left + offsetX, leftTop.top + offsetY ]
          rb: [ right.right + offsetX, right.bottom + offsetY ]
        }
        # Guidance div
        $guide
          .offset top: rect.lt[1], left: rect.lt[0]
          .width rect.rb[0] - rect.lt[0]
          .height rect.rb[1] - rect.lt[1]
          .appendTo 'body'
          .append $tracker
        # This will be on top of the first row so the user
        # is not able to click on it (the "Total" row)
        $firstRowOverlay
          .offset top: rect.lt[1], left: rect.lt[0]
          .width rect.rb[0] - rect.lt[0]
          .height leftTop.bottom - leftTop.top
          .appendTo 'body'

        chartHeight = $('svg > g:first', $chart).get(0).getBoundingClientRect().height
        $chart.css height: "#{chartHeight + 30}px"

      if ($chart.data('rows') || []).length > 0
        table.addRows $chart.data('rows')
        formatter = new google.visualization.PatternFormat('whaaat')
        formatter.format(table, [1])
        drawChart()

      tagButton = video.controlBar.addChild 'button',
        el: videojs.createEl('div', { className:  'tag-button vjs-control', 'role': 'button' })

      $tagButton = $video.find('.tag-button')
      tagStart = 0
      tagButton.on 'click', ->
        if $tagButton.hasClass('end')
          addRow tagStart, video.currentTime()
          $tagButton.removeClass('end')
        else
          tagStart = video.currentTime()
          $tagButton.addClass('end')

      formatSeconds = (secs) ->
        hours = parseInt(secs / 3600) % 24
        minutes = parseInt(secs / 60) % 60
        seconds = Math.round((secs % 60) * 1000) / 1000
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
        if row == 0
          $dialog.dialog 'close'
        else
          dialogForRow row

      addRow = (tagStart, tagEnd) ->
        $dialog.data 'row', table.Lf.length # New
        table.addRows [[ '', 'new', tagStart * 1000, tagEnd * 1000 ]]
        dialogForRow $dialog.data('row')
        drawChart()

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
        drawChart()

      removeRow = ->
        row = $dialog.data('row')
        id = table.Lf[row].c[1].v
        deletedTags.push id if id != 'new'
        table.removeRow(row)
        drawChart()

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
      $controls.keypress (e) ->
        if e.which == 13
          updateRow()
          $dialog.dialog 'close'

      video.on 'timeupdate', (e) ->
        time = video.currentTime()
        secsPerPixel = $guide.width() / video.duration()
        $tracker.offset left: $guide.offset().left + time * secsPerPixel

      $form = $('form.update-tags')
      $btnSaveTags = $('button', $form)
      $btnSaveTags.click (e) ->
        e.preventDefault()
        $('input.h', $form).remove()
        prefix = "<input class='h' type='hidden' name='video[tags_attributes]"
        for tag, idx in table.Lf
          if idx > 0
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

        $btnSaveTags.addClass 'processing'

        $.ajax
          type: 'PATCH'
          url: $form.attr('action')
          data: $form.serialize()
          success: ->
            $btnSaveTags.removeClass 'processing'
            $btnSaveTags.addClass 'done'
            setTimeout ->
              $btnSaveTags.removeClass 'done'
            , 1000
          error: ->
            $btnSaveTags.removeClass 'processing'
            alert 'There was an unexpected error, please try again later.'

    $video = $('.video-js')
    id = $video.attr('id')
    video = videojs(id)
    video.on 'loadedmetadata', (e) ->
      loadTagChart()

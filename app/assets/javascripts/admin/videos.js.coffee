$ ->
  google.load 'visualization', '1.0', 'packages': [ 'corechart' ], callback: ->
    $loaded = false
    $datafileData = {rows: [], columns: [], title: [], movingAverage: ''}
    $datafileTracker = []
    $datafileGuide = []

    loadDatafileChart = (id, index) ->
      $datafileChart = $("#datafile-chart-#{id}")
      table = new google.visualization.DataTable()
      table.addColumn 'number', $datafileData.columns[2]
      table.addColumn 'number', $datafileData.columns[1]
      table.addColumn 'number', $datafileData.movingAverage+" per. Mov. Avg. "+$datafileData.columns[0]
      table.addColumn 'number', 'UB Std Dev'
      table.addColumn 'number', 'LB Std Dev'

      changeFormat = (secs) ->
        secs = secs.replace(',','')
        minutes = parseInt(secs / 60) % 60
        seconds = Math.round((secs % 60) * 1000) / 1000
        minutes = "0#{minutes}" if minutes < 10
        seconds = "0#{seconds}" if seconds < 10
        return "#{minutes}:#{seconds}"

      if ($datafileData.rows || []).length > 0
        table.addRows $datafileData.rows
        formatter = new google.visualization.PatternFormat('whaaat')
        formatter.format(table, [1])
        durationFormatter = new google.visualization.NumberFormat(decimalSymbol: ':', fractionDigits: 2)
        durationFormatter.format(table, 0)
        $axis0Range = table.getColumnRange(2)
        $axis1Range = table.getColumnRange(1)

      chartOptions = {
        width: $('body').width() - 60
        height: 500
        chartArea: {width: '88%', left: '4%', top: '10%'}
        title: $datafileData.title[0]
        curveType: 'function'
        legend: "bottom"
        seriesType: "line"
        titlePosition: 'in'
        #hAxis: {format: 'mm:ss'}
        series: [
          {targetAxisIndex: 1}
          {targetAxisIndex: 0}
          {targetAxisIndex: 1,visibleInLegend: false, lineWidth: 4}
          {targetAxisIndex: 1,visibleInLegend: false, lineWidth: 4}
        ]
        vAxes: [
          {
            title: $datafileData.columns[0]
            titleTextStyle: {color: "blue"}
            format: '0.0'
            minValue: $axis0Range.max * -1
            maxValue: $axis0Range.min * -1
            gridlines:{count:5}
            slantedText:true
            slantedTextAngle:90
          }
          {
            title: $datafileData.columns[1]
            titleTextStyle: {color: "red"}
            format: '0.00E00'
            minValue: $axis1Range.max * -1
            maxValue: $axis1Range.min * -1
            gridlines:{count:9}
            slantedText:true
            slantedTextAngle:90
          }
        ]
        colors:['red','blue', 'yellow', 'green']
      }
      dataChart = new google.visualization.LineChart($datafileChart.get(0))
      $datafileTracker[index] = $("<div class='tracking-line'></div>")
      $datafileGuide[index] = $("<div style='position:absolute;pointer-events:none;overflow:hidden'></div>")

      drawChart = ->
        # Draw first to get new height
        dataChart.draw table, chartOptions
        chartHeight = 480; ##$('svg:last > g:first', $datafileChart).get(0).getBoundingClientRect().height
        $datafileChart.css height: "#{chartHeight + 60}px"
        dataChart.draw table, chartOptions
        $datafileChart.css height: "#{chartHeight + 30}px"

        leftTop = $($('svg:last > g', $datafileChart)[1]).find(' > rect:last').get(0).getBoundingClientRect()
        right = $($('svg:last > g', $datafileChart)[1]).find(' > rect:last').get(0).getBoundingClientRect()
        offsetY = document.body.scrollTop
        offsetX = document.body.scrollLeft
        rect = {
          lt: [ leftTop.left + offsetX, leftTop.top + offsetY ]
          rb: [ right.right + offsetX, right.bottom + offsetY ]
        }
        # Guidance div
        $datafileGuide[index]
          .offset top: rect.lt[1], left: rect.lt[0]
          .width rect.rb[0] - rect.lt[0]
          .height rect.rb[1] - rect.lt[1]
          .appendTo 'body'
          .append $datafileTracker[index]

        xAxisTextArray = $($('svg:last > g', $datafileChart)[1]).find(' > g:last').find("text[text-anchor='middle']")
        $.each xAxisTextArray, ( index, value ) ->
          $(value).text(changeFormat($(value).text()))

      drawChart() if ($datafileData.rows || []).length > 0

    loadAllCharts = ->
      $('.datafile-chart').each ( index ) ->
        id = $(this).attr('id').split('-')[2]
        videoId = $(this).data('video-id')
        $datafileTracker[index].remove() if $datafileTracker[index]
        $datafileGuide[index].remove()   if $datafileGuide[index]
        $.ajax
          type: 'GET'
          contentType: 'application/json; charset=utf-8'
          url: '/videos/'+videoId+'/datafiles/'+id+'/chart_data'
          dataType: 'json'
          async: false
          success: (data) ->
            $datafileData = {rows: data.rows, columns: data.columns, title: data.title, movingAverage: data.movingAverage, threshold: data.threshold, stdev: data.standardDeviation}
            loadDatafileChart(id, index) if $("#datafile-chart-#{id}").length > 0
          error: (result) ->
            alert("Error loading chart")

      $loaded = true

    $video = $('.video-js')
    if $video.length > 0
      id = $video.attr('id')
      video = videojs(id)
      video.on 'loadedmetadata', (e) ->
        loadAllCharts()
      video.on 'timeupdate', (e) ->
        unless $loaded
          loadAllCharts()
        time = video.currentTime()
        # For datafile chart
        $('.datafile-chart').each ( index ) ->
          secsPerPixelDatafile = $datafileGuide[index].width() / video.duration()
          $datafileTracker[index].offset left: $datafileGuide[index].offset().left + time * secsPerPixelDatafile

      $(window).on "throttledresize", (event) ->
        loadAllCharts()
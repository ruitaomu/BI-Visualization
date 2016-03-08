(function() {
  var charts = {},
      nextColor = 5,
      lastCrosshairP = 0,
      selectedTags = {},
      cache = {data: {}, ma: {}};

  function displayTags() {
    var $tags = $('#tags');
    var $legend = $('#legend');
    var t_s, t_e;
    //var max_ts = tags.max_ts * 1 - tags.min_ts * 1;
    var max_ts = tags.max_ts * 1;
    var tags_color = {};
    for (var tag in tags.tag) {
      tags_color[tag] = randomColor(true);

      for (var i = 0; i < tags.tag[tag].length; i++) {
        //t_s = tags.tag[tag][i].t_s * 1 - tags.min_ts * 1;
        //t_e = tags.tag[tag][i].t_e * 1 - tags.min_ts * 1;
        t_s = tags.tag[tag][i].t_s * 1;
        t_e = tags.tag[tag][i].t_e * 1;
        
        var $tag = $('<div></div>').attr('data-tag', tag).addClass('tag tag-' + tag).css({
          'left': (t_s / max_ts * 100) + '%',
          'width': ((t_e - t_s) / max_ts * 100) + '%',
          'background-color': 'rgba(' + tags_color[tag] + ',1)'
        }).hover(
          function(e) {
            var $el = $(e.target).closest('.tag');
            var $tags = $el.closest('.tags');

            $tags.children('.active').removeClass('active');
            $tags.children('.tag-' + $el.attr('data-tag')).addClass('active');
	    $el.addClass('hover');
          },
          function(e) {
            var $el = $(e.target).closest('.tag');
            var $tags = $el.closest('.tags');

            $tags.children('.active').removeClass('active');
	    $el.removeClass('hover');
          }
        ).click(function(e) {
          var $el = $(e.target).closest('.tag'),
	      tag = $el.attr('data-tag');

          if ($el.is('.selected')) {
	    unselectTag(tag);
          }
          else {
	    selectTag(tag);
          }
        }).appendTo($tags);

        $('<div class="t_s"><span>' + sec2time(t_s / 1000) + '</span></div>').appendTo($tag);
        $('<div class="t_e"><span>' + sec2time(t_e / 1000) + '</span></div>').appendTo($tag);
      }

      // legend:
      $('<li>' + tag + '</li>').attr('data-tag', tag).css({
        'border-color': 'rgb(' + tags_color[tag] + ')'
      }).appendTo($legend);
    }

    $legend.on('click', function(e) {
      toggleTag($(e.target).closest('li'));
    });
  }

  window.displayTags = displayTags;

  function selectTag(tag) {
    var $tags = $('#tags');

    if (window.tagAnalysis) {
      $tags.find('.selected').removeClass('selected');
      selectedTags = {};
      window.selectedTag = tag;
    }

    $tags.find('.tag-' + tag).addClass('selected');
    selectedTags[tag] = true;

    refreshCharts();
  }

  function unselectTag(tag) {
    var $tags = $('#tags');

    $tags.find('.tag-' + tag).removeClass('selected');
    delete selectedTags[tag];

    if (window.tagAnalysis) {
      window.selectedTag = null;
    }
    
    refreshCharts();
  }

  function toggleTag($li) {
    var tag = $li.attr('data-tag');

    if ($li.hasClass('is-hidden')) {
      // show:
      $('#tags').find('.tag-' + tag).show();
      $li.removeClass('is-hidden');
    }
    else {
      // hide:
      $('#tags').find('.tag-' + tag).hide();
      $li.addClass('is-hidden');
      unselectTag(tag);
    }
  }

  // get the list of data series present on this project/tester:
  function getPresentSeries() {
    var result = [];

    if (index_attr && index_attr.length) {
      for (var i = 0; i < index_attr.length; i++) {
        var attr = index_attr[i].toLowerCase();

        if (!index_data || !index_data[attr]) {
          continue;
        }

        result.push({
          id: attr,
          text: index_attr[i]
        });
      }
    }

    return result;
  }

  function getAttrLabel(attr) {
    if (index_attr && index_attr.length) {
      for (var i = 0; i < index_attr.length; i++) {
        if (index_attr[i].toLowerCase() == attr) {
          return index_attr[i];
        }
      }
    }
  }

  function displayCharts(max) {
    if (index_attr && index_attr.length) {
      for (var i = 0; i < index_attr.length; i++) {
        var attr = index_attr[i].toLowerCase();

        if (!index_data || !index_data[attr]) {
          continue;
        }

        charts[attr] = {
          attr: attr,
          avg: true,
          avg2: false,

          $el: $([
            '<div class="chart-container">',
            '<label>', index_attr[i], '</label>',
            '<div class="chart"></div>',
            '<div class="row controls">',
            '<div class="col-lg-6" style="padding-left: 95px;">',
            '<input type="hidden" value="', attr, '" class="series" data-attr="', attr, '">',
            '<input type="hidden" class="ma" placeholder="Moving Average" data-attr="', attr, '">',
            '<label class="checkbox-inline"><input type="checkbox" checked data-attr="', attr, '"> Show average</label>',
            '</div>',
            '<div class="col-lg-6" style="text-align: right; padding-right: 30px;">',
            '<input type="hidden" class="series" placeholder="Y2 Data" data-y2="true" data-attr="', attr, '">',
            '<input type="hidden" class="ma" placeholder="Y2 Moving Average" data-y2="true" data-attr="', attr, '">',
            '<label class="checkbox-inline"><input type="checkbox" data-y2="true" data-attr="', attr, '"> Show average</label>',
            '</div>',
            '</div>',
            '&nbsp;',
            '</div>',
            '</div>'
          ].join('')).appendTo('#charts')
        };

        charts[attr].$el.find('input.series').select2({
          minimumResultsForSearch: 10,
          data: getPresentSeries(),
          allowClear: true
        }).change(function(e) {
          var $el = $(this),
              attr = $el.attr('data-attr'),
              y2 = $el.attr('data-y2');

          charts[attr]['attr' + (y2 ? '2' : '')] = $el.val();
          displayChart(attr);
          
          zoom();
        });

        charts[attr].$el.find('input.ma').select2({
          minimumResultsForSearch: 10,
          allowClear: true,
          data: ma_attr
        }).change(function(e) {
          var $el = $(this),
              attr = $el.attr('data-attr'),
              y2 = $el.attr('data-y2');

          charts[attr]['ma' + (y2 ? '2' : '')] = $el.val();
          displayChart(attr);

          zoom();
        });

        charts[attr].$el.find('input[type="checkbox"]').click(function(e) {
          var $el = $(this),
              attr = $el.attr('data-attr'),
              y2 = $el.attr('data-y2');

          charts[attr]['avg' + (y2 ? '2' : '')] = $el.prop('checked');
          displayChart(attr);

          zoom();
        });

        displayChart(attr);

        if (window.tagAnalysis) {
          return;
        }
      }
    }
  }

  window.displayCharts = displayCharts;

  function displayChart(attr) {
    var series = [];

    var label = getAttrLabel(charts[attr].attr);
    if (charts[attr].attr2) {
      label += ' vs. ' + getAttrLabel(charts[attr].attr2);
    }
    charts[attr].$el.children('label').text(label);

    var $chart = charts[attr].$el.find('.chart');

    charts[attr].plot = $.plot($chart,
      getSeries(attr),
      {
        series: {
          shadowSize: 0
        },
        xaxis: {
          tickFormatter: function(val, axis) {
            return sec2time(val * 400 / 1000);
          }
        },
        yaxis: {
          labelWidth: 80
        },
        yaxes: [
          {},
          {
            position: 'right',
            labelWidth: 80
          }
        ],
        selection: {
          mode: 'x'
        },
        crosshair: {
          mode: 'x'
        },
	legend: {
	  show: true,
	  noColumns: 6 
	}
      }
    );

    // add zoom-out button:
    var $btn = $('<button>Zoom Out</button>').addClass('btn btn-danger btn-xs btn-zoom-out').appendTo($chart).click(function(e) {
      zoom();
    });

    $chart.bind('plotselected', function(e, ranges) {
      zoom(ranges);
    });

    crosshair();
  }

  function refreshCharts() {
    if (window.tagAnalysis) {
      if (window.selectedTag) {
        $('#charts').show();
        $('#no-tag-selected').hide();
      }
      else {
        $('#charts').hide();
        $('#no-tag-selected').show();
      }
    }

    for (var attr in charts) {
      displayChart(attr);
    }
  }

  function crosshair(p) {
    if (p === undefined) {
      p = lastCrosshairP;
    }

    if (p === undefined) {
      return;
    }

    lastCrosshairP = p;

    for (var attr in charts) {
      var plot = charts[attr].plot;
      var n = index_data[attr].series.length - 1;
      plot.lockCrosshair({ x: n * p/100 });
    }
  }

  function zoom(ranges) {
    for (var attr in charts) {
      var plot = charts[attr].plot;
      $.each(plot.getXAxes(), function(_, axis) {
        if (ranges) {
          axis.options.min = ranges.xaxis.from;
          axis.options.max = ranges.xaxis.to;
        }
        else {
          axis.options.min = axis.datamin;
          axis.options.max = axis.datamax;
        }
      });

      plot.setupGrid();
      plot.draw();
      plot.clearSelection();
    }

    crosshair();
    if (ranges) {
      $('.btn-zoom-out').show();
    }
    else {
      $('.btn-zoom-out').hide();
    }
  }

  function getSeries(attr) {
    if (window.tagAnalysis && !window.selectedTag) {
      return [];
    }

    if (typeof(charts[attr].color) == 'undefined') {
      charts[attr].color = nextColor;
      nextColor += 2;
    }

    var series = [];

    // data:
    var data = getFlotData(charts[attr].attr);
    series.push({
      label: '&nbsp;' + getAttrLabel(charts[attr].attr) + '&nbsp;&nbsp;&nbsp;',
      color: charts[attr].color,
      data: data
    });

    if (charts[attr].avg) {
      if (window.tagAnalysis) {
        var avg = 0;
        for (var i = 0; i < data.length; i++) {
          avg += data[i][1];
        }
        avg /= data.length;

        series.push({
          label: '&nbsp;' + getAttrLabel(charts[attr].attr) + ' Avg&nbsp;&nbsp;&nbsp;',
          color: 2,
          data: [[0, avg], [data.length -1, avg]]
        });
      }
      else {
        var avg = index_data[charts[attr].attr].avg;
        series.push({
          label: '&nbsp;' + getAttrLabel(charts[attr].attr) + ' Avg&nbsp;&nbsp;&nbsp;',
          color: 2,
          data: [[0, avg], [index_data[charts[attr].attr].series.length, avg]]
        });
      }
    }

    // moving average:
    if (charts[attr].ma) {
      series.push({
        label: '&nbsp;' + getAttrLabel(charts[attr].attr) + ' MA-' + charts[attr].ma + '&nbsp;&nbsp;&nbsp;',
        color: 1,
        data: getMAData(charts[attr].attr, charts[attr].ma)
      });
    }

    if (charts[attr].attr2) {
      // data:
      var data2 = getFlotData(charts[attr].attr2);

      series.push({
        label: '&nbsp;' + getAttrLabel(charts[attr].attr2) + '&nbsp;&nbsp;&nbsp;',
        color: charts[attr].color + 1,
        data: data2,
        yaxis: 2
      });
  
      if (charts[attr].avg2) {
        if (window.tagAnalysis) {
          var avg = 0;
          for (var i = 0; i < data2.length; i++) {
            avg += data2[i][1];
          }
          avg /= data2.length;
  
          series.push({
	    label: '&nbsp;' + getAttrLabel(charts[attr].attr2) + ' Avg&nbsp;&nbsp;&nbsp;',
            color: 3,
            data: [[0, avg], [data2.length -1, avg]],
            yaxis: 2
          });
        }
        else {
          var avg = index_data[charts[attr].attr2].avg;
          series.push({
	    label: '&nbsp;' + getAttrLabel(charts[attr].attr2) + ' Avg&nbsp;&nbsp;&nbsp;',
            color: 3,
            data: [[0, avg], [index_data[charts[attr].attr2].series.length, avg]],
            yaxis: 2
          });
        }
      }

      // moving average:
      if (charts[attr].ma2) {
        series.push({
	  label: '&nbsp;' + getAttrLabel(charts[attr].attr2) + ' MA-' + charts[attr].ma2 + '&nbsp;&nbsp;&nbsp;',
          color: 4,
          data: getMAData(charts[attr].attr2, charts[attr].ma2),
          yaxis: 2
        });
      }
    }

    return series;
  }

  // determine the intervals we need to "nullify" from the data, based on what
  // tags are selected:
  function getIntervals(attr, include) {
    var selTags = [];
    for (var tag in selectedTags) {
      selTags.push(tag);
    }

    if (!selTags.length) {
      return null;
    }

    var intervals = [];
    for (var i = 0; i < selTags.length; i++) {
      for (var j = 0; j < tags.tag[selTags[i]].length; j++) {
        var seq = tags.tag[selTags[i]][j];
        intervals.push({
          s: Math.max(0, Math.min(Math.round(seq.t_s / 400), index_data[attr].series.length - 1)),
          e: Math.max(0, Math.min(Math.round(seq.t_e / 400), index_data[attr].series.length - 1))
        });
      }
    }

    intervals.sort(function(a, b) {
      return a.s - b.s;
    });

    if (include) {
      return intervals;
    }

    var result = [];
    var start = 0;
    for (var i = 0; i < intervals.length; i++) {
      if (start < intervals[i].s) {
        result.push({s: start, e: intervals[i].s});
      }
      if (start < intervals[i].e) {
        start = intervals[i].e;
      }
    }

    if (start < index_data[attr].series.length - 1) {
      result.push({s: start, e: index_data[attr].series.length - 1});
    }

    return result;
  }

  function getFlotData(attr) {
    var data = [];

    if (window.tagAnalysis) {
      var intervals = getIntervals(attr, true);
      if (intervals) {
        var k, counts = [];
        for (var i = 0; i < intervals.length; i++) {
          k = 0;
          for (j = intervals[i].s; j < intervals[i].e; j++) {
            if (!data[k]) data[k] = [k, 0];
            if (!counts[k]) counts[k] = 0;

            data[k][1] += index_data[attr].series[j];
            counts[k]++;
            k++;
          }
        }

        for (var i = 0; i < data.length; i++) {
          data[i][1] /= counts[i];
        }
      }
    }
    else {
      for (var i = 0; i < index_data[attr].series.length; i++) {
        data.push([i, index_data[attr].series[i]]);
      }

      var intervals = getIntervals(attr);
      if (intervals) {
        for (var i = 0; i < intervals.length; i++) {
          for (j = intervals[i].s; j < intervals[i].e; j++) {
            data[j][1] = null;
          }
        }
      }
    }

    return data;
  }

  function getMAData(attr, period) {
    var data = [];
    var period = Math.round(period * 1000 / 400);

    if (period == 0) {
      return [];
    }

    var sourceData = getFlotData(attr);

    if (period == 1) {
      return sourceData;
      //return getFlotData(attr);
    }

    var s = 0, k = 0;
    /*for (var i = 0; i < index_data[attr].series.length; i++) {
      s += index_data[attr].series[i];
      if (i >= period - 1) {
        data.push([i, s / period]);
        s -= index_data[attr].series[i - period + 1];
      }
      else {
        data.push([i, null]);
      }
    }*/
    for (var i = 0; i < sourceData.length; i++) {
      if (sourceData[i][1] === null) {
        s = k = 0;
      }
      else {
        s += sourceData[i][1];
        k++;
        if (k >= period) {
          data.push([i, s / period]);
          s -= sourceData[i - period + 1][1];
        }
        else {
          data.push([i, null]);
        }
      }
    }

    /*var intervals = getIntervals(attr);
    if (intervals) {
      for (var i = 0; i < intervals.length; i++) {
        for (j = intervals[i].s; j < intervals[i].e; j++) {
          data[j][1] = null;
        }
      }
      }*/

    return data;
  }

  function randomColor(rgb) {
    if (rgb) {
      return [
        Math.floor(Math.random() * 256),
        Math.floor(Math.random() * 256),
        Math.floor(Math.random() * 256)
      ];
    }
    else {
      return '#'+(Math.random()*0xFFFFFF<<0).toString(16);
    }
  }

  function updateVideoProgress(p, t) {
    $('.video-marker').css({
      'left': p + '%'
    });

    crosshair(p);

    $('.video-time').text(sec2time(t));
  }

  window.updateVideoProgress = updateVideoProgress;

  function sec2time(sec) {
    var h, m, s, ms, time = [];

    ms = sec + '';
    if (ms.indexOf('.') > 0) {
      ms = ms.substr(ms.indexOf('.'));
    }
    
    if (h = Math.floor(sec / 3600)) {
      time.push(h);
    }
    
    m = Math.floor((sec % 3600) / 60);
    time.push(m < 10 ? '0' + m : m);

    s = sec % 60;
    s = ((s < 10 ? '0' + s : s) + '').substr(0, 6);
    time.push(s);

    return time.join(':');
  }

})();

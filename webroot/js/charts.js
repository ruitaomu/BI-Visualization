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
        
        var $tag = $('<div></div>').attr('data-tag', tag).addClass('tag-' + tag).css({
          'left': (t_s / max_ts * 100) + '%',
          'width': ((t_e - t_s) / max_ts * 100) + '%',
          'background-color': 'rgba(' + tags_color[tag] + ',1)'
        }).hover(
          function(e) {
            var $el = $(e.target);
            var $tags = $el.closest('.tags');

            $tags.children('.active').removeClass('active');
            $tags.children('.tag-' + $el.attr('data-tag')).addClass('active');
          },
          function(e) {
            var $el = $(e.target);
            var $tags = $el.closest('.tags');

            $tags.children('.active').removeClass('active');
          }
        ).click(function(e) {
          var $el = $(e.target),
              $tags = $el.closest('.tags'),
              tag = $el.attr('data-tag');

          if ($el.is('.selected')) {
            $tags.find('.tag-' + tag).removeClass('selected');
            delete selectedTags[tag];
          }
          else {
            $tags.find('.tag-' + tag).addClass('selected');
            selectedTags[tag] = true;
          }

          refreshCharts();
        }).appendTo($tags);

        $('<div class="t_s"></div>').text(sec2time(t_s / 1000)).appendTo($tag);
        $('<div class="t_e"></div>').text(sec2time(t_e / 1000)).appendTo($tag);
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
    }
  }

  function displayCharts() {
    if (index_attr && index_attr.length) {
      for (var i = 0; i < index_attr.length; i++) {
        var attr = index_attr[i].toLowerCase();

        if (!index_data || !index_data[attr]) {
          continue;
        }

        charts[attr] = {
          $el: $([
            '<div class="chart-container">',
            '<label>', index_attr[i], '</label>',
            '<div class="chart"></div>',
            '<input type="hidden" class="ma" placeholder="Moving Average" data-attr="', attr, '">',
            '</div>'
          ].join('')).appendTo('#charts')
        };

        charts[attr].$el.find('input').select2({
          minimumResultsForSearch: 10,
          data: ma_attr
        }).change(function(e) {
          var $el = $(this),
              attr = $el.attr('data-attr');

          charts[attr].ma = $el.val();
          displayChart(attr);
        });

        displayChart(attr);
      }
    }
  }

  window.displayCharts = displayCharts;

  function displayChart(attr) {
    var series = [];

    var $chart = charts[attr].$el.find('.chart');

    charts[attr].plot = $.plot($chart,
      getSeries(attr),
      {
        series: {
          shadowSize: 0
        },
        xaxis: {
        },
        yaxis: {
          labelWidth: 80
        },
        selection: {
          mode: 'x'
        },
        crosshair: {
          mode: 'x'
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
      var n = index_data[attr].length - 1;
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
    if (typeof(charts[attr].color) == 'undefined') {
      charts[attr].color = nextColor++;
    }

    var series = [];

    // data:
    series.push({
      color: charts[attr].color,
      data: getFlotData(attr)
    });

    var avg = index_data[attr].avg;
    series.push({
      color: 2,
      data: [[0, avg], [index_data[attr].series.length, avg]]
    });

    // moving average:
    if (charts[attr].ma) {
      series.push({
        color: 1,
        data: getMAData(attr, charts[attr].ma)
      });
    }

    return series;
  }

  // determine the intervals we need to "nullify" from the data, based on what
  // tags are selected:
  function getIntervals(attr) {
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
          s: Math.max(0, Math.min(Math.round(seq.t_s / 400), index_data[attr].length - 1)),
          e: Math.max(0, Math.min(Math.round(seq.t_e / 400), index_data[attr].length - 1))
        });
      }
    }

    intervals.sort(function(a, b) {
      return a.s - b.s;
    });

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

    if (start < index_data[attr].length - 1) {
      result.push({s: start, e: index_data[attr].length - 1});
    }

    return result;
  }

  function getFlotData(attr) {
    var data = [];

    for (var i = 0; i < index_data[attr].series.length; i++) {
      data.push([i, index_data[attr].series[i]]);
    }

    var intervals = getIntervals(attr);
    if (intervals) {
      for (var i = 0; i < intervals.length; i++) {
        for (j = intervals[i].s; j <= intervals[i].e; j++) {
          data[j][1] = null;
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

    if (period == 1) {
      return getFlotData(attr);
    }

    var s = 0;
    for (var i = 0; i < index_data[attr].series.length; i++) {
      s += index_data[attr].series[i];
      if (i >= period - 1) {
        data.push([i, s / period]);
        s -= index_data[attr].series[i - period + 1];
      }
      else {
        data.push([i, null]);
      }
    }

    var intervals = getIntervals(attr);
    if (intervals) {
      for (var i = 0; i < intervals.length; i++) {
        for (j = intervals[i].s; j <= intervals[i].e; j++) {
          data[j][1] = null;
        }
      }
    }

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

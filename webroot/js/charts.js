(function() {
  var charts = {},
      nextColor = 5,
      lastCrosshairP = 0,
      selectedTags = {},
      cache = {data: {}, ma: {}};

  $(function() {
    // close any popovers when clicking outside:
    $('body').on('click', function(e) {
      var $el = $(e.target);
      if (!$el.closest('.popover').length) {
        if (!$el.closest('.axis-target').length) {
          closePopover();
        }
      }
    });
  });

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
        ).appendTo($tags);

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

    var lastClickAt = 0,
        timer;
    $tags.on('click', function(e) {
      var t = (new Date()).getTime();

      if (lastClickAt && t - lastClickAt < 200) {
        clearTimeout(timer);

        var max = $tags.width(),
            x = e.pageX - $tags.offset().left,
            prc = x / max * 100;

        seek(prc);
        clearSelection();
      }
      else {
        timer = setTimeout(function() {
          var $el = $(e.target).closest('.tag'),
	            tag = $el.attr('data-tag');

          if ($el.is('.selected')) {
	          unselectTag(tag);
          }
          else {
	          selectTag(tag);
          }
        }, 200);
      }

      lastClickAt = t;
    });
  }

  window.displayTags = displayTags;

  function clearSelection() {
    if(document.selection && document.selection.empty) {
      document.selection.empty();
    }
    else if (window.getSelection) {
      var sel = window.getSelection();
      sel.removeAllRanges();
    }
  }

  function selectTag(tag) {
    var $tags = $('#tags');

    $tags.find('.tag-' + tag).addClass('selected');
    selectedTags[tag] = true;

    refreshCharts();
  }

  function unselectTag(tag) {
    var $tags = $('#tags');

    $tags.find('.tag-' + tag).removeClass('selected');
    delete selectedTags[tag];

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

  function displayCharts() {
    if (index_attr && index_attr.length) {
      for (var i = 0; i < index_attr.length; i++) {
        var attr = index_attr[i].toLowerCase();

        if (!index_data || !index_data[attr]) {
          continue;
        }

        charts[attr] = {
          attr: attr,
          avg: (window.tagAnalysis ? false : true),
          avg2: false,

          $el: $([
            '<div class="chart-container">',
            '<label class="labs">', index_attr[i], '</label>',
            '<div class="chart"></div>',
            '<div class="row controls">',
            '<div class="col-lg-6" style="padding-left: 95px;">',
            '<input type="hidden" value="', attr, '" class="series" data-attr="', attr, '">',
            '<input type="hidden" class="ma" placeholder="Moving Average" data-attr="', attr, '">',
            (window.tagAnalysis ? '' : '<label class="checkbox-inline"><input type="checkbox" checked data-attr="' + attr + '"> Show average</label>'),
            '<div class="boLine"><div class="boLineIn"></div></div><span class="boLineTxt">点击换播放线颜色</span>',
            '</div>',
            '<div class="col-lg-6" style="text-align: right; padding-right: 30px;">',
            '<input type="hidden" class="series" placeholder="Y2 Data" data-y2="true" data-attr="', attr, '">',
            '<input type="hidden" class="ma" placeholder="Y2 Moving Average" data-y2="true" data-attr="', attr, '">',
            (window.tagAnalysis ? '' : '<label class="checkbox-inline"><input type="checkbox" data-y2="true" data-attr="' + attr + '"> Show average</label>'),
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
    colorBtn();
  }

  window.displayCharts = displayCharts;

  function displayChart(attr,colors1,colors2,lineColor) {
    var series = [];
    var label = getAttrLabel(charts[attr].attr);
    if (charts[attr].attr2) {
      label += ' vs. ' + getAttrLabel(charts[attr].attr2);
    }
    charts[attr].$el.children('label').text(label);

    var $chart = charts[attr].$el.find('.chart');
    var changeLineColor='';
    if(!lineColor)
    {
      changeLineColor='#a23c3c';
    }  
    else
    {
      changeLineColor=lineColor;
    }
    var plot = charts[attr].plot = $.plot($chart,
      getSeries(attr,colors1,colors2),
      {
        series: {
          shadowSize: 0
        },
        xaxis: {
          tickFormatter: function(val, axis) {
            if (window.tagAnalysis) {
              if (index_data[charts[attr].attr].counts[val]) {
                return sec2time(val * 400 / 1000) + '<br>' + index_data[charts[attr].attr].counts[val];
              }
              else {
                return '';
              }
            }
            else {
              return sec2time(val * 400 / 1000);
            }
          }
        },
        yaxes: [
          {
            labelWidth: 80,
            min: charts[attr].min,
            max: charts[attr].max
          },
          {
            position: 'right',
            labelWidth: 80,
            min: charts[attr].min2,
            max: charts[attr].max2
          }
        ],
        selection: {
          mode: 'x'
        },
        crosshair: {
          mode: 'x',
          color:changeLineColor
        },
        legend: {
          show: true,
          noColumns: 6 
        },
        grid: {
          clickable: true,
          autoHighlight: false
        }
      }
    );

    // add zoom-out button:
    var $btn = $('<button>Zoom Out</button>').addClass('btn btn-danger btn-xs btn-zoom-out').appendTo($chart).click(function(e) {
      zoom();
    });

    $chart.unbind();

    $chart.bind('plotselected', function(e, ranges) {
      zoom(ranges);
    });

    var lastClickAt = 0;
    $chart.bind('plotclick', function(e, pos) {
      var t = (new Date()).getTime();

      if (lastClickAt && t - lastClickAt < 200) {
        var max = plot.getXAxes()[0].datamax,
            prc = pos.x / max * 100;

        seek(prc);
      }

      lastClickAt = t;
    });

    // interact with the Y axes:
    $(plot.getPlaceholder()).find('.axis-target').remove();
    $.each(plot.getYAxes(), function(i, axis) {
      if (!axis.show) {
        return;
      }

      var box = axis.box;
      var id = 'a' + Math.floor(Math.random() * 10e6);

      $('<a href="javascript:;"></a>').attr('id', id).addClass('axis-target').css({
        position: 'absolute',
        display: 'block',
        left: box.left + 'px',
        top: box.top + 'px',
        width: box.width + 'px',
        height: box.height + 'px',
        'background-color': '#f00', //侧边移入移出的背景颜色的变化
        opacity: 0,
        cursor: 'pointer'
      }).hover(
        function() { $(this).addClass('axis-selected'); },
        function() { $(this).removeClass('axis-selected'); }
      ).click(function() {
        $(this).css('opacity', 0.10);
        openPopover(id);
      }).popover({
        placement: i == 0 ? 'right': 'left',
        content: [
          '<form id="f', id, '" data-attr="', attr, '" data-axis="', i, '">',
          '<div class="row" style="margin-bottom: 5px;">',
          '<div class="col-xs-6"><input name="min" type="text" value="', axis.min, '" class="form-control" placeholder="Min"></div>',
          '<div class="col-xs-6"><input name="max" type="text" value="', axis.max, '" class="form-control" placeholder="Max"></div>',
          '</div>',
          '<a href="javascript: setAxisRange();" class="btn btn-danger btn-sm">Update</a>',
          '</form>'
        ].join(''),
        html: true,
        trigger: 'manual',
        title: 'Set Axis Range'
      }).appendTo(plot.getPlaceholder());
    });

    crosshair();
    colorBtn();
  }

  window.setAxisRange = function() {
    if (!window.openedPopover) {
      return;
    }

    var $form = $('form#f' + window.openedPopover),
        attr = $form.attr('data-attr'),
        axis = parseInt($form.attr('data-axis')),
        min = $form.find('[name="min"]').val(),
        max = $form.find('[name="max"]').val();

    if (min) {
      min = parseFloat(min);
    }
    else {
      min = null;
    }

    if (max) {
      max = parseFloat(max);
    }
    else {
      max = null;
    }

    charts[attr]['min' + (axis ? '2' : '')] = min;
    charts[attr]['max' + (axis ? '2' : '')] = max;

    displayChart(attr);

    closePopover();
  };

  function openPopover(id) {
    if (window.openedPopover && window.openedPopover != id) {
      closePopover(window.openedPopover);
    }

    window.openedPopover = id;
    $('#' + id).popover('show');
  }

  function closePopover(id) {
    window.openedPopover = null;

    var $el = (id ? $('#' + id) : $('.axis-target'));
    $el.css('opacity', 0).popover('hide');
  }

  function refreshCharts() {
    for (var attr in charts) {
      displayChart(attr);
    }
  }

  window.refreshCharts = refreshCharts;

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

  function getSeries(attr,colors1,colors2) {
    if (typeof(charts[attr].color) == 'undefined') {
      charts[attr].color = nextColor;   //颜色控制，是flot图的背景颜色
      nextColor += 2;
    }
    else
    {
      if(colors1)
      {
        charts[attr].color = colors1;   //颜色控制，是flot图的背景颜色
      }
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
      var avg = index_data[charts[attr].attr].avg;
      var changeColor='';
      if(colors2)
      {
        changeColor=colors2;
      }
      else
      {
        changeColor=2;
      }
      series.push({
        label: '&nbsp;' + getAttrLabel(charts[attr].attr) + ' Avg&nbsp;&nbsp;&nbsp;',
        color: changeColor, //中间那条线的颜色
        data: [[0, avg], [index_data[charts[attr].attr].series.length, avg]]
      });
    }

    // moving average:
    if (charts[attr].ma) {
      series.push({
        label: '&nbsp;' + getAttrLabel(charts[attr].attr) + ' MA-' + charts[attr].ma + '&nbsp;&nbsp;&nbsp;',
        color: 2, //会在中间出现波浪线，而且改变颜色的话会发生颜色变化
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
        var avg = index_data[charts[attr].attr2].avg;
        series.push({
          label: '&nbsp;' + getAttrLabel(charts[attr].attr2) + ' Avg&nbsp;&nbsp;&nbsp;',
          color: 3,
          data: [[0, avg], [index_data[charts[attr].attr2].series.length, avg]],
          yaxis: 2
        });
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
          s: Math.max(0, Math.min(Math.floor(seq.t_s / 400) - 1, index_data[attr].series.length - 1)),
          e: Math.max(0, Math.min(Math.floor(seq.t_e / 400) - 1, index_data[attr].series.length - 1))
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

  function seek(prc) {
    if (!window.player || !window.player.hasData()) {
      return;
    }

    var pos = window.player.duration() * prc / 100;
    window.player.time(pos);
  }
  //十六进制颜色值的正则表达式  
  var reg = /^#([0-9a-fA-f]{3}|[0-9a-fA-f]{6})$/;
  /*RGB颜色转换为16进制*/
  String.prototype.colorHex = function(){
   var that = this;
   if(/^(rgb|RGB)/.test(that)){
        var aColor = that.replace(/(?:\(|\)|rgb|RGB)*/g,"").split(",");
        var strHex = "#";
        for(var i=0; i<aColor.length; i++){
             var hex = Number(aColor[i]).toString(16);
             if(hex === "0"){
                  hex += hex;    
             }
             strHex += hex;
        }
        if(strHex.length !== 7){
             strHex = that;    
        }
        return strHex;
   }else if(reg.test(that)){
        var aNum = that.replace(/#/,"").split("");
        if(aNum.length === 6){
             return that;    
        }else if(aNum.length === 3){
             var numHex = "#";
             for(var i=0; i<aNum.length; i+=1){
                  numHex += (aNum[i]+aNum[i]);
             }
             return numHex;
        }
   }else{
        return that;    
   }
  };
  //通过点击改变颜色
  function colorBtn()
  {
    $('.legendColorBox').off('click');
    $('.legendColorBox').on('click',function (index){
      var target=this;
      var colorArr=[];
      var index=$(target).index();
      var legendSib=$('<div class=".legendSib"></div>');
      legendSib.insertBefore($(target));
      $.fn.jPicker.defaults.images.clientPath='../../img/';
      var colors=$(target).children().children().css('border-color'); //rgb(150, 60, 99);
      colors = colors.colorHex();
        $(legendSib).jPicker(  
          {  
            window:  
            {  
                position:  
                {  
                  x: 'screenCenter',
                   /* acceptable values "left", "center", "right", "screenCenter", or relative px value */  
                  y: 'bottom' 
                  /* acceptable values "top", "bottom", "center", or relative px value */  
                }  
              // expandable: false  
            },
            "color":{
          active: new $.jPicker.Color({ hex: colors })
        },  

            // images:  
            // {  
            //   //clientPath: '/'+document.location.pathname.split("/")[1]+'/commons/jpicker-1.1.6/images/', /* Path to image files */  
            //   clientPath: 'images/', 
            //   /* Path to image files */  
            // },  
            localization: /* alter these to change the text presented by the picker (e.g. different language) */  
            {  
              text:  
              {  
                title: '拖动鼠标选中一个颜色',  
                newColor: '选中颜色',  
                currentColor: '当前颜色',  
                ok: '确定',  
                cancel: '取消'  
              },  
              tooltips:  
              {  
                colors:  
                {  
                  newColor: '点击‘确定’提交新选颜色',  
                  currentColor: '点击这里还原当前颜色'  
                },  
                buttons:  
                {  
                  ok: '提交新选颜色',  
                  cancel: '取消并恢复当前颜色'  
                }  
              }  
            }
          },
          function (color, context){
            var all = color.val('all');
            var colors=(all && '#' + all.hex || 'transparent');
              $('.jPicker').hide();
              $(target).children().children().css(
              {
                borderColor: colors
              });
              var colors1=$(target).parents('.chart-container').find('.legendColorBox').eq(0).children().children().css('border-color');
              colors1 = colors1.colorHex();
              var colors2=$(target).parents('.chart-container').find('.legendColorBox').eq(1).children().children().css('border-color');
              colors2 = colors2.colorHex();
              var changeLineColor=$(target).parents('.chart-container').find('.boLineIn').css('border-color');
              changeLineColor = changeLineColor.colorHex();
              var attrs=$(target).parents('.chart-container').find('.labs').text().toLowerCase(); 
              console.log(attrs,colors1,colors2,changeLineColor+'///111');
              displayChart(attrs,colors1,colors2,changeLineColor);
            },
            function (color, context){
              var hex = color.val('hex');
              $(target).children().children().css(
              {
                borderColor: hex && '#' + hex || 'transparent'
              });
            },
            function (color, context){
              $('.jPicker').hide();
            }
          ); 
      });
    $('.boLine').off('click');
    $('.boLine').on('click',function (index){
      var target=this;
      var index=$(target).index();
      var legendSib=$('<div class=".legSib"></div>');
      legendSib.insertBefore($(target));
      $.fn.jPicker.defaults.images.clientPath='../../img/';
      var changeColors=$(target).children().css('border-color').colorHex();
        $(legendSib).jPicker(  
          {  
            window:  
            {  
                position:  
                {  
                  x: 'left',
                   /* acceptable values "left", "center", "right", "screenCenter", or relative px value */  
                  y: 'bottom' 
                  /* acceptable values "top", "bottom", "center", or relative px value */  
                }  
              // expandable: false  
            },
            "color":{
          active: new $.jPicker.Color({ hex: changeColors })
        },  

            // images:  
            // {  
            //   //clientPath: '/'+document.location.pathname.split("/")[1]+'/commons/jpicker-1.1.6/images/', /* Path to image files */  
            //   clientPath: 'images/', 
            //   /* Path to image files */  
            // },  
            localization: /* alter these to change the text presented by the picker (e.g. different language) */  
            {  
              text:  
              {  
                title: '拖动鼠标选中一个颜色',  
                newColor: '选中颜色',  
                currentColor: '当前颜色',  
                ok: '确定',  
                cancel: '取消'  
              },  
              tooltips:  
              {  
                colors:  
                {  
                  newColor: '点击‘确定’提交新选颜色',  
                  currentColor: '点击这里还原当前颜色'  
                },  
                buttons:  
                {  
                  ok: '提交新选颜色',  
                  cancel: '取消并恢复当前颜色'  
                }  
              }  
            }
          },
          function (color, context){
            var all = color.val('all');
            var colors=(all && '#' + all.hex || 'transparent');
              $(target).children().css(
              {
                borderColor: colors
              });
              $('.jPicker').hide();
              var colors1=$(target).parents('.chart-container').find('.legendColorBox').eq(0).children().children().css('border-color');
              colors1 = colors1.colorHex();
              var colors2=$(target).parents('.chart-container').find('.legendColorBox').eq(1).children().children().css('border-color');
              colors2 = colors2.colorHex();
              var attrs=$(target).parents('.chart-container').find('.labs').text().toLowerCase();               
              setTimeout(function (){
                console.log(attrs,colors1,colors2,colors+'222');
                displayChart(attrs,colors1,colors2,colors);
              },30);
            },
            function (color, context){
              var hex = color.val('hex');
              $(target).children().css(
              {
                borderColor: hex && '#' + hex || 'transparent'
              });
            },
            function (color, context){
              $('.jPicker').hide();
            }
          ); 
      });
  }
})();

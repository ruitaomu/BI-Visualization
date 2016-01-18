{extends 'layouts/front.tpl'}
{block name='head' append}
<link type="text/css" href="{$BASE}/lib/select2/select2.css" rel="stylesheet">
<link type="text/css" href="{$BASE}/lib/select2-bootstrap/select2-bootstrap.css" rel="stylesheet">
<link type="text/css" href="{$BASE}/lib/c3/c3.css" rel="stylesheet">
<style type="text/css">
  .c3-axis-y {
    min-width: 50px;
  }
</style>
{/block}
{block name='content'}
<section class="wrapper">
  {flash}
  <section class="panel">
    <div class="panel-heading">
	    <span class="lead">Projects | {$title}</span>
      <select id="tester_id" style="float: right; min-width: 150px;" placeholder="Select Tester">
        <option value=""></option>
        {html_options options=$tester_opt selected=$tester_id}
      </select>
      {include file='controllers/projects/tabs.tpl'}
    </div>
    <div class="panel-body visualisation">
      {if $tester_id}
        {if $tester_data.wistia_video_hashed_id}
        <div class="row">
          <div class="col-lg-4 col-lg-offset-4 col-md-4 col-md-offset-4 col-sm-6 col-sm-offset-3">
            <div class="embed-responsive embed-responsive-16by9">
              <div class="embed-responsive-item">
                <iframe src="//fast.wistia.net/embed/iframe/{$tester_data.wistia_video_hashed_id}" allowtransparency="true" frameborder="0" scrolling="no" class="wistia_embed" name="wistia_embed" allowfullscreen mozallowfullscreen webkitallowfullscreen oallowfullscreen msallowfullscreen width="100%" height="100%"></iframe>
              </div>
            </div>
          </div>
        </div>
        {/if}
        <div class="row">
          <div class="col-lg-12 col-md-12 col-sm-12">
            <span style="font-size: 15px;">Tags</span>
            <hr>
            {if $tester_data.tags_file}
              <div style="margin: 0 12px 0 62px; padding-top: 10px;">
                <div id="tags" class="tags">
                  <div id="tags-marker" class="video-marker" data-toggle="tooltip" data-html="true" data-title="<span class='video-time'>00:00</span>" data-trigger="manual" data-placement="top" data-container="#tags-marker"></div>
                </div>
                <ul id="legend" class="list-unstyled list-inline legend"></ul>
              </div>
            {else}
              There's no tags file uploaded for this tester, please upload one from the Data tab.
            {/if}
          </div>
        </div>
        <div class="row">
          <div class="col-lg-12 col-md-12 col-sm-12">
            <span style="font-size: 15px;">Index Data</span>
            <hr>
            {if $tester_data.index_file}
              <div id="charts"></div>
              <div id="loader" style="text-align: center;"><i class="fa fa-spinner fa-spin"></i> loading charts, please wait...</div>
            {else}
              There's no index file uploaded for this tester, please upload one from the Data tab.
            {/if}
          </div>
        </div>
      {/if}
    </div>
  </section>
</section>
{/block}
{block name='foot' append}
<script src="//fast.wistia.net/assets/external/E-v1.js"></script>
<script type="text/javascript" src="{$BASE}/lib/select2/select2.js"></script>
<script type="text/javascript" src="{$BASE}/lib/frwk/js/forms.js"></script>
<script type="text/javascript" src="{$BASE}/lib/d3/d3.min.js"></script>
<script type="text/javascript" src="{$BASE}/lib/c3/c3.min.js"></script>
{show_errors form='creupd' errors=$errors}
<script type="text/javascript">
  var tags = {$tags_json};
  var index_data = {$index_data_json};
  var index_attr = {$index_attr_json};
  $(function() {
    $('#tester_id').select2({
      minimumResultsForSearch: 10
    });

    // display the tags:
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
        ).appendTo($tags);

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

    // generate the index data charts:
    setTimeout(function() {
      if (index_data) {
        var $charts = $('#charts'), charts = {};
        for (var i = 0; i < index_attr.length; i++) {
          var attr = index_attr[i].toLowerCase();
          if (index_data[attr]) {
            var $el = $('<div></div>').appendTo($charts);
            c3.generate({
              bindto: $el[0],
              data: {
                columns: [index_data[attr]]
              },
              zoom: {
                enabled: true
              },
              point: {
                show: false
              },
              padding: {
                left: 50
              },
              color: {
                pattern: [randomColor()]
              },
              onrendered: function() {
                $('#loader').hide();
              }
            });
          }
        }
      }
    }, 500);

    $('#tester_id').change(function() {
      var url = "{href action='visualisation'}?id={$id}" + '&tester_id=' + $(this).val();
      window.location.href = url;
    });

    window._wq = window._wq || [];
    _wq.push({
      '_all': function(video) {
        video.bind('timechange', function(t) {
          var p = t / video.duration() * 100;
          updateVideoProgress(p, t);
        });
        
        video.bind('end', function() {
          updateVideoProgress(100, video.duration());
        });
      }
    });

    $('[data-toggle="tooltip"]').tooltip('show');
  });

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

    $('.video-time').text(sec2time(t));
  }

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
</script>
{/block}

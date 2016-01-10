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
            <h2>Tags</h2>
            <hr>
            {if $tester_data.tags_file eq 1}
              <div style="margin: 0 12px 0 62px;" class="xx">
                <div id="tags" class="tags"></div>
                <ul id="legend" class="list-unstyled list-inline legend"></ul>
              </div>
            {else}
              There's no tags file uploaded for this tester, please upload one from the Data tab.
            {/if}
          </div>
        </div>
        <div class="row">
          <div class="col-lg-12 col-md-12 col-sm-12">
            <h2>Index Data</h2>
            <hr>
            {if $tester_data.index_file eq 1}
              <div id="charts"></div>
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
    var max_ts = tags.max_ts * 1 - tags.min_ts * 1;
    var tags_color = {};
    for (var tag in tags.tag) {
      tags_color[tag] = [
        Math.floor(Math.random() * 256),
        Math.floor(Math.random() * 256),
        Math.floor(Math.random() * 256)
      ];

      for (var i = 0; i < tags.tag[tag].length; i++) {
        t_s = tags.tag[tag][i].t_s * 1 - tags.min_ts * 1;
        t_e = tags.tag[tag][i].t_e * 1 - tags.min_ts * 1;
        
        $('<div></div>').addClass('tag-' + tag).css({
          'left': (t_s / max_ts * 100) + '%',
          'width': ((t_e - t_s) / max_ts * 100) + '%',
          'background-color': 'rgba(' + tags_color[tag] + ',1)'
        }).appendTo($tags);
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
            point: {
              show: false
            },
            padding: {
              left: 50
            }
          });
        }
      }
    }

    $('#tester_id').change(function() {
      var url = "{href action='visualisation'}?id={$id}" + '&tester_id=' + $(this).val();
      window.location.href = url;
    });
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
</script>
{/block}

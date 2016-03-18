{extends 'layouts/front.tpl'}
{block name='head' append}
<link type="text/css" href="{$BASE}/lib/select2/select2.css" rel="stylesheet">
<link type="text/css" href="{$BASE}/lib/select2-bootstrap/select2-bootstrap.css" rel="stylesheet">
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
      {include file='controllers/projects/tabs2.tpl'}
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
              <div style="margin: 0 12px 0 80px; padding-top: 10px;">
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
              <div id="loader" style="display: none; text-align: center;"><i class="fa fa-spinner fa-spin"></i> loading charts, please wait...</div>
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
<script type="text/javascript" src="{$BASE}/lib/flot/jquery.flot.js"></script>
<script type="text/javascript" src="{$BASE}/lib/flot/jquery.flot.resize.js"></script>
<script type="text/javascript" src="{$BASE}/lib/flot/jquery.flot.crosshair.js"></script>
<script type="text/javascript" src="{$BASE}/lib/flot/jquery.flot.selection.js"></script>
<script type="text/javascript" src="{$BASE}/js/charts.js"></script>
<script type="text/javascript">
  var tags = {$tags_json};
  var index_data = {$index_data_json};
  var index_attr = {$index_attr_json};
  var ma_attr = {$ma_attr_json};
  var url = "{href action='project-data-visualisation'}?id={$id}";

  $(function() {
    // initialise select2 controls:
    $('#tester_id').select2({
      minimumResultsForSearch: 10
    });

    $('#tester_id').change(function() {
      window.location.href = url + '&tester_id=' + $(this).val();
    });

    displayTags();
    displayCharts();

    $('[data-toggle="tooltip"]').tooltip('show');

    window._wq = window._wq || [];
    _wq.push({
      '_all': function(video) {
        window.player = video;

        video.bind('timechange', function(t) {
          var p = t / video.duration() * 100;
          updateVideoProgress(p, t);
        });
        
        video.bind('end', function() {
          updateVideoProgress(100, video.duration());
        });
      }
    });
  });
</script>
{/block}

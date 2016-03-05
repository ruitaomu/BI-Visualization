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
        <div class="row">
          <div class="col-lg-12 col-md-12 col-sm-12">
            <span style="font-size: 15px;">Tags</span>
            <hr>
            {if $tester_data.tags_file}
              <div style="margin: 0 12px 0 80px; padding-top: 10px;">
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
            <span style="font-size: 15px;">Average of Index Data (for selected tag)</span>
            <hr>
            {if $tester_data.index_file}
              <div id="charts" style="display: none;"></div>
              <div id="loader" style="display: none; text-align: center;"><i class="fa fa-spinner fa-spin"></i> loading charts, please wait...</div>
              <div id="no-tag-selected" style="text-align: center;">Please select a tag from above.</div>
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
  var url = "{href action='project-tag-analysis'}?id={$id}";
  window.tagAnalysis = true;

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
  });
</script>
{/block}

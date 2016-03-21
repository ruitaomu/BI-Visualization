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
      {include file='controllers/projects/tabs2.tpl'}
    </div>
    <div class="panel-body visualisation">
      <div class="row">
        <div class="col-lg-12 col-md-12 col-sm-12">
          <!--
          <span style="font-size: 15px;">Tags Selection</span>
          <hr>
          -->
          <div class="clearfix">
            <div id="testers" class="pull-left">
              <b>Testers</b>
              {foreach from=$tester_opt key=tester_id item=tester_name}
              <label class="checkbox">
                <input type="checkbox" value="{$tester_id}">
                {$tester_name}
              </label>
              {/foreach}
            </div>
            <div id="tags" class="pull-left" style="margin-left: 30px;">
              <b>Tags</b>
              {foreach from=$tags key=tag item=data}
              <div class="tag t-0 {$data.testers}" style="display: none;">
                <label class="checkbox">
                  <input type="checkbox">
                  {$tag}
                </label>
                <div>
                  {foreach from=$data.seq key=seq item=testers}
                    <label class="checkbox-inline t-0 {$testers}" style="display: none;">
                      <input type="checkbox" value="{$seq}" data-tag="{$tag}">
                      {$seq}
                    </label>
                  {/foreach}
                </div>
              </div>
              {/foreach}
            </div>
          </div>
          <br>
          <div>
            <b>Data Alignment</b>
            <br>
            <label class="radio-inline" style="padding-left: 0;">
              <input type="radio" name="tail" checked>
              Head (Left)
            </label>
            <label class="radio-inline">
              <input type="radio" name="tail" id="tail">
              Tail (Right)
            </label>
          </div>
          <br>
          <button class="btn btn-danger" onclick="generate()">Generate</button>
          <span id="loader" style="display: none;"><i class="fa fa-spinner fa-spin"></i> loading chart, please wait...</span>
        </div>
      </div>
      <div class="row">
        <div class="col-lg-12 col-md-12 col-sm-12">
          <div id="charts"></div>
        </div>
      </div>
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
  var index_data;
  var index_attr = {$index_attr_json};
  var ma_attr = {$ma_attr_json};
  var url = "{href action='project-tag-analysis'}?id={$id}";
  var displayChartsCalled = false;
  window.tagAnalysis = true;

  $(function() {
    $('#testers').on('click', 'input', function() {
      var tester_ids = [];
      $('#testers').find('input:checked').each(function() {
        tester_ids.push($(this).val());
      });

      showTags(tester_ids);
    });

    $('#tags').on('click', '.checkbox input', function(e) {
      var $el = $(e.target);
      $el.closest('.tag').find('.checkbox-inline input').prop('checked', $el.prop('checked'));
    });

    $('#tags').on('click', '.checkbox-inline input', function(e) {
      var $el = $(e.target);
      if (!$el.prop('checked')) {
        $el.closest('.tag').find('.checkbox input').prop('checked', false);
      }
    });
  });

  function showTags(tester_ids) {
    var $tags = $('#tags');
    $tags.find('.t-0').hide();
    for (var i = 0; i < tester_ids.length; i++) {
      $tags.find('.t-' + tester_ids[i]).show();
    }
  }

  function generate() {
    var data = {
      testers: [],
      tags: {},
      tail: $('#tail').prop('checked')
    };

    $('#testers').find('input:checked').each(function() {
      data.testers.push($(this).val());
    });

    var notags = true;
    $('#tags').find('.checkbox-inline input:visible').filter(':checked').each(function() {
      var $el = $(this),
          tag = $el.attr('data-tag'),
          seq = $el.val();

      if (!data.tags[tag]) {
        data.tags[tag] = [];
      }

      data.tags[tag].push(seq);
      notags = false;
    });

    if (notags) {
      return;
    }

    $('#loader').show();

    $.post(url, {
      json: JSON.stringify(data)
    },
    function(json) {
      $('#loader').hide();

      if (json.ok) {
        index_data = json.data;
        
        if (!displayChartsCalled) {
          displayChartsCalled = true;
          displayCharts();
        }
        else {
          refreshCharts();
        }
      }
    }, 'json');
  }
</script>
{/block}

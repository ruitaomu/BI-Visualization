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
	    <span class="lead">Projects Data</span>
      {include file='controllers/projects/tabs1.tpl'}
    </div>
    <div class="panel-body">
      <div class="row">
        <div class="col-lg-2">
          {include file='controllers/projects/filters.tpl'}
        </div>
        <div class="col-lg-10">
          <div id="charts"></div>
          <div id="loader" style="display: none; margin-top: 20px; text-align: center;"><i class="fa fa-spinner fa-3x fa-spin"></i><br>Loading charts, please wait...</div>
          <div id="empty" style="display: none; margin-top: 20px; text-align: center;">
            <p class="lead">No data found.</p>
          </div>
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

  $(function() {
    loadCharts();

    $('#view-projects').click(function() {
      window.location.href = '{href}?' + getFilters(true);
    });
  });

  function loadCharts() {
    var $loader = $('#loader').show();
    var filters = getFilters();

    $.getJSON("{href action='index-data'}", filters, function(json) {
      if (json.ok) {
        if (json.data.length === 0) {
          $('#empty').show();
        }
        else {
          index_data = json.data;
          displayCharts();
        }
      }

      $loader.hide();
    });
  }

  function getFilters(serialized) {
    var filters = {};
    $.each($('#filters').serializeArray(), function(_, kv) {
      if (kv.value) {
        filters[kv.name] = kv.value;
      }
    });
    if (serialized) {
      var arr = [];
      for (var k in filters) {
        arr.push(k + '=' + filters[k]);
      }
      return arr.join('&');
    }
    else {
      return filters;
    }
  }
</script>
{/block}

{extends 'layouts/front.tpl'}
{block name='content'}
<section class="wrapper">
  <div class="row">
    <div class="col-lg-4 dash-item">
      <div class="panel">
        <div class="panel-body">
          <a href="{href controller='projects'}"><i class="fa fa-briefcase fa-5x"></i>{$projects} <span>Project{if $projects ne 1}s{/if}</span></a>
        </div>
      </div>
    </div>
    <div class="col-lg-4 dash-item">
      <div class="panel">
        <div class="panel-body">
          <a href="{href controller='testers'}"><i class="fa fa-users fa-5x"></i>{$testers} <span>Tester{if $testers ne 1}s{/if}</span></a>
        </div>
      </div>
    </div>
    <div class="col-lg-4 dash-item">
      <div class="panel">
        <div class="panel-body">
          <a href="javascript:;"><i class="fa fa-tags fa-5x"></i>{$tags} <span>Tag{if $tags ne 1}s{/if}</span></a>
        </div>
      </div>
    </div>
    <div class="col-lg-4 dash-item">
      <div class="panel">
        <div class="panel-body">
          <div class="embed-responsive embed-responsive-4by3">
            <div class="chart-game_hardware embed-responsive-item"></div>
          </div>
          <span>Projects by Hardware</span>
        </div>
      </div>
    </div>
    <div class="col-lg-4 dash-item">
      <div class="panel">
        <div class="panel-body">
          <div class="embed-responsive embed-responsive-4by3">
            <div class="chart-game_type embed-responsive-item"></div>
          </div>
          <span>Projects by Game Type</span>
        </div>
      </div>
    </div>
    <div class="col-lg-4 dash-item">
      <div class="panel">
        <div class="panel-body">
          <div class="embed-responsive embed-responsive-4by3">
            <div class="chart-age_group embed-responsive-item"></div>
          </div>
          <span>Projects by Age Group</span>
        </div>
      </div>
    </div>
  </div>
</section>
{/block}
{block name='foot' append}
<script type="text/javascript" src="{$BASE}/lib/flot/jquery.flot.js"></script>
<script type="text/javascript" src="{$BASE}/lib/flot/jquery.flot.resize.js"></script>
<script type="text/javascript" src="{$BASE}/lib/flot/jquery.flot.pie.js"></script>
<script type="text/javascript">
  var charts = {$charts_json};

  $(function() {
    var $chart;
    for (var k in charts) {
      $chart = $('.chart-' + k);
      if (!$chart.length) {
        continue;
      }

      $.plot($chart, charts[k].data, {
        series: {
          pie: {
            innerRadius: 0.5,
            show: true
          }
        },
        legend: {
          show: false
        }
      });
    }
  });
</script>
{/block}

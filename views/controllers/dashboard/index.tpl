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
  </div>
</section>
{/block}

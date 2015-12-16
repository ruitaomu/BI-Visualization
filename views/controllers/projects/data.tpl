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
      {include file='controllers/projects/tabs.tpl'}
    </div>
    <div class="panel-body">
      <div id="data_container" class="row">
        {foreach $data as $d}
        <div class="pdata col-lg-3 col-md-4 col-sm-6">
          <div class="new"><span>+</span><br>click to add project data</div>
          <div class="panel">
            <div class="panel-heading">
              <div class="content" style="position: relative;">
                <div style="margin-right: 50px;">
                  <select name="tester_id" class="form-control" placeholder="Select Tester">
                    <option value=""></option>
                    {html_options options=$tester_id_opt}
                  </select>
                </div>
                <div style="top: 6px; right: 0; position: absolute;">
                  <i class="fa fa-pencil"></i>
                  <i class="fa fa-trash-o"></i>
                </div>
              </div>
            </div>
            <div class="panel-body">
              <div class="content">
                <div class="embed-responsive embed-responsive-16by9">
                  <div class="embed-responsive-item" style="padding-top: 10%; text-align: center; background-color: #f5f6f8;">
                    <i class="fa fa-video-camera fa-5x"></i>
                    <br>
                    click to upload video
                  </div>
                </div>
                <div class="row" style="margin-top: 10px;">
                  <div class="col-lg-6 col-md-6 col-sm-6">
                    <div style="text-align: center; background-color: #f5f6f8; padding: 5px;">
                      <i class="fa fa-paperclip fa-2x"></i>
                      <br>
                      upload index file
                    </div>
                  </div>
                  <div class="col-lg-6 col-md-6 col-sm-6">
                    <div style="text-align: center; background-color: #f5f6f8; padding: 5px;">
                      <i class="fa fa-tags fa-2x"></i>
                      <br>
                      upload tags file
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        {/foreach}
      </div>
    </div>
  </section>
</section>
{/block}
{block name='foot' append}
<script type="text/javascript" src="{$BASE}/lib/select2/select2.js"></script>
<script type="text/javascript" src="{$BASE}/lib/frwk/js/forms.js"></script>
<script type="text/javascript" src="{$BASE}/js/project_data.js"></script>
{show_errors form='creupd' errors=$errors}
{/block}

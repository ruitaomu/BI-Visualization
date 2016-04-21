{extends 'layouts/front.tpl'}
{block name='head' append}
<link type="text/css" href="{$BASE}/lib/select2/select2.css" rel="stylesheet">
<link type="text/css" href="{$BASE}/lib/select2-bootstrap/select2-bootstrap.css" rel="stylesheet">
<link type="text/css" href="{$BASE}/lib/fileupload/css/jquery.fileupload-ui.css" rel="stylesheet">
<link type="text/css" href="{$BASE}/css/project_data.css" rel="stylesheet">
<link type="text/css" href="{$BASE}/theme/assets/bootstrap-datetimepicker/css/datetimepicker.css" rel="stylesheet">
{/block}
{block name='content'}
<section class="wrapper">
  {flash}
  <section class="panel">
    <div class="panel-heading">
	    <span class="lead">Projects | {$title}</span>
      {include file='controllers/projects/tabs2.tpl'}
    </div>
    <div class="panel-body">
      <div id="data_container" class="row">
        {include file='partials/data_widget.tpl'}
        {foreach $testers as $t}
          {include file='partials/data_widget.tpl'}
        {/foreach}
      </div>
    </div>
  </section>
</section>
<div aria-hidden="true" role="dialog" tabindex="-1" id="addTester" class="modal fade">
  <form id="add_tester" method="post" action="{href controller='testers' action='create'}" data-frwk-validation="tester_model::default" data-frwk-submitfn="add_tester">
    <input type="hidden" name="mode" value="creupd">
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
          <h4 class="modal-title">Add Tester</h4>
        </div>
        <div class="modal-body">
          <div class="form-group control-group">
            <div class="controls">
              <input type="text" name="first_name" placeholder="First Name" class="form-control" maxlength="32">
            </div>
          </div>
          <div class="form-group control-group">
            <div class="controls">
              <input type="text" name="last_name" placeholder="Last Name" class="form-control" maxlength="32">
            </div>
          </div>
    			<div class="form-group control-group">
    				<div class="controls">
              <div class="input-group">
    					  <input type="text" id="dob" name="dob" placeholder="Date of Birth" class="form-control" maxlength="10">
                <span class="input-group-addon">
                  <i class="fa fa-calendar"></i>
                </span>
              </div>
    				</div>
    			</div>
    			<div class="form-group control-group">
    				<div class="controls">
              <label class="radio-inline" style="padding-left: 0;">
                <input type="radio" name="gender" value="M"> Male
              </label>
              <label class="radio-inline" style="padding-left: 0;">
                <input type="radio" name="gender" value="F"> Female
              </label>
    				</div>
    			</div>
    			<div class="form-group control-group">
    				<div class="controls">
    				  <select id="experience_id" name="experience_id" class="form-control" placeholder="Experience">
                <option value=""></option>
                {html_options options=$experience_id_opt selected=$experience_id}
              </select>
    				</div>
    			</div>
        </div>
        <div class="modal-footer">
          <div class="pull-left" style="margin-top: 7px;">
            <span class="x-state x-state_loading" style="display: none;">
              <img src="{$BASE}/img/ajax-loader.gif">
              {'Please wait...'|i18n}
            </span>
          </div>
          <button data-dismiss="modal" class="btn btn-default" type="button">Cancel</button>
          <button class="btn btn-primary" type="submit">Add Tester</button>
        </div>
      </div>
    </div>
  </form>
</div>
{/block}
{block name='foot' append}
<script charset="ISO-8859-1" src="//fast.wistia.com/assets/external/E-v1.js"></script>
<script type="text/javascript" src="{$BASE}/lib/select2/select2.js"></script>
<script type="text/javascript" src="{$BASE}/lib/frwk/js/forms.js"></script>
<script type="text/javascript" src="{$BASE}/lib/fileupload/js/vendor/jquery.ui.widget.js"></script>
<script type="text/javascript" src="{$BASE}/lib/fileupload/js/jquery.iframe-transport.js"></script>
<script type="text/javascript" src="{$BASE}/lib/fileupload/js/jquery.fileupload.js"></script>
<script type="text/javascript" src="{$BASE}/theme/assets/bootstrap-datetimepicker/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript" src="{$BASE}/js/project_data.js"></script>
<script type="text/javascript">
  var availableTesters = {$available_testers_json};
  var uploadUrl = '{$CFG.WISTIA.upload_url}';
  var statusUrl = '{$CFG.WISTIA.status_url}';

  $(function() {
    $('select').select2({
      minimumResultsForSearch: 10
    });

    $('#dob').datetimepicker({
      format: 'yyyy-mm-dd',
      autoclose: true,
      startView: 4,
      minView: 2
    });
  });

  function add_tester() {
    FRWK.Forms.ajax_submit(this, function(json) {
      if (json.ok) {
        $('.new [name="tester_id"]').select2('data', {
          id: json.data.id,
          text: json.data.first_name + ' ' + json.data.last_name
        });
        addTester();
        $('#addTester').modal('hide');
      }
    });

    return false;
  }
</script>
{show_errors form='creupd' errors=$errors}
{/block}

{extends 'layouts/front.tpl'}
{block name='head' append}
<link type="text/css" href="{$BASE}/lib/select2/select2.css" rel="stylesheet">
<link type="text/css" href="{$BASE}/lib/select2-bootstrap/select2-bootstrap.css" rel="stylesheet">
<link type="text/css" href="{$BASE}/theme/assets/bootstrap-datetimepicker/css/datetimepicker.css" rel="stylesheet">
{/block}
{block name='content'}
<section class="wrapper">
  {flash}
  <section class="panel">
    <div class="panel-heading">
	    <span class="lead">{if $id gt 0}{'Testers'|i18n} | {$first_name} {$last_name}{else}{'Create Tester'|i18n}{/if}</span>
    </div>
    <div class="panel-body">
    	<form id="creupd" method="post" class="form-horizontal" autocomplete="off" data-frwk-validation="tester_model::default" {if $id gt 0}data-frwk-mode="upd"{/if}>
    		<input type="hidden" name="mode" value="creupd">
    		<fieldset>
    			<div class="control-group form-group">
    				<label for="first_name" class="control-label col-lg-2 col-md-2 col-sm-2">{'First Name'|i18n}</label>
    				<div class="controls col-lg-10 col-md-10 col-sm-10">
    					<input type="text" id="first_name" name="first_name" value="{$first_name}" maxlength="32" class="form-control">
    				</div>
    			</div>
    			<div class="control-group form-group">
    				<label for="last_name" class="control-label col-lg-2 col-md-2 col-sm-2">{'Last Name'|i18n}</label>
    				<div class="controls col-lg-10 col-md-10 col-sm-10">
    					<input type="text" id="last_name" name="last_name" value="{$last_name}" maxlength="32" class="form-control">
    				</div>
    			</div>
    			<div class="control-group form-group">
    				<label for="dob" class="control-label col-lg-2 col-md-2 col-sm-2">{'Date of Birth'|i18n}</label>
    				<div class="controls col-lg-10 col-md-10 col-sm-10">
              <div class="input-group">
    					  <input type="text" id="dob" name="dob" value="{$dob}" maxlength="10" class="form-control">
                <span class="input-group-addon">
                  <i class="fa fa-calendar"></i>
                </span>
              </div>
    				</div>
    			</div>
    			<div class="control-group form-group">
    				<label for="" class="control-label col-lg-2 col-md-2 col-sm-2">{'Gender'|i18n}</label>
    				<div class="controls col-lg-10 col-md-10 col-sm-10">
              <label class="radio-inline" style="padding-left: 0;">
                <input type="radio" name="gender" value="M" {if $gender eq 'M'}checked{/if}> Male
              </label>
              <label class="radio-inline" style="padding-left: 0;">
                <input type="radio" name="gender" value="F" {if $gender eq 'F'}checked{/if}> Female
              </label>
    				</div>
    			</div>
    			<div class="control-group form-group">
    				<label for="experience_id" class="control-label col-lg-2 col-md-2 col-sm-2">{'Experience'|i18n}</label>
    				<div class="controls col-lg-10 col-md-10 col-sm-10">
              <div class="input-group select2-bootstrap-append">
    					  <select id="experience_id" name="experience_id" class="form-control">
                  {html_options options=$experience_id_opt selected=$experience_id}
                </select>
                <span class="input-group-btn">
                  <a data-toggle="modal" href="#addExperience" class="btn btn-primary">Add New</a>
                </span>
              </div>
    				</div>
    			</div>
    			<div class="form-group">
            <div class="col-lg-offset-2 col-md-offset-2 col-sm-offset-2 col-lg-10 col-md-10 col-sm-10">
    				  <button type="submit" class="btn btn-primary">{if $id}Update{else}Create{/if}</button>
    				  <a href="{href}" class="btn">{'Cancel'|i18n}</a>
            </div>
    			</div>
    		</fieldset>
    	</form>
    </div>
  </section>
</section>
<div aria-hidden="true" role="dialog" tabindex="-1" id="addExperience" class="modal fade">
  <form id="add_experience" method="post" action="{href controller='attributes' action='add-attribute'}" data-frwk-validation="attribute_model::default" data-frwk-submitfn="add_attribute">
    <input type="hidden" name="name" value="experience">
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
          <h4 class="modal-title">Add Tester Experience</h4>
        </div>
        <div class="modal-body">
          <div class="form-group control-group">
            <div class="controls">
              <input type="text" name="value" placeholder="Experience" class="form-control" maxlength="64">
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
          <button class="btn btn-primary" type="submit">Add Tester Experience</button>
        </div>
      </div>
    </div>
  </form>
</div>
{/block}
{block name='foot' append}
<script type="text/javascript" src="{$BASE}/lib/select2/select2.js"></script>
<script type="text/javascript" src="{$BASE}/theme/assets/bootstrap-datetimepicker/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript" src="{$BASE}/lib/frwk/js/forms.js"></script>
{show_errors form='creupd' errors=$errors}
<script type="text/javascript">
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

  function add_attribute() {
    var $form = $(this);
    var name = $form.find('input[name="name"]').val();
    var value = $form.find('input[name="value"]').val();

    $.post($form.attr('action'), { name: name, value: value }, function(response) {
      response = JSON.parse(response);
      if (typeof(response) == 'number' && response > 0) {
        add_option($('#experience_id'), response, value);
        $form.closest('.modal').modal('hide');
      }
      else {
        FRWK.Forms.show_errors($form[0], response);
      }
    });

    return false;
  }

  function add_option($select, id, text) {
    var $option = $('<option></option>').val(id).text(text);
    $select.append($option).select2('val', id);
  }
</script>
{/block}

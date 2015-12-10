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
	    <span class="lead">{if $id gt 0}{'Projects'|i18n} - {$title}{else}{'Create Project'|i18n}{/if}</span>
      {include file='controllers/projects/tabs.tpl'}
    </div>
    <div class="panel-body">
    	<form id="creupd" method="post" class="form-horizontal" autocomplete="off" data-frwk-validation="project_model::default" {if $id gt 0}data-frwk-mode="upd"{/if}>
    		<input type="hidden" name="mode" value="creupd">
    		<fieldset>
    			<div class="control-group form-group">
    				<label for="title" class="control-label col-lg-2 col-sm-2">{'Title'|i18n}</label>
    				<div class="controls col-lg-10 col-md-10 col-sm-10">
    					<input type="text" id="title" name="title" value="{$title}" maxlength="128" class="form-control">
    				</div>
    			</div>
    			<div class="control-group form-group">
    				<label for="description" class="control-label col-lg-2 col-md-2 col-sm-2">{'Description'|i18n}</label>
    				<div class="controls col-lg-10 col-md-10 col-sm-10">
    					<textarea id="description" name="description" class="form-control" rows="4">{$description}</textarea>
    				</div>
    			</div>
    			<div class="control-group form-group">
    				<label for="customer_id" class="control-label col-lg-2 col-md-2 col-sm-2">{'Customer'|i18n}</label>
    				<div class="controls col-lg-10 col-md-10 col-sm-10">
              <div class="input-group select2-bootstrap-append">
    					  <select id="customer_id" name="customer_id" class="form-control">
                  {html_options options=$customer_id_opt selected=$customer_id}
                </select>
                <span class="input-group-btn">
                  <a data-toggle="modal" href="#addCustomer" class="btn btn-primary">Add New</a>
                </span>
              </div>
    				</div>
    			</div>
    			<div class="control-group form-group">
    				<label for="game_type_id" class="control-label col-lg-2 col-md-2 col-sm-2">{'Game Type'|i18n}</label>
    				<div class="controls col-lg-10 col-md-10 col-sm-10">
    					<select id="game_type_id" name="game_type_id" class="form-control">
                {html_options options=$game_type_id_opt selected=$game_type_id}
              </select>
    				</div>
    			</div>
    			<div class="control-group form-group">
    				<label for="game_version" class="control-label col-lg-2 col-md-2 col-sm-2">{'Game Version'|i18n}</label>
    				<div class="controls col-lg-10 col-md-10 col-sm-10">
    					<input type="text" id="game_version" name="game_version" value="{$game_version}" maxlength="128" class="form-control">
    				</div>
    			</div>
    			<div class="control-group form-group">
    				<label for="game_hardware_id" class="control-label col-lg-2 col-md-2 col-sm-2">{'Game Hardware'|i18n}</label>
    				<div class="controls col-lg-10 col-md-10 col-sm-10">
    					<select id="game_hardware_id" name="game_hardware_id" class="form-control">
                {html_options options=$game_hardware_id_opt selected=$game_hardware_id}
              </select>
    				</div>
    			</div>
    			<div class="form-group">
            <div class="col-lg-offset-2 col-md-offset-2 col-sm-offset-2 col-lg-10 col-md-10 col-sm-10">
    				  <button type="submit" class="btn btn-primary">{if $id}Update{else}Next{/if}</button>
    				  <a href="{href}" class="btn">{'Cancel'|i18n}</a>
            </div>
    			</div>
    		</fieldset>
    	</form>
    </div>
  </section>
</section>
<div aria-hidden="true" role="dialog" tabindex="-1" id="addCustomer" class="modal fade">
  <form id="add_customer" method="post" action="{href controller='customers' action='create'}" data-frwk-validation="customer_model::default" data-frwk-submitfn="add_customer">
    <input type="hidden" name="mode" value="creupd">
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
          <h4 class="modal-title">Add Customer</h4>
        </div>
        <div class="modal-body">
          <div class="form-group control-group">
            <div class="controls">
              <input type="text" name="name" placeholder="Name" class="form-control" maxlength="128">
            </div>
          </div>
          <div class="form-group control-group">
            <div class="controls">
              <input type="text" name="contact_name" placeholder="Contact name" class="form-control" maxlength="128">
            </div>
          </div>
          <div class="form-group control-group">
            <div class="controls">
              <input type="text" name="contact_email" placeholder="Contact e-mail" class="form-control" maxlength="128">
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
          <button class="btn btn-primary" type="submit">Add Customer</button>
        </div>
      </div>
    </div>
  </form>
</div>
{/block}
{block name='foot' append}
<script type="text/javascript" src="{$BASE}/lib/select2/select2.js"></script>
<script type="text/javascript" src="{$BASE}/lib/frwk/js/forms.js"></script>
{show_errors form='creupd' errors=$errors}
<script type="text/javascript">
  $(function() {
    $('select').select2({
      minimumResultsForSearch: 10
    });
  });

  function add_customer() {
    FRWK.Forms.ajax_submit(this, function(json) {
      if (json.ok) {
        var $option = $('<option></option>').val(json.data.id).text(json.data.name);
        $('#customer_id').append($option).select2('val', json.data.id);
        $('#addCustomer').modal('hide');
      }
    });

    return false;
  }
</script>
{/block}

{extends 'layouts/front.tpl'}
{block name='content'}
<section class="wrapper">
  <section class="panel">
    <div class="panel-heading">
	    <span class="lead">{if $id gt 0}{'Update Customer'|i18n} - {$name}{else}{'Create Customer'|i18n}{/if}</span>
    </div>
    <div class="panel-body">
    	<form id="creupd" method="post" class="form-horizontal" autocomplete="off" data-frwk-validation="customer_model::default" {if $id gt 0}data-frwk-mode="upd"{/if}>
    		<input type="hidden" name="mode" value="creupd">
    		<fieldset>
    			<div class="control-group form-group">
    				<label for="name" class="control-label col-lg-2 col-sm-2">{'Name'|i18n}</label>
    				<div class="controls col-lg-10">
    					<input type="text" id="name" name="name" value="{$name}" maxlength="128" class="form-control">
    				</div>
    			</div>
    			<div class="control-group form-group">
    				<label for="contact_name" class="control-label col-lg-2 col-sm-2">{'Contact name'|i18n}</label>
    				<div class="controls col-lg-10">
    					<input type="text" id="contact_name" name="contact_name" value="{$contact_name}" maxlength="128" class="form-control">
    				</div>
    			</div>
    			<div class="control-group form-group">
    				<label for="contact_email" class="control-label col-lg-2 col-sm-2">{'Contact e-mail'|i18n}</label>
    				<div class="controls col-lg-10">
    					<input type="text" id="contact_email" name="contact_email" value="{$contact_email}" maxlength="128" class="form-control">
    				</div>
    			</div>
    			<div class="form-group">
            <div class="col-lg-offset-2 col-lg-10">
    				  <button type="submit" class="btn btn-primary">{if $id}Update{else}Create{/if}</button>
    				  <a href="{href}" class="btn">{'Cancel'|i18n}</a>
            </div>
    			</div>
    		</fieldset>
    	</form>
    </div>
  </section>
</section>
{/block}
{block name='foot' append}
<script type="text/javascript" src="{$BASE}/lib/frwk/js/forms.js"></script>
{show_errors form='creupd' errors=$errors}
{/block}

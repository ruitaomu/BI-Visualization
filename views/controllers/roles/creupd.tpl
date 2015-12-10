{extends 'layouts/front.tpl'}
{block name='head' append}
<link type="text/css" href="{$BASE}/css/permissions.css" rel="stylesheet">
{/block}
{block name='content'}
<section class="wrapper">
  <section class="panel panel-default">
    <div class="panel-heading">
  	  {if $id gt 0}
  		  <h1>{'Update Role'|i18n} - {$name}</h1>
  	  {else}
  		  <h1>{'Create Role'|i18n}</h1>
  	  {/if}
  	  <p class="lead">
  		  {''|i18n}
  	  </p>
    </div>
    <div class="panel-body">
    	<form id="creupd" method="post" class="form-horizontal" data-frwk-validation="role_model::default" {if $id gt 0}data-frwk-mode="upd"{/if}>
    		<input type="hidden" name="mode" value="creupd">
    		<fieldset>
    			<div class="control-group form-group">
    				<label for="name" class="control-label col-lg-2 col-sm-2">{'Name'|i18n}</label>
    				<div class="controls col-lg-10">
    					<input type="text" id="name" name="name" value="{$name}" maxlength="32" class="form-control">
    				</div>
    			</div>
    			<div class="control-group form-group">
    				<label for="description" class="control-label col-lg-2 col-sm-2">{'Description'|i18n}</label>
    				<div class="controls col-lg-10">
    					<textarea id="description" name="description" data-maxlength="255" class="form-control">{$description}</textarea>
    					<p class="help-block">
    						<small><span id="description_chars_remaining"></span> {'chars remaining'|i18n}</small>
    					</p>
    				</div>
    			</div>
    			<div class="control-group form-group">
    				<label class="control-label col-lg-2 col-sm-2">{'Permissions'|i18n}</label>
    				<div class="controls col-lg-10">
    					{include file='partials/permissions.tpl'}
    				</div>
    			</div>
    			<div class="form-group">
            <div class="col-lg-offset-2 col-lg-10">
    				  <button type="submit" class="btn btn-primary">{'Save Changes'|i18n}</button>
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
<script type="text/javascript" src="{$BASE}/lib/frwk/js/maxlength.js"></script>
<script type="text/javascript" src="{$BASE}/js/permissions.js"></script>
{show_errors form='creupd' errors=$errors}
{/block}

{extends 'layouts/admin.tpl'}
{block name='content'}
<div class="container">
	{if $id gt 0}
		<h1>{'Update Sample'|i18n} - {$name}</h1>
	{else}
		<h1>{'Create Sample'|i18n}</h1>
	{/if}
	<p class="lead">
		{''|i18n}
	</p>
	<br>
	<form id="creupd" method="post" class="form-horizontal" data-frwk-validation="sample_model::default" {if $id gt 0}data-frwk-mode="upd"{/if}>
		<input type="hidden" name="mode" value="creupd">
		<fieldset>
			<div class="control-group">
				<label for="name" class="control-label">{'Name'|i18n}</label>
				<div class="controls">
					<input type="text" id="name" name="name" value="{$name}" maxlength="32">
				</div>
			</div>
			<div class="form-actions">
				<button type="submit" class="btn btn-primary">{'Save Changes'|i18n}</button>
				<a href="{href}" class="btn">{'Cancel'|i18n}</a>
			</div>
		</fieldset>
	</form>
</div>
{/block}
{block name='foot' append}
<script type="text/javascript" src="{$BASE}/lib/frwk/js/forms.js"></script>
{show_errors form='creupd' errors=$errors}
{/block}

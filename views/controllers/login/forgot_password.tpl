{extends 'layouts/index.tpl'}
{block name='content'}
<form id="forgot_password" method="post" action="" class="well page_centered" data-frwk-validation="forgot_password">
	{flash}
	{if $failed}
	<div class="alert alert-error">{'This e-mail address is not registered.'|i18n}</div>
	{/if}
	<div class="control-group">
		<label for="email" class="control-label">{'E-mail'|i18n}:</label>
		<div class="controls">
			<input type="email" id="email" name="email" value="{$email}" class="span4">
		</div>
	</div>
	<br>
	<input type="submit" value="{'Reset'|i18n}" class="btn btn-primary">
	<a href="{href controller='login'}" id="login_link" class="btn btn-link">{'Login'|i18n}</a>
	|
	<a href="{href controller='register'}" class="btn btn-link">{'Register'|i18n}</a>
</form>
{/block}
{block name='foot' append}
<script type="text/javascript" src="{$BASE}/lib/frwk/js/forms.js"></script>
{/block}

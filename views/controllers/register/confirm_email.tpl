{extends 'layouts/index.tpl'}
{block name='content'}
{if $success}
<div class="alert alert-block alert-success page_centered">
	<h4>{'Registration Complete'|i18n}</h4>
	<br>
	<p>{'Your account is now active and ready to use.'|i18n}</p>
	<br>
	<a href="{href controller='login'}" class="btn btn-success">{'Login'|i18n}</a>
</div>
{else}
<div class="alert alert-block alert-error page_centered">
	<h4>{'Error'|i18n}</h4>
	<br>
	<p>{'Something went wrong. The link you are trying to access may be broken or expired. For any assistance please contact our support.'|i18n}</p>
	<br>
	<a href="mailto: {$CFG.EMAIL.support_email}" class="btn btn-danger">{'Contact Support'|i18n}</a>
</div>
{/if}
{/block}

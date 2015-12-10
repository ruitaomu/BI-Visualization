{extends 'layouts/index.tpl'}
{block name='content'}
<div class="alert alert-block alert-info page_centered">
	<h4>{'Confirm E-mail'|i18n}</h4>
	<br>
	<p>{'Thank you for joining!'|i18n}</p>
	<p>{'Before activating your new account, we need to verify your e-mail address. To that end, we\'ve just sent you an e-mail. To activate your account, please open the message and click on the confirmation link.'|i18n}</p>
	<br>
	<a href="{$BASE}/" class="btn btn-info">Continue</a>
</div>
{/block}

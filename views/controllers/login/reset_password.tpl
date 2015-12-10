{extends 'layouts/index.tpl'}
{block name='content'}
{if $success}
<form id="reset_password" method="post" action="" class="form-signin" data-frwk-validation="reset_password" data-frwk-submitfn="reset_password">
  <h2 class="form-signin-heading">Reset Password</h2>
  <div class="login-wrap">
	<div class="alert alert-error hide x-form_errors"></div>
	<div class="control-group">
		<div class="controls">
			<input type="password" id="password" name="password" class="form-control" maxlength="32" placeholder="New password">
		</div>
	</div>
	<div class="control-group">
		<div class="controls">
			<input type="password" id="password_retype" name="password_retype" class="form-control" maxlength="32" placeholder="Retype password">
		</div>
	</div>
  <button class="btn btn-lg btn-login btn-block" type="submit">Reset</button>
  </div>
</form>
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
{block name='foot' append}
{if $success}
<script type="text/javascript" src="{$BASE}/lib/frwk/js/forms.js"></script>
<script type="text/javascript">
	function reset_password($form) {
		if ($('#password').val() != $('#password_retype').val()) {
			FRWK.Forms.show_errors($form[0], {
				'password_retype': {
					'custom': 'Passwords don\'t match.'
				}
			});
			return false;
		}

		return true;
	}
</script>
{show_errors form='reset_password' errors=$errors}
{/if}
{/block}

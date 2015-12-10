{extends 'layouts/index.tpl'}
{block name='content'}
<form id="register" method="post" action="{href}" class="well page_centered" data-frwk-validation="user_model::default,register" data-frwk-submitfn="register">
	<div class="alert alert-error hide x-form_errors"></div>
	<div class="control-group">
		<label for="name" class="control-label">{'First name'|i18n}:</label>
		<div class="controls">
			<input type="text" id="first_name" name="first_name" value="{$first_name}" class="span4" maxlength="32">
		</div>
	</div>
	<div class="control-group">
		<label for="name" class="control-label">{'Last name'|i18n}:</label>
		<div class="controls">
			<input type="text" id="last_name" name="last_name" value="{$last_name}" class="span4" maxlength="32">
		</div>
	</div>
	<div class="control-group">
		<label for="email" class="control-label">{'E-mail'|i18n}:</label>
		<div class="controls">
			<input type="email" id="email" name="email" value="{$email}" class="span4" maxlength="64">
		</div>
	</div>
	<div class="control-group">
		<label for="password" class="control-label">{'Password'|i18n}:</label>
		<div class="controls">
			<input type="password" id="password" name="password" class="span4" maxlength="32">
		</div>
	</div>
	<div class="control-group">
		<label for="password_retype" class="control-label">{'Retype password'|i18n}:</label>
		<div class="controls">
			<input type="password" id="password_retype" name="password_retype" class="span4" maxlength="32">
		</div>
	</div>
	<input type="submit" value="{'Register'|i18n}" class="btn btn-primary">
	<a href="{href controller='login'}" class="btn btn-link">{'Login'|i18n}</a>
</form>
{/block}
{block name='foot' append}
<script type="text/javascript" src="{$BASE}/lib/frwk/js/forms.js"></script>
<script type="text/javascript">
	function register($form) {
		if ($('#password').val() != $('#password_retype').val()) {
			FRWK.Forms.show_errors($form[0], {
				'password_retype': {
					'custom': "{'Passwords don\'t match.'|i18n}"
				}
			});
			return false;
		}

		return true;
	}
</script>
{show_errors form='register' errors=$errors}
{/block}

{extends 'layouts/front.tpl'}
{block name='content'}
<section class="wrapper">
	{flash}
  <section class="panel">
    <div class="panel-heading">
    	<span class="lead">{'Edit Profile'|i18n}</span>
    </div>
    <div class="panel-body">
			<form id="profile" method="post" class="form-horizontal" action="{href}" autocomplete="off" data-frwk-validation="user_model::default" data-frwk-submitfn="save" data-frwk-mode="upd">
				<div class="alert alert-error x-form_errors" style="display: none;"></div>
				<div class="control-group form-group">
				  <label for="first_name" class="control-label col-lg-2">{'First name'|i18n}</label>
					<div class="controls col-lg-10">
						<input type="text" id="first_name" name="first_name" value="{$first_name}" class="form-control" maxlength="32" placeholder="First name">
					</div>
				</div>
				<div class="control-group form-group">
				  <label for="last_name" class="control-label col-lg-2">{'Last name'|i18n}</label>
					<div class="controls col-lg-10">
						<input type="text" id="last_name" name="last_name" value="{$last_name}" class="form-control" maxlength="32" placeholder="Last name">
					</div>
				</div>
				<div class="control-group form-group">
				  <label for="email" class="control-label col-lg-2">{'E-mail'|i18n}</label>
					<div class="controls col-lg-10">
						<input type="text" id="email" name="email" value="{$email}" class="form-control" maxlength="64" placeholder="E-mail">
					</div>
				</div>
				<div class="control-group form-group">
				  <label for="password" class="control-label col-lg-2">{'New password'|i18n}</label>
					<div class="controls col-lg-10">
						<input type="password" id="password" name="password" class="form-control" maxlength="32" placeholder="New password">
					</div>
				</div>
				<div class="control-group form-group">
				  <label for="password_retype" class="control-label col-lg-2">{'Retype new password'|i18n}</label>
					<div class="controls col-lg-10">
						<input type="password" id="password_retype" name="password_retype" class="form-control" maxlength="32" placeholder="Retype new password">
					</div>
				</div>
        <div class="form-group">
          <div class="col-lg-offset-2 col-lg-10">
            <input type="submit" value="{'Save Changes'|i18n}" class="btn btn-primary">
          </div>
        </div>
				<span class="x-state x-state_loading" style="display: none;">
					<img src="{$BASE}/img/ajax-loader.gif">
					{'Please wait...'|i18n}
				</span>
				<span class="x-state x-state_success" style="display: none;">
					<i class="icon-ok"></i>
					{'Saved!'|i18n}
				</span>
			</form>
    </div>
  </section>
</section>
{/block}
{block name='foot' append}
<script type="text/javascript" src="{$BASE}/lib/frwk/js/forms.js"></script>
<script type="text/javascript">
	function save($form) {
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
{show_errors form='profile' errors=$errors}
{/block}

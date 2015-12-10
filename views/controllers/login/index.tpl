{extends 'layouts/index.tpl'}
{block name='content'}
<div class="container">
  <form id="login" method="post" action="{href}" class="form-signin" data-frwk-validation="login">
    <h2 class="form-signin-heading">Login Now</h2>
    <div class="login-wrap">
    	{if $failed}
    	<div class="alert alert-error">{'Wrong e-mail/password combination.'|i18n}</div>
    	{/if}
    	<div class="control-group">
    		<div class="controls">
    			<input type="text" id="email" name="email" value="{$email}" class="form-control" placeholder="E-mail">
    		</div>
    	</div>
    	<div class="control-group">
    		<div class="controls">
    			<input type="password" id="password" name="password" value="{$password}" class="form-control" placeholder="Password">
    		</div>
    	</div>
    	<label class="checkbox">
    		<input type="checkbox" id="remember_me" name="remember_me" value="Y">
    		{'Remember me'|i18n}
        <span class="pull-right">
          <a data-toggle="modal" href="#myModal">Forgot Password?</a>
        </span>
    	</label>
      <button class="btn btn-lg btn-login btn-block" type="submit">Login</button>
    </div>
  </form>
  <form id="forgot_password" method="post" action="{href action='forgot-password'}" class="form-signin" data-frwk-validation="forgot_password" data-frwk-submitfn="forgot_password">
    <div aria-hidden="true" aria-labelledby="myModalLabel" role="dialog" tabindex="-1" id="myModal" class="modal fade">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
            <h4 class="modal-title">Forgot Password?</h4>
          </div>
          <div class="modal-body">
            <p>Enter your e-mail address below to reset your password.</p>
            <div class="control-group">
              <div class="controls">
                <input type="text" name="email" placeholder="Email" autocomplete="off" class="form-control placeholder-no-fix">
                <p class="help-block x-state x-state_loading" style="display: none;">
                  <img src="{$BASE}/img/ajax-loader.gif">
                  {'Please wait...'|i18n}
                </p>
                <p class="help-block x-state x-state_success" style="display: none;">
                  <i class="icon-ok"></i>
                  {'E-mail sent!'|i18n}
                </p>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button data-dismiss="modal" class="btn btn-default" type="button">Cancel</button>
            <button class="btn btn-success" type="submit">Submit</button>
          </div>
        </div>
      </div>
    </div>
  </form>
</div>
{/block}
{block name='foot' append}
<script type="text/javascript" src="{$BASE}/lib/frwk/js/forms.js"></script>
<script type="text/javascript">
  function forgot_password() {
    FRWK.Forms.ajax_submit(this, function(json) {
    });

    return false;
  }
</script>
{/block}

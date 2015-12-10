{extends 'layouts/front.tpl'}
{block name='content'}
<section class="wrapper">
  <section class="panel">
    <div class="panel-heading">
	    <span class="lead">{if $id gt 0}{'Update'|i18n} {$u_name} - {$name}{else}{'Create'|i18n} {$u_name}{/if}</span>
    </div>
    <div class="panel-body">
    	<form id="creupd" method="post" class="form-horizontal" autocomplete="off" data-frwk-validation="user_model::default" data-frwk-submitfn="creupd" {if $id gt 0}data-frwk-mode="upd"{/if}>
    		<input type="hidden" name="mode" value="creupd">
    		<fieldset>
          {if $id > 0}
    			<div class="control-group form-group">
    				<label for="status" class="control-label col-lg-2 col-sm-2">{'User type'|i18n}</label>
    				<div class="controls col-lg-10">
    					<select id="user_type" name="user_type" class="form-control">
    						{html_options options=$user_type_opt selected=$user_type}
    					</select>
    				</div>
    			</div>
          {/if}
    			<div class="control-group form-group">
    				<label for="first_name" class="control-label col-lg-2 col-sm-2">{'First name'|i18n}</label>
    				<div class="controls col-lg-10">
    					<input type="text" id="first_name" name="first_name" value="{$first_name}" maxlength="32" class="form-control">
    				</div>
    			</div>
    			<div class="control-group form-group">
    				<label for="last_name" class="control-label col-lg-2 col-sm-2">{'Last name'|i18n}</label>
    				<div class="controls col-lg-10">
    					<input type="text" id="last_name" name="last_name" value="{$last_name}" maxlength="32" class="form-control">
    				</div>
    			</div>
    			<div class="control-group form-group">
    				<label for="email" class="control-label col-lg-2 col-sm-2">{'E-mail'|i18n}</label>
    				<div class="controls col-lg-10">
    					<input type="text" id="email" name="email" value="{$email}" maxlength="64" class="form-control">
    				</div>
    			</div>
    			<div class="control-group form-group">
    				<label for="password" class="control-label col-lg-2 col-sm-2">{if $id gt 0}{'New password'|i18n}{else}{'Password'|i18n}{/if}</label>
    				<div class="controls col-lg-10">
    					<input type="password" id="password" name="password" value="" maxlength="32" class="form-control">
    				</div>
    			</div>
    			<div class="control-group form-group">
    				<label for="password_retype" class="control-label col-lg-2 col-sm-2">{if $id gt 0}{'Retype new password'|i18n}{else}{'Retype password'|i18n}{/if}</label>
    				<div class="controls col-lg-10">
    					<input type="password" id="password_retype" name="password_retype" value="" maxlength="32" class="form-control">
    				</div>
    			</div>
          <!--
    			{if $SESSION.user_info.root_access eq '1'}
    			<div class="control-group form-group">
    				<label for="root_access" class="control-label col-lg-2 col-sm-2">{'Root access'|i18n}</label>
    				<div class="controls col-lg-10">
    					<label class="checkbox">
    						<input type="checkbox" id="root_access" name="root_access" value="1" {if $root_access eq '1'}checked{/if}>
    						- {'Grant unlimited access to the entire application'|i18n}
    					</label>
    				</div>
    			</div>
    			{/if}
          -->
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
<script type="text/javascript">
	function creupd($form) {
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
{show_errors form='creupd' errors=$errors}
{/block}

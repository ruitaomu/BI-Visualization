<div class="permissions">
	<label class="radio-inline" style="padding-left: 0;">
		<input type="radio" name="star_permission" value="1" {if $star_permission eq 1}checked{/if}>
		&nbsp;{'All'|i18n}
	</label>
	<label class="radio-inline" style="padding-left: 0;">
		<input type="radio" name="star_permission" value="0" {if $star_permission ne 1}checked{/if}>
		&nbsp;{'Only selected permissions'|i18n}
	</label>
  <br><br>
	
	<div class="permission_list">
		{foreach $permission_list as $glabel => $plist}
			<dl>
				<dt class="hd"><label class="checkbox">
					<input type="checkbox">
					{$glabel}
				</label></dt>
				{foreach $plist as $plabel => $info}
					<dt><label class="checkbox">
						<input type="checkbox" name="permissions[]" value="{$plabel}" {if $permissions[$plabel]}checked{/if}>
			{$info.name}
					</label></dt>
				{/foreach}
			</dl>
		{foreachelse}
			{'No system permissions available.'|i18n}
		{/foreach}
	</div>
</div>

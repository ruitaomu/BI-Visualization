$(function() {
	$('div.permissions dt.hd input[type=checkbox]').click(function(e) {
		$el = $(this);
		$el.closest('dl').find('dt[class!=hd] input[type=checkbox]').prop('checked', $el.prop('checked'));
	});
	$('div.permissions dt[class!=hd] input[type=checkbox]').click(function(e) {
		$el = $(this);
		if (!$el.prop('checked')) {
			$el.closest('dl').find('dt.hd input[type=checkbox]').prop('checked', false);
		}
	});

	$('input[type=radio][name=star_permission]').click(function(e) {
		update_star_permission($(this).val());
	});

	var star_permission = null;
	function update_star_permission(new_star_permission) {
		if (star_permission == new_star_permission) return;
		star_permission = new_star_permission;

		if (star_permission == 1) {
			$('div.permission_list input[type=checkbox]').prop('disabled', true);
			$('div.permission_list').slideUp();
		}
		else {
			$('div.permission_list input[type=checkbox]').prop('disabled', false);
			$('div.permission_list').slideDown();
		}
	}

	update_star_permission($('input[type=radio][name=star_permission]:checked').val());
});

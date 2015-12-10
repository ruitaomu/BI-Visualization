(function() {
	$(function() {
		$('input[data-maxlength], textarea[data-maxlength]').each(function() {
			var $el = $(this),
					n = parseInt($el.attr('data-maxlength'));
			if (!isNaN(n)) init($el, n);
		});
	});

	function init($el, n) {
		var id = $el.attr('id'),
				$count_remaining = (id ? $('#' + id + '_chars_remaining') : null),
				$count = (id ? $('#' + id + '_chars') : null);

		if ($count_remaining && !$count_remaining.length) $count_remaining = null;
		if ($count && !$count.length) $count = null;
		
		$el.bind('keyup keydown', function() {
			update();
		});
		update();

		function update() {
			var v = $el.val(),
					l = v.length;
			
			if (l > n) {
				$el.val(v.substring(0, n));
			}
			else {
				if ($count_remaining) $count_remaining.html(n - l);
				if ($count) $count.html(l);
			}
		}
	}
})();

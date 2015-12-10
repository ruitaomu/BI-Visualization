/**
 * forms.js
 *
 ******************************************************************************/
(function() {
	var ns = window.FRWK,
			validation_rules = {};

	$(function() {
		enable();

	});

	/**
	 * Enable form validation for forms that have a "data-frwk-validation"
	 * attribute.
	 */
	function enable() {
		var $forms = $('form[data-frwk-validation]');
		
		$forms.each(function() {
			var $form = $(this),
					label = $form.attr('data-frwk-validation');

			if (!label) {
				return;
			}

			// re-submit the form when "refresh" select boxes are changed:
			$form.find('select[data-frwk-refresh=true]').change(function(e) {
				$form.find('#mode').val('refresh');
				$form.submit();
			});

			$form.submit(function(e) {
				clear_errors(this);

				// form submit due to a "refresh" field:
				if ($(this).find('#mode').val() == 'refresh') {
					return true;
				}

				if (validate(this)) {
					// if we have a submit function, pass control to it:
					var submitfn = $form.attr('data-frwk-submitfn');
					if (submitfn && typeof(window[submitfn]) == 'function') {
						return window[submitfn].call(this, $form);
					}
					// if we need to submit via AJAX:
					else if ($form.attr('data-frwk-ajaxsubmit') == 'true') {
						ajax_submit(this);
						return false;
					}
					// normal submit:
					else {
						return true;
					}
				}

				return false;
			});

			// download validation rules from server:
			if (typeof(validation_rules[label]) == 'undefined') {
				validation_rules[label] = false;
				var url = ns.BASE + '/frwk/validation-rules/';
				$.getJSON(url, {'label': label}, function(json) {
					validation_rules[label] = json;
				});
			}
		});
	}

	/**
	 * Validate a form.
	 */
	function validate(form) {
		var $form = $(form),
				label = $form.attr('data-frwk-validation');

		// no validation rules:
		if (!label || !validation_rules[label]) {
			return true;
		}

		// put all form fields in a hash:
		var hash = {},
				arr = $form.serializeArray();

		for (var i = 0; i < arr.length; i++) {
			hash[arr[i].name] = arr[i].value;
		}

		var errors = null;
		if ($form.attr('data-frwk-mode') == 'upd') {
			errors = validate_hash_to_rules(hash, validation_rules[label]);
		}
		else {
			errors = validate_rules_to_hash(hash, validation_rules[label]);
		}

		if (errors) {
			show_errors(form, get_error_messages(errors, validation_rules[label]));
		}

		return (errors === null);
	}

	/**
	 * Submit a form via AJAX.
	 */
	function ajax_submit(form, callback) {
		var $form = $(form),
				action = $form.attr('action'),
				method = $form.attr('method');

		clear_errors(form);

		var $submit = $form.find('input[type=submit]').prop('disabled', true);
		$form.find('.x-state').hide();
		var $loading = $form.find('.x-state_loading').show();

		$.ajax({
			'type': (method && method.toLowerCase() == 'post' ? 'POST' : 'GET'),
			'url': action,
			'data': $form.serializeArray(),
			'dataType': 'json',

			'success': function(json) {
				if (json) {
					if (json.ok) {
						$form.find('.x-state_success').show();
					}
					else {
						show_errors(form, json.errors);
					}
				}

				if (callback) {
					callback.call(form, json);
				}
			},

			'complete': function() {
				$loading.hide();
				$submit.prop('disabled', false);
			}
		});
	}

	/**
	 * Show form errors.
	 */
	function show_errors(form, errors) {
    console.log(errors);
		if (typeof(errors) == 'object') {
			for (var field in errors) {
				for (var test in errors[field]) {
					show_field_error(form, field, errors[field][test]);
				}
			}
		}
		else if (errors) {
			$(form).find('.x-form_errors').html(errors).show();
		}
	}

	/**
	 * Show errors on a field from a form.
	 */
	function show_field_error(form, field, message) {
		var $form = $(form),
				$field = $form.find('[name=' + field + ']');

		$field.closest('div.control-group').addClass('error has-error');

		var html = '<p class="help-block x-error">' + message + '</p>';
		$field.closest('div.controls').append(html);
	}

	/**
	 * Clear form errors.
	 */
	function clear_errors(form) {
		var $form = $(form);

		$form.find('div.control-group').removeClass('error has-error');
		$form.find('.x-error').remove();
		$form.find('.x-form_errors').empty().hide();
	}

	/**
	 * Get error messages from validation rules.
	 */
	function get_error_messages(err, rules) {
		if (typeof(err) == 'object') {
			var errors = {};
			for (var field in err) {
				errors[field] = {};
				var error_message = '';
				if (rules[field][err[field]]['error_message']) {
					error_message = rules[field][err[field]]['error_message'];
				}
				errors[field][err[field]] = error_message;
			}
			return errors;
		}
		return err;
	}

	/**
	 * Make sure the rules are satisfied by the hash.
	 */
	function validate_rules_to_hash(hash, rules) {
		var errors = {}, field, value, name, params;

		for (field in rules) {
			value = (typeof(hash[field]) != 'undefined' ? hash[field] : null);
			for (name in rules[field]) {
				params = rules[field][name];
				if (!is_valid(value, name, params)) {
					errors[field] = name;
					break;
				}
			}
		}
		return (!$.isEmptyObject(errors) ? errors : null);
	}

	/**
	 * Make sure the hash satisfies the rules.
	 */
	function validate_hash_to_rules(hash, rules) {
		var errors = {}, field, value, name, params;

		for (field in hash) {
			if (typeof(rules[field]) == 'undefined') continue;
			for (name in rules[field]) {
				params = rules[field][name];

				if (params['skip_on_update']) {
					continue;
				}

				if (!is_valid(hash[field], name, params)) {
					errors[field] = name;
					break;
				}
			}
		}
		return (!$.isEmptyObject(errors) ? errors : null);
	}

	/**
	 * Validate a value against a test.
	 */
	function is_valid(value, test_name, test_params) {
		if (typeof(tests[test_name]) == 'function') {
			return tests[test_name](value, test_params);
		}

		// if unknown test, ignore it:
		return true;
	}

	//////////////////////////////////////////////////////////////////////////////
	//
	// Validation Tests
	//
	//////////////////////////////////////////////////////////////////////////////

	var tests = {
		'required': function(value, params) {
			return ($.trim(value) != '');
		},

		'alpha': function(value, params) {
			return !this.regexp(value, {'regexp': /[^a-z]/i});
		},

		'numeric': function(value, params) {
			if (this.regexp(value, {'regexp': /[^0-9\.\+\-e]/i})) return false;
			value *= 1;
			if (typeof(params['min']) != 'undefined' && value < params['min']) {
				return false;
			}
			if (typeof(params['max']) != 'undefined' && value > params['max']) {
				return false;
			}
			return true;
		},

		'alphanumeric': function(value, params) {
			return !this.regexp(value, {'regexp': /[^a-z0-9]/i});
		},

		'email': function(value, params) {
			return this.regexp(value, {
				'regexp': /^[a-z0-9,!#\$%&'\*\+\/=\?\^_`\{\|}~-]+(\.[a-z0-9,!#\$%&'\*\+\/=\?\^_`\{\|}~-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*\.([a-z]{2,})$/i
			});
		},

		'regexp': function(value, params) {
			var re = params['regexp'];
			if (typeof(re) == 'string') {
				var matches = re.match(/^\/(.+)\/(.*)$/);
				if (matches) {
					re = new RegExp(matches[1], matches[2]);
				}
			}
			return re.test(value);
		}
	};

	//////////////////////////////////////////////////////////////////////////////
	//
	// API
	//
	//////////////////////////////////////////////////////////////////////////////

	ns.Forms = {};

	ns.Forms.show_errors = function(form, errors) {
		if (typeof(form) == 'string') form = document.getElementById(form);
		show_errors(form, errors);
	};

	ns.Forms.clear_errors = function(form) {
		if (typeof(form) == 'string') form = document.getElementById(form);
		clear_errors(form);
	};

	ns.Forms.ajax_submit = function(form, callback) {
		if (typeof(form) == 'string') form = document.getElementById(form);
		ajax_submit(form, callback);
	};
})();

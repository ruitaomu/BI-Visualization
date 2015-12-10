<?php
/**
 * Data Validation Rules
 *
 ******************************************************************************/

$CFG['VALIDATION'] = array(
	// login form:
	'login' => array(
		'email' => array(
			'required',
			'email'
		),
		'password' => array(
			'required'
		)
	),

	// forgot password form:
	'forgot_password' => array(
		'email' => array(
			'required',
			'email'
		)
	),

	// reset password form:
	'reset_password' => array(
		'password' => array(
			'required'
		)
	),

	// change e-mail (on profile page):
	'change_email' => array(
		'email' => array(
			'required',
			'email'
		)
	),

	// change password form (on profile page):
	'change_password' => array(
		'current_password' => array(
			'required'
		),
		'password' => array(
			'required'
		),
		'password_retype' => array(
			'required'
		)
	)
);

/**
 * Default parameters for validation tests.
 */
$CFG['VALIDATION_DEFAULTS'] = array(
	'required' => array(
		'error_message' => 'This field is required.'
	),
	'email' => array(
		'error_message' => 'This field must be an e-mail address.'
	)
);

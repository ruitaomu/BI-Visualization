<?php
/**
 * Framework Default Configuration
 *
 ******************************************************************************/

// current environment:
$CFG['ENV'] = 'development';

// current theme:
$CFG['THEME'] = '';

// application URL:
list($CFG['BASE_URL'], $CFG['ROOT_URL']) = utils::get_app_url();

////////////////////////////////////////////////////////////////////////////////
//
// Framework Defaults
//
////////////////////////////////////////////////////////////////////////////////
$CFG['FRWK'] = array();

/**
 * Auth
 */
$CFG['FRWK']['AUTH'] = array(
	'require_user' => array(
		'redirect_to' => array('module' => '', 'controller' => 'login')
	),

	'require_permissions' => array(
		'redirect_to' => array('controller' => 'dashboard')
	)
);

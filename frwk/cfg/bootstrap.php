<?php
/**
 * Framework Bootstrap
 *
 ******************************************************************************/

/**
 * Load framework files.
 */
require_once($CFG['FRWK_DIR'] . '/lib/auth.class.php');
require_once($CFG['FRWK_DIR'] . '/lib/controller.class.php');
require_once($CFG['FRWK_DIR'] . '/lib/db.class.php');
require_once($CFG['FRWK_DIR'] . '/lib/framework.class.php');
require_once($CFG['FRWK_DIR'] . '/lib/model.class.php');
require_once($CFG['FRWK_DIR'] . '/lib/params.class.php');
require_once($CFG['FRWK_DIR'] . '/lib/plugin.class.php');
require_once($CFG['FRWK_DIR'] . '/lib/plugin_manager.class.php');
require_once($CFG['FRWK_DIR'] . '/lib/response.class.php');
require_once($CFG['FRWK_DIR'] . '/lib/router.class.php');
require_once($CFG['FRWK_DIR'] . '/lib/session.class.php');
require_once($CFG['FRWK_DIR'] . '/lib/utils.class.php');
require_once($CFG['FRWK_DIR'] . '/lib/validation.class.php');
require_once($CFG['FRWK_DIR'] . '/lib/view.class.php');
require_once($CFG['FRWK_DIR'] . '/lib/web_request.class.php');
//require_once($CFG['FRWK_DIR'] . '/lib/.class.php');

/**
 * Load framework default configuration.
 */
require_once($CFG['FRWK_DIR'] . '/cfg/config.php');

/**
 * Set include path.
 */
utils::ins_include_path(
	$CFG['ROOT_DIR'],
	$CFG['ROOT_DIR'] . '/include'
);

////////////////////////////////////////////////////////////////////////////////
//
// Global Functions
//
////////////////////////////////////////////////////////////////////////////////

/**
 * Class auto-loading.
 */
spl_autoload_register(function($class) {
	global $CFG, $FRWK_AUTOLOAD_SILENT;

	$type = 'class';
	$name = $class;

	if (preg_match('/_(model)$/', $class, $matches)) {
		$name = preg_replace('/_(model)$/', '', $class);
		$file = "$matches[1]s/$name.class.php";
		$type = $matches[1];
	}
	else {
		$file = "$class.class.php";
	}

	if (!(@include_once($file)) && $type == 'model') {
		if (!isset($FRWK_AUTOLOAD_SILENT) || $FRWK_AUTOLOAD_SILENT !== true) {
			throw response::http404(array(
				'class' => array(
					'type' => $type, 'name' => $name, 'class' => $class, 'file' => $file
				)
			));
		}
	}
});

/**
 * Get database table names from configuration.
 */
function tb($name) {
	global $CFG;

	$cfgname = 'DBTABLE_' . strtoupper(preg_replace('/[^a-z0-9]/i', '', $name));
	return (isset($CFG[$cfgname]) ? $CFG[$cfgname] : $name);
}

/**
 * i18n support.
 */
if (!function_exists('_')) {
  function _($msg) {
    return $msg;
  }
}

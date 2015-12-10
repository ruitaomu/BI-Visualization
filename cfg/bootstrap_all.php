<?php
/**
 * Application Bootstrap
 *
 ******************************************************************************/

/**
 * Load configuration.
 */

// basic settings:
$CFG['ROOT_DIR'] = dirname(dirname(__FILE__));
$CFG['FRWK_DIR'] = $CFG['ROOT_DIR'] . '/frwk';
$CFG['BASE_DIR'] = $CFG['ROOT_DIR'] . '/webroot';

// framework:
require_once($CFG['FRWK_DIR'] . '/cfg/bootstrap.php');

// framework customizations:
require_once($CFG['ROOT_DIR'] . '/cfg/frwk.php');

// application specific settings:
require_once($CFG['ROOT_DIR'] . '/cfg/config.php');
require_once($CFG['ROOT_DIR'] . '/cfg/db.php');
require_once($CFG['ROOT_DIR'] . '/cfg/permissions.php');
require_once($CFG['ROOT_DIR'] . '/cfg/validation.php');

// environment specific overrides:
include_once($CFG['ROOT_DIR'] . '/cfg/env.php');
require_once($CFG['ROOT_DIR'] . "/cfg/environment_$CFG[ENV].php");

// domain specific overrides:
//require_once($CFG['ROOT_DIR'] . '/cfg/domains/bootstrap.php');
//load_domain_cfg('config.php');

// routing rules:
require_once($CFG['ROOT_DIR'] . '/cfg/urls.php');

// domain specific routing rules overrides:
//load_domain_cfg('urls.php');

// local overrides:
include_once($CFG['ROOT_DIR'] . '/cfg/local.php');

/**
 * Additional includes (application specific).
 */
require_once($CFG['ROOT_DIR'] . '/cfg/includes.php');

/**
 * Create framework object.
 */
$frwk = framework::get();

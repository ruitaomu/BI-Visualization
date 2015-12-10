<?php
/**
 * Application Bootstrap (WEB requests)
 *
 ******************************************************************************/

$CFG = array('MODE' => 'web');
require_once(dirname(__FILE__) . '/bootstrap_all.php');

$frwk->handle_web();

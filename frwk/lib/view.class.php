<?php
/**
 * view.class.php
 *
 ******************************************************************************/
require_once(dirname(__FILE__) . '/view/smarty/smarty_view.class.php');

class view {
	/**
	 * View instances.
	 * @var array
	 */
	private static $instances = array();


	/**
	 * Constructor (singleton).
	 */
	private function __construct() {
	}

	/**
	 * Get view instance.
	 *
	 * @param $class string Name of the view class
	 * @return object
	 */
	public static function get($class = 'smarty_view') {
		switch ($class) {
		case 'smarty_view':
			if (!isset(self::$instances[$class])) {
				self::$instances[$class] = new smarty_view();
			}
			return self::$instances[$class];
		default:
			return null;
		}
	}
}

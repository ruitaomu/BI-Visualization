<?php
/**
 * db.class.php
 *
 ******************************************************************************/
require_once(dirname(__FILE__) . '/db/db_mysql.class.php');

class db {
	/**
	 * Active database connections.
	 */
	public static $db_conn = array();


	/**
	 * Constructor (singleton).
	 */
	private function __construct() {
	}

	/**
	 * Create a database connection.
	 *
	 * @param $p array Connection parameters.
	 * @return object
	 */
	public static function create($p) {
		switch ($p['type']) {
		case 'mysql':
			return new db_mysql($p['name'], $p['user'], $p['pass'], $p['host']);
		default:
			return null;
		}
	}

	/**
	 * Get a database connection.
	 *
	 * @param $label string The connection label.
	 * @return object
	 */
	public static function get($label = 'default') {
		global $CFG;

		if (!isset(self::$db_conn[$label])) {
			if (isset($CFG['DB'][$label])) {
				self::$db_conn[$label] = self::create($CFG['DB'][$label]);
			}
			else {
				self::$db_conn[$label] = null;
			}
		}

		return self::$db_conn[$label];
	}
}

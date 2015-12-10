<?php
/**
 * params.class.php
 *
 ******************************************************************************/

class params {
	/**
	 * Constructor.
	 */
	public function __construct() {
	}

	/**
	 * __get.
	 */
	public function __get($name) {
		return $this->get($name);
	}

	/**
	 * Getter.
	 */
	public function get($name, $default = null) {
		return (isset($_REQUEST[$name]) ? $_REQUEST[$name] : $default);
	}

	/**
	 * Get a list of parameters, if they were set in the request.
	 */
	public function get_if_set() {
		$args = func_get_args();

		$result = array();
		foreach ($args as $arg) {
			if (isset($_REQUEST[$arg])) {
				$result[$arg] = $_REQUEST[$arg];
			}
		}
		return $result;
	}

	/**
	 * Get all parameters as an array.
	 */
	public function all() {
		return $_REQUEST;
	}
}

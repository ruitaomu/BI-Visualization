<?php
/**
 * session.class.php
 *
 ******************************************************************************/

class session {
	/**
	 * Flash variables.
	 * @var array
	 */
	protected $flash_vars = array();


	/**
	 * Constructor (singleton).
	 */
	private function __construct() {
		if (!session_start()) {
			die('Error: could not start session.');
		}
	}

	/**
	 * Destructor.
	 */
	public function __destruct() {
		if (isset($_SESSION['__flash_vars'])) {
			foreach ($_SESSION['__flash_vars'] as $name => $_) {
				if (!isset($this->flash_vars[$name])) {
					unset($_SESSION[$name]);
				}
			}
		}
		$_SESSION['__flash_vars'] = $this->flash_vars;
	}
	
	//////////////////////////////////////////////////////////////////////////////
	//
	// Magic Methods
	//
	//////////////////////////////////////////////////////////////////////////////

	public function __set($name, $value) {
		$this->set($name, $value);
	}

	public function __get($name) {
		return $this->get($name);
	}

	//////////////////////////////////////////////////////////////////////////////
	//
	// Setters & Getters
	//
	//////////////////////////////////////////////////////////////////////////////

	/**
	 * Set a session variable.
	 */
	public function set($name, $value = null) {
		$_SESSION[$name] = $value;
	}

	/**
	 * Set a flash session variable.
	 */
	public function flash($name, $value = null) {
		if (1 == func_num_args()) {
			$value = $name;
			$name = 'flash';
		}

		$this->set($name, $value);
		$this->flash_vars[$name] = true;
	}

	/**
	 * Get a session variable.
	 */
	public function get($name = null, $default = null) {
		if ($name) {
			return (isset($_SESSION[$name]) ? $_SESSION[$name] : $default);
		}
		else {
			return $_SESSION;
		}
	}

	//////////////////////////////////////////////////////////////////////////////
	//
	// Session Methods
	//
	//////////////////////////////////////////////////////////////////////////////

	/**
	 * Destroy the session.
	 */
	public function destroy() {
		session_destroy();
	}

	//////////////////////////////////////////////////////////////////////////////
	//
	// Static
	//
	//////////////////////////////////////////////////////////////////////////////

	private static $instance = null;

	/**
	 * Get session instance.
	 */
	public static function &get_instance() {
		if (is_null(self::$instance)) {
			self::$instance = new session();
		}
		return self::$instance;
	}
}

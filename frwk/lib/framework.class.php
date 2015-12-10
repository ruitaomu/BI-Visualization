<?php
/**
 * framework.class.php
 *
 ******************************************************************************/

class framework {
	/**
	 * Configuration options.
	 * @var array
	 */
	public $cfg = null;

	/**
	 * Request.
	 * @var object
	 */
	public $req;

	/**
	 * Plugin manager.
	 * @var object
	 */
	public $pm;

	/**
	 * Functions registered at runtime.
	 * @var array
	 */
	public $func = array();


	/**
	 * Constructor (singleton).
	 */
	private function __construct() {
		global $CFG;

		$this->cfg =& $CFG;
		$this->pm = new plugin_manager($this);
	}

	//////////////////////////////////////////////////////////////////////////////
	//
	// Magic Methods
	//
	//////////////////////////////////////////////////////////////////////////////
	
	/**
	 * Getter for registered plugins.
	 */
	public function __get($name) {
		return (isset($this->plugins[$name]) ? $this->plugins[$name] : null);
	}

	/**
	 * Call functions registered at runtime.
	 */
	public function __call($name, $args) {
		if (isset($this->func[$name])) {
			return call_user_func_array($this->func[$name], $args);
		}
		return null;
	}

	//////////////////////////////////////////////////////////////////////////////
	//
	// Request Handlers
	//
	//////////////////////////////////////////////////////////////////////////////
	
	/**
	 * Handle a web request.
	 */
	public function handle_web() {
		$this->req = new web_request($this);
		$this->req->handle();
	}

	//////////////////////////////////////////////////////////////////////////////
	//
	// Database
	//
	//////////////////////////////////////////////////////////////////////////////

	public function db($label = 'default') {
		return db::get($label);
	}

	//////////////////////////////////////////////////////////////////////////////
	//
	// Session
	//
	//////////////////////////////////////////////////////////////////////////////

	public function session() {
		return session::get_instance();
	}

	//////////////////////////////////////////////////////////////////////////////
	//
	// Static
	//
	//////////////////////////////////////////////////////////////////////////////

	private static $instance = null;

	/**
	 * Get framework instance.
	 */
	public static function &get() {
		if (is_null(self::$instance)) {
			self::$instance = new framework();
		}
		return self::$instance;
	}
}

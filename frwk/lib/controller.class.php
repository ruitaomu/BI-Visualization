<?php
/**
 * controller.class.php
 *
 ******************************************************************************/

class controller {
	/**
	 * Framework reference.
	 * @var object
	 */
	public $frwk;

	/**
	 * Controller info.
	 * @var array
	 */
	protected $info;

	/**
	 * Request.
	 * @var object
	 */
	public $req;

	/**
	 * Params.
	 * @var object
	 */
	public $params;

	/**
	 * View variables.
	 * @var array
	 */
	public $vars = array();

	/**
	 * Controller attributes.
	 * @var array
	 */
	protected $attr = array();

	/**
	 * Functions registered at runtime.
	 * @var array
	 */
	protected $func = array();


	/**
	 * Constructor.
	 */
	public function __construct($info) {
		$this->frwk = framework::get();
		$this->info = $info;

		// shortcuts:
		$this->req =& $this->frwk->req;
		$this->params =& $this->frwk->req->params;

		// set controller's name:
		$this->name = preg_replace('/_controller$/', '', get_class($this));
	}

	//////////////////////////////////////////////////////////////////////////////
	//
	// Magic Methods
	//
	//////////////////////////////////////////////////////////////////////////////

	/**
	 * Set an attribute.
	 */
	public function __set($name, $value) {
		$this->attr[$name] = $value;
	}

	/**
	 * Get an attribute or send request to the framework.
	 */
	public function __get($name) {
		if (isset($this->attr[$name])) {
			return $this->attr[$name];
		}
		else {
			return $this->frwk->{$name};
		}
	}

	/**
	 * Call a runtime function or send request to the framework.
	 */
	public function __call($name, $args) {
		if (isset($this->func[$name])) {
			$callback = $this->func[$name];
		}
		else {
			$callback = array($this->frwk, $name);
		}
		
		return call_user_func_array($callback, $args);
	}

	//////////////////////////////////////////////////////////////////////////////
	//
	// Controller Methods
	//
	//////////////////////////////////////////////////////////////////////////////

	/**
	 * Init. This is called before the action.
	 */
	public function init() {
	}

	/**
	 * Database.
	 */
	public function db($label = 'default') {
		return $this->frwk->db($label);
	}

	/**
	 * Session.
	 */
	public function session() {
		return $this->frwk->session();
	}

	/**
	 * Set a variable to be used on the view layer.
	 */
	public function set($name, $value = true) {
		if (!is_array($name)) {
			$this->vars[$name] = $value;
		}
		else {
			$this->vars = $name + $this->vars;
		}
	}

	/**
	 * Get a variable previously set using set() above.
	 */
	public function get($name, $default = null) {
		return (isset($this->vars[$name]) ? $this->vars[$name] : $default);
	}

	/**
	 * Pass request parameters to the view layer.
	 */
	public function pass() {
		$args = func_get_args();
		if (count($args)) {
			foreach ($args as $arg) {
				if (is_array($arg)) {
					foreach ($arg as $name => $default) {
						$value = $this->params->get($name, $default);
						$this->set($name, $value);
					}
				}
				else {
					$value = $this->params->get($arg);
					if (!is_null($value)) {
						$this->set($arg, $value);
					}
				}
			}
		}
		else {
			$this->set($this->req->params->all());
		}
	}

	/**
	 * Attribute setter & getter.
	 */
	public function attr() {
		return utils::attr($this->attr, func_get_args());
	}

	/**
	 * Render the view.
	 */
	public function render() {
		// path to the view file:
		$path = implode('', array(
			$this->frwk->cfg['ROOT_DIR'], '/views/controllers',
			(!empty($this->info['module']) ? '/' . $this->info['module'] . '/' : '/'),
			$this->name, '/', $this->view
		));

		$view = view::get();
		return $view->render($path, $this->vars);
	}

	/**
	 * Redirect.
	 */
	public function redirect($p = null) {
		utils::redirect($p);
	}
}

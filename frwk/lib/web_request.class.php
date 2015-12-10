<?php
/**
 * web_request.class.php
 *
 ******************************************************************************/

class web_request {
	/**
	 * Framework reference.
	 * @var object
	 */
	public $frwk;

	/**
	 * Controller for this request.
	 * @var object
	 */
	public $controller_info;
	public $controller;

	/**
	 * Controller response.
	 * @var mixed
	 */
	public $res;

	/**
	 * HTTP request method.
	 * @var string
	 */
	public $http_method;

	/**
	 * Request path.
	 * @var string
	 */
	public $path;

	/**
	 * Array with request properties.
	 * @var array
	 */
	public $prop = array();

	/**
	 * Request parameters.
	 * @var object
	 */
	public $params;


	/**
	 * Constructor.
	 */
	public function __construct($frwk) {
		$this->frwk = $frwk;
		$this->params = new params();

		$this->request_prop();
	}

	/**
	 * Handle.
	 */
	public function handle() {
		try {
			$this->res = $this->run();
		}
		catch (Exception $e) {
			$this->res = $e;
		}

		$this->out();
	}

	/**
	 * Run.
	 */
	private function run() {
		// find a controller for this request:
		if (!is_array($this->controller_info = router::get_info($this->path))) {
			return response::http404(array('route' => array()));
		}

		// run controller:
		if (is_null($res = $this->run_controller())) {
			// render a view:
			return $this->controller->render();
		}

		return $res;
	}

	/**
	 * Out.
	 */
	private function out() {
		$res = $this->res;

		while ($res instanceof response) {
			$res = $res->out();
		}

		if (!is_null($res)) {
			if ($this->prop['ajax']) {
				$callback = $this->params->callback;
				$json = json_encode($res);
				echo (!empty($callback) ? "$callback($json);" : $json);
			}
			else {
				echo $res;
			}
		}
	}

	/**
	 * Run the controller for this request.
	 */
	public function run_controller() {
		// load:
		if (!$this->load_controller()) {
			return response::http404(array('controller' => $this->controller_info));
		}

		// find appropriate action to call, based on request properties:
		$ci = $this->controller_info;
		$plist = array();
		if ($this->prop['ajax']) {
			$plist[] = "$ci[action]_{$this->http_method}_ajax";
			$plist[] = "$ci[action]_ajax";
		}
		$plist[] = "$ci[action]_{$this->http_method}";
		$plist[] = $ci['action'];

		foreach ($plist as $action) {
			if (method_exists($this->controller, "action_$action")) {
				$this->controller->action = $this->controller->view = $action;
				break;
			}
		}

		// no action found:
		if (!$this->controller->action) {
			return response::http404(array('action' => $this->controller_info));
		}

		// execute controller init logic:
		$this->controller->init();

		//
		// -- HOOK -- BEFORE RUN ACTION
		//
		//$this->frwk->plugin_run_callback(framework::$HOOK_BEFORE_RUN_ACTION, $this->controller);

		// execute action and return response:
		return call_user_func_array(
			array($this->controller, "action_$action"),
			$this->controller_info['args']
		);
	}

	/**
	 * Load controller.
	 */
	private function load_controller() {
		$ci = $this->controller_info;

		$path = implode('', array(
			$this->frwk->cfg['ROOT_DIR'], '/controllers',
			(!empty($ci['module']) ? '/' . $ci['module'] . '/' : '/'),
			$ci['controller'] . '.class.php'
		));
		$class = $ci['controller'] . '_controller';

		if (!(@include($path))) {
			return false;
		}

		$this->controller = new $class($this->controller_info);

		return true;
	}

	/**
	 * Check request properties.
	 */
	public function is() {
		$props = func_get_args();
		foreach ($props as $prop) {
			if (!isset($this->prop[$prop]) || !$this->prop[$prop]) {
				return false;
			}
		}
		return true;
	}

	/**
	 * Determine all interesting request properties.
	 */
	private function request_prop() {
		// HTTP method:
		$this->http_method = strtolower($_SERVER['REQUEST_METHOD']);
		$this->prop[$this->http_method] = true;

		// check if this is an AJAX request:
		$is_ajax = false;
		if (!is_null($this->params->ajax)) {
			$is_ajax = true;
		}
		elseif (isset($_SERVER['HTTP_X_REQUESTED_WITH'])) {
			if (strtolower($_SERVER['HTTP_X_REQUESTED_WITH']) == 'xmlhttprequest') {
				$is_ajax = true;
			}
		}
		$this->prop['ajax'] = $is_ajax;

		// extract request path:
		list($path) = explode('?', $_SERVER['REQUEST_URI'], 2);
		$script = basename($_SERVER['SCRIPT_NAME']);
		$path = substr($path, strlen($this->frwk->cfg['BASE_URL']));
		$path = preg_replace("/^\/$script/", '', $path);
		$path = preg_replace('/\/+/', '/', $path);
		$this->path = preg_replace('/^\/|\/$/', '', $path);
	}
}

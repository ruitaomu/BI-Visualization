<?php
/**
 * plugin_manager.class.php
 *
 ******************************************************************************/

class plugin_manager {
	/**
	 * Framework reference.
	 * @var object
	 */
	public $frwk;

	/**
	 * Loaded plugins.
	 * @var array
	 */
	public $plugins = array();

	/**
	 * Registered callbacks.
	 * @var array
	 */
	public $callbacks = array();


	/**
	 * Plugin hooks.
	 */
	public static $HOOK_BEFORE_RUN_ACTION = 'before_run_action';


	/**
	 * Constructor.
	 */
	public function __construct($frwk) {
		$this->frwk = $frwk;
	}

	/**
	 * Load a plugin.
	 */
	public function load($plugin_info, $init_args = array()) {
		if (!(@include_once(utils::plugin_realpath($plugin_info['dir']) . "/$plugin_info[class].class.php"))) {
			throw response::http404(array('plugin' => $plugin_info));
		}
		$class = "$plugin_info[class]_plugin";
		$plugin = new $class($plugin_info);

		$id = call_user_func_array(array($plugin, 'init'), $init_args);
		if (is_null($id) && isset($plugin_info['id'])) {
			$id = $plugin_info['id'];
		}

		if (!empty($id)) {
			$this->plugins[$id] = $plugin;
		}

		return $plugin;
	}

	/**
	 * Add a plugin callback.
	 */
	public function add_callback($hook, $callback, $priority = 5) {
		$priority = max(0, min(5, $priority));
		if (!isset($this->plugin_callbacks[$hook])) $this->plugin_callbacks[$hook] = array_fill(0, 6, array());
		$this->plugin_callbacks[$hook][$priority][] = $callback;
	}

	/**
	 * Run plugin callbacks.
	 */
	public function run_callback() {
		$args = func_get_args();
		$hook = array_shift($args);
		if (isset($this->plugin_callbacks[$hook])) {
			for ($priority = 0; $priority <= 5; $priority++) {
				foreach ($this->plugin_callbacks[$hook][$priority] as $callback) {
					if (($res = call_user_func_array($callback, $args)) !== null) {
						return $res;
					}
				}
			}
		}
	}
}

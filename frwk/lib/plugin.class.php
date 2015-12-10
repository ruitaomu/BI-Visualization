<?php
/**
 * plugin.class.php
 *
 ******************************************************************************/

class plugin {
	/**
	 * Framework reference.
	 * @var object
	 */
	public $frwk;

	/**
	 * Plugin manager.
	 * @var object
	 */
	public $pm;

	/**
	 * Plugin info.
	 * @var array
	 */
	public $info;


	/**
	 * Constructor.
	 */
	public function __construct($plugin_info) {
	}

	/**
	 * Init.
	 */
	public function init($plugin_info) {
		$this->frwk = framework::get();
		$this->info = $plugin_info;

		$this->pm =& $this->frwk->pm;
	}

	/**
	 * Add a callback.
	 */
	protected function add_callback($hook, $method_name, $priority = 3) {
		$this->pm->add_callback($hook, array(&$this, $method_name), $priority);
	}
}

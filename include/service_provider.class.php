<?php
/**
 * service_provider.class.php
 *
 ******************************************************************************/

class service_provider {
	/**
	 * Service type.
	 * @var string
	 */
	public $type;

	/**
	 * Provider name.
	 * @var string
	 */
	public $provider_name;

	/**
	 * Provider interface / API.
	 * @var object
	 */
	public $provider;


	/**
	 * Constructor.
	 */
	public function __construct($type, $provider_name = null) {
		global $CFG;

		if (!$provider_name && isset($CFG[$type]['provider_name'])) {
			$provider_name = $CFG[$type]['provider_name'];
		}

		$this->provider = new $provider_name();
	}

	/**
	 * Proxy everything to the provider object.
	 */

	public function __set($name, $value) {
		$this->provider->$name = $value;
	}

	public function __get($name) {
		return $this->provider->$name;
	}

	public function __call($name, $args) {
		return call_user_func_array(array($this->provider, $name), $args);
	}
}

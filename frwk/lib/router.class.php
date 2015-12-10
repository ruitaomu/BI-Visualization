<?php
/**
 * router.class.php
 *
 ******************************************************************************/

class router {
	/**
	 * Configured routing rules.
	 * @var array
	 */
	private static $routing_rules;

	/**
	 * List of identifying controller properties and their default values.
	 * @var array
	 */
	public static $controller_props = array(
		'module' => '',
		'controller' => 'index',
		'action' => 'index'
	);


	/**
	 * Set routing rules.
	 */
	public static function set_rules($rules) {
		self::$routing_rules = (is_array($rules) ? $rules : array());
	}

	/**
	 * Add routing rules.
	 */
	public static function add_rules() {
		$args = func_get_args();
		$info = array_pop($args);
		for ($i = 0; $i < count($args); $i++) {
			self::$routing_rules[$args[$i]] = $info;
		}
	}

	/**
	 * Given an URL path return an info array.
	 */
	public static function get_info($path, $rules = null) {
		// use pre-defined rules if none specified:
		if (!$rules) $rules = (is_array(self::$routing_rules) ? self::$routing_rules : array());

		foreach ($rules as $regexp => $params) {
			$rule = self::prepare_for_get_info($regexp, $params);

			// we have a match:
			if (preg_match($rule['regexp'], $path, $matches)) {
				$controller_info = self::$controller_props;
				foreach ($controller_info as $k => $v) {
					if (isset($rule['params'][$k])) {
						$controller_info[$k] = self::get_param_from_matches($rule['params'][$k], $matches);
					}
					elseif (isset($matches[$k])) {
						$controller_info[$k] = $matches[$k];
					}
					$controller_info[$k] = preg_replace('/[^A-Za-z0-9]+/', '_', $controller_info[$k]);
				}

				// controller must exist:
				$controller_path = self::get_controller_path($controller_info);
				if (!is_file($controller_path)) {
					continue;
				}

				// save all matched parameters:
				$controller_info['params'] = array_slice($matches, 1);

				// save all arguments, if any:
				$path = preg_replace('/^\//', '', preg_replace($rule['regexp'], '', $path));
				$controller_info['args'] = (!empty($path) ? explode('/', $path) : array());

				return $controller_info;
			}
		}
	}

	/**
	 * Prepare a routing rule for usage in get_info().
	 */
	private static function prepare_for_get_info($regexp, $params) {
		$rule = array(
			'params' => (is_array($params) ? $params : array())
		);

		// transform pseudo-regexp into actual regexp:
		if (empty($regexp)) {
			$regexp = '/^$/';
		}
		elseif ($regexp[0] != '/') {
			$regexp = preg_replace('/\(:num:(\w+)\)/', "(?P<\\1>[\d]+)", $regexp);
			$regexp = preg_replace('/\(:any:(\w+)\)/', "(?P<\\1>[^/]+)", $regexp);

			$regexp = '/^' . str_replace('/', '\/', $regexp) . '$/';
		}
		$rule['regexp'] = $regexp;

		return $rule;
	}

	/**
	 * Given an info array return an URL path.
	 */
	public static function get_path($info) {
		foreach (self::$routing_rules as $regexp => $params) {
			$rule = self::prepare_for_get_path($regexp, $params);

			// check that all parameters specified in $info are
			// found either in rule params (and match) or rule vars:
			$sw = true;
			foreach ($info as $var => $value) {
				$sw_params = (isset($rule['params'][$var]) && $rule['params'][$var] == $value);
				$sw_vars = in_array($var, $rule['vars']);
				if (!$sw_params && !$sw_vars) {
					$sw = false;
					break;
				}
			}
			if (!$sw) continue;

			// generate path:
			$path = @preg_replace('/:(\w+)/e', "\$info['\\1']", $rule['regexp']);
			$path = preg_replace('/^\/|\/$/', '', preg_replace('/\/+/', '/', $path));
			return $path . '/';
		}
	}

	/**
	 * Prepare a routing rule for usage in get_path().
	 */
	private static function prepare_for_get_path($regexp, $params) {
		$rule = array(
			'params' => (is_array($params) ? $params : array()),
			'vars' => array()
		);

		// transform "(:<type>:<var>)" into ":<var>":
		$regexp = preg_replace('/\(:\w+:(\w+)\)/', ":\\1", $regexp);

		// find ":<var>" type placeholders:
		if (preg_match_all('/:(\w+)/', $regexp, $matches)) {
			foreach ($matches[1] as $var) $rule['vars'][] = $var;
		}

		// make sure required controller properties are either part of the
		// variables extracted from the rule regexp or hard-coded in $params,
		// otherwise place their default value in $params:
		foreach (self::$controller_props as $p => $default) {
			if (!isset($rule['params'][$p]) && !in_array($p, $rule['vars'])) {
				$rule['params'][$p] = $default;
			}
		}

		$rule['regexp'] = $regexp;
		return $rule;
	}

	private static function get_param_from_matches($param, &$matches) {
		if (is_int($param)) {
			$param = $matches[$param];
		}
		elseif ($param[0] == ':') {
			$param = $matches[str_replace(':', '', $param)];
		}

		return $param;
	}

	/**
	 * Get a path from a controller info array.
	 *
	 * @param $controller_info array
	 * @return string
	 */
	private static function get_controller_path($controller_info) {
		global $CFG;

		$path = $CFG['ROOT_DIR'] . '/controllers';
		if ($controller_info['module']) {
			$path .= '/' . $controller_info['module'];
		}
		$path .= '/' . $controller_info['controller'] . '.class.php';

		return $path;
	}
}

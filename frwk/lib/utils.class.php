<?php
/**
 * utils.class.php
 *
 ******************************************************************************/

class utils {
	/**
	 * Constructor (prevent instantiation).
	 */
	private function __construct() {
	}

	/**
	 * Insert new paths at the begining of the current include path, but keep
	 * current directory (.) first.
	 */
	public static function ins_include_path() {
		$ps = PATH_SEPARATOR;
		$path = preg_replace("/^\.$ps/", '', get_include_path());
		set_include_path(implode($ps, array(
			'.', implode($ps, func_get_args()), $path
		)));
	}

	/**
	 * Determine application's full URL and path on server (only works for web
	 * requests).
	 */
	public static function get_app_url() {
		if (!isset($_SERVER['SERVER_NAME']) || !isset($_SERVER['SERVER_PORT'])) {
			return array('', '');
		}

		// protocol:
		$prot = 'http://';
		if (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on') {
			$prot = 'https://';
		}

		// port:
		$default_port = ($prot == 'http://' ? 80 : 443);
		$port = $_SERVER['SERVER_PORT'];

		// path on server:
		$path = preg_replace('/^\/$/', '', dirname($_SERVER['SCRIPT_NAME']));

		// full URL:
		$full = implode('', array(
			$prot,
			$_SERVER['SERVER_NAME'],
			($port != $default_port ? ':' . $port : ''),
			$path
		));

		return array($path, $full);
	}

	/**
	 * Create an URL to an application controller/action or another location.
	 */
	public static function href($p = '', $query = null, $absolute = false) {
		global $CFG;

		$prefix = ($absolute ? $CFG['ROOT_URL'] : $CFG['BASE_URL']);

		if (is_string($p)) {
			if (empty($p)) {
				return $prefix . '/';
			}
			elseif ($p[0] == '/' || preg_match('/^(https?|ftp):\/\//i', $p)) {
				return $p;
			}
			else {
				return $prefix . '/' . $p;
			}
		}
		else {
			if (!is_array($p)) $p = array();
			$frwk = framework::get();

			$sw_module = true;
			if (!isset($p['module'])) {
				$p['module'] = $frwk->req->controller_info['module'];
				$sw_module = false;
			}

			if (!isset($p['controller'])) {
				if (!$sw_module) {
					$p['controller'] = $frwk->req->controller->name;
				}
			}

			$path = router::get_path($p);

			if (!is_null($query)) {
				if (is_array($query)) {
					$path .= '?' . http_build_query($query);
				}
				else {
					$path .= '?' . urlencode($query);
				}
			}

			return $prefix . '/' . $path;
		}
	}

	/**
	 * Redirect.
	 */
	public static function redirect($p) {
		throw response::redirect(self::href($p));
	}

	/**
	 * Implement set/get functionality for an attribute container.
	 */
	public static function attr(&$attr, $args) {
		$n = count($args);

		// if no arguments are passed, return all attributes:
		if (!$n) {
			return $attr;
		}

		// if the first argument is an array, set new attributes:
		if (is_array($args[0])) {
			foreach ($args[0] as $k => $v) {
				$attr[$k] = $v;
			}
			return;
		}

		// if at least 2 arguments, set a new attribute:
		if ($n > 1) {
			$attr[$args[0]] = $args[1];
			return;
		}

		// finally, return an attribute's value:
		if (isset($attr[$args[0]])) {
			return $attr[$args[0]];
		}
	}

	/**
	 * Strip slashes, go int each array element for arrays.
	 */
	public static function stripslashes_deep($v) {
		if (is_array($v)) {
			return array_map(array('utils', 'stripslashes_deep'), $v);
		}
		else {
			return stripslashes($v);
		}
	}

	/**
	 * Add slashes, go into each array element for arrays.
	 */
	public static function addslashes_deep($v) {
		if (is_array($v)) {
			return array_map(array('utils', 'addslashes_deep'), $v);
		}
		else {
			return addslashes($v);
		}
	}

	/**
	 * Make a HTTP POST request (using cURL).
	 */
	public static function http_post($url, $params = array(), $opt = array()) {
		$ch = curl_init();
		$op = $opt + array(
			CURLOPT_URL => $url,
			CURLOPT_POST => true,
			CURLOPT_POSTFIELDS => http_build_query($params, null, '&'),
			CURLOPT_RETURNTRANSFER => true,
			CURLOPT_CONNECTTIMEOUT => 10,
			CURLOPT_TIMEOUT => 60,
			CURLOPT_USERAGENT => '',
			CURLOPT_SSL_VERIFYPEER => false,
			CURLOPT_SSL_VERIFYHOST => false,
			CURLOPT_FOLLOWLOCATION => true,
			CURLOPT_FAILONERROR => false
		);
		foreach ($op as $k => $v) curl_setopt($ch, $k, $v);

		$response = curl_exec($ch);
		curl_close($ch);

		return $response;
	}

	/**
	 * Array deep extend.
	 */
	public static function array_extend(&$result) {
		if (!is_array($result)) {
			$result = array();
		}

		$args = func_get_args();
		
		for ($i = 1; $i < count($args); $i++) {
			// we only work on arrays:
			if (!is_array($args[$i])) continue;

			// extend current result with $arg:
			foreach ($args[$i] as $k => $v) {
				if (!isset($result[$k])) {
					$result[$k] = $v;
				}
				else {
					if (is_array($result[$k]) && is_array($v)) {
						self::array_extend($result[$k], $v);
					}
					else {
						$result[$k] = $v;
					}
				}
			}
		}

		return $result;
	}
}

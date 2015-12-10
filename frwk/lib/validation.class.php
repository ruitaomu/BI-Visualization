<?php
/**
 * validation.class.php
 *
 ******************************************************************************/

class validation {
	/**
	 * Given an array with validation rules, make sure it's in a proper
	 * format.
	 */
	public static function fix($rules) {
		global $CFG;
		
		$results = array();
		foreach ($rules as $field => $tests) {
			$results[$field] = array();
			foreach ($tests as $test => $params) {
				if (is_numeric($test)) {
					$test = $params;
				}

				$results[$field][$test] = array();
				if (isset($CFG['VALIDATION_DEFAULTS'][$test])) {
					$results[$field][$test] = $CFG['VALIDATION_DEFAULTS'][$test];
				}

				if (is_array($params)) {
					utils::array_extend($results[$field][$test], $params);
				}
			}
		}

		return $results;
	}

	/**
	 * Validate.
	 */
	public static function validate($hash, $rules, $partial = false) {
		if ($partial) {
			return self::validate_hash_to_rules($hash, $rules);
		}
		else {
			return self::validate_rules_to_hash($hash, $rules);
		}
	}

	/**
	 * Make sure the hash satisfies the rules.
	 */
	public static function validate_hash_to_rules($hash, $rules) {
		$errors = array();
		foreach ($hash as $field => $value) {
			if (!isset($rules[$field])) continue;
			foreach ($rules[$field] as $name => $params) {
				if (isset($params['skip_on_update']) && $params['skip_on_update']) {
					continue;
				}

				if (!self::is_valid($value, $name, $params)) {
					$errors[$field] = $name;
					break;
				}
			}
		}
		return (count($errors) ? $errors : null);
	}
	
	/**
	 * Make sure the rules are satisfied by the hash.
	 */
	public static function validate_rules_to_hash($hash, $rules) {
		$errors = array();
		foreach ($rules as $field => $tests) {
			$value = (isset($hash[$field]) ? $hash[$field] : null);
			foreach ($tests as $name => $params) {
				if (!self::is_valid($value, $name, $params)) {
					$errors[$field] = $name;
					break;
				}
			}
		}
		return (count($errors) ? $errors : null);
	}

	/**
	 * Validate a value against a test.
	 */
	public static function is_valid($value, $test, $params) {
		if (method_exists('validation', 'test_' . $test)) {
			$f = array('validation', 'test_' . $test);
			return call_user_func($f, $value, $params);
		}
		// if unknown test, ignore it:
		return true;
	}

	//////////////////////////////////////////////////////////////////////////////
	//
	// Tests
	//
	//////////////////////////////////////////////////////////////////////////////

	// Functions below return true when the value is valid according to the
	// test or false otherwise.

	/**
	 * Required.
	 */
	public static function test_required($value, $params) {
		$value = trim($value);
		return !(empty($value) && $value !== '0');
	}

	/**
	 * Alpha.
	 */
	public static function test_alpha($value, $params) {
		return !self::test_regexp($value, array('regexp' => '/[^a-z]/i'));
	}

	/**
	 * Numeric.
	 */
	public static function test_numeric($value, $params) {
		if (!is_numeric($value)) return false;
		$value += 0;
		if (isset($params['min']) && $value < $params['min']) {
			return false;
		}
		if (isset($params['max']) && $value > $params['max']) {
			return false;
		}
		return true;
	}

	/**
	 * Alpha-Numeric.
	 */
	public static function test_alphanumeric($value, $params) {
		return !self::test_regexp($value, array('regexp' => '/[^a-z0-9]/i'));
	}

	/**
	 * E-mail.
	 */
	public static function test_email($value, $params) {
		return self::test_regexp($value, array(
			'regexp' => "/^[a-z0-9,!#\$%&'\*\+\/=\?\^_`\{\|}~-]+(\.[a-z0-9,!#\$%&'\*\+\/=\?\^_`\{\|}~-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*\.([a-z]{2,})$/i"
		));
	}

	/**
	 * Regexp.
	 */
	public static function test_regexp($value, $params) {
		return preg_match($params['regexp'], $value);
	}
}

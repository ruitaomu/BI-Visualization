<?php
/**
 * auth.class.php
 *
 ******************************************************************************/

class auth {
	/**
	 * Constructor (prevent instantiation).
	 */
	private function __construct() {
	}

	/**
	 * Require a logged in user.
	 */
	public static function require_user($redirect_to = null) {
		global $CFG;

		$session = session::get_instance();
		if ($session && is_array($session->user_info)) {
			return $session->user_info;
		}

		if (is_null($redirect_to)) {
			$redirect_to = $CFG['FRWK']['AUTH']['require_user']['redirect_to'];
		}

		if ($redirect_to !== false) {
			utils::redirect($redirect_to);
		}

		return false;
	}

	/**
	 * Require a set of permissions.
	 */
	public static function require_permissions($perms, $redirect_to = null) {
		global $CFG;

		// first, require we have a user associated with this session:
		self::require_user($redirect_to);

		if (is_null($redirect_to)) {
			$redirect_to = $CFG['FRWK']['AUTH']['require_permissions']['redirect_to'];
		}

		// get user permissions:
		$user_info = session::get_instance()->user_info;
		if (!isset($user_info['permissions'])) {
			$user_info['permissions'] = array();
		}

		if (isset($user_info['root_access']) && $user_info['root_access'] == 1) {
			return true;
		}

		if (isset($perms['any']) && count($perms['any'])) {
			$sw = false;
			foreach ($perms['any'] as $p) {
				if (isset($user_info['permissions'][$p])) {
					$sw = true;
					break;
				}
			}

			if (!$sw) {
				if ($redirect_to !== false) {
					utils::redirect($redirect_to);
				}
				return false;
			}
		}
		
		if (isset($perms['all']) && count($perms['all'])) {
			$sw = true;
			foreach ($perms['all'] as $p) {
				if (!isset($user_info['permissions'][$p])) {
					$sw = false;
					break;
				}
			}

			if (!$sw) {
				if ($redirect_to !== false) {
					utils::redirect($redirect_to);
				}
				return false;
			}
		}

		return true;
	}

	/**
	 * Get system permissions.
	 */
	public static function get_system_permission_list($allowed = null, $flat = false) {
		global $CFG;

		$permissions = array();

		foreach ($CFG['PERMISSIONS'] as $group => $list) {
			$group_permissions = array();
			foreach ($list as $label => $info) {
				if ($allowed && !isset($allowed[$label])) {
					continue;
				}
				if (!is_array($info)) $info = array('name' => $info);
				$group_permissions[$label] = $info;
			}
			if (count($group_permissions)) {
				if ($flat) {
					$permissions += $group_permissions;
				}
				else {
					$permissions[$group] = $group_permissions;
				}
			}
		}

		return $permissions;
	}
}

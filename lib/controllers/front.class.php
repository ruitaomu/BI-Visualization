<?php
/**
 * front controller
 *
 ******************************************************************************/

class front_controller extends app_controller {
	/**
	 * User info (from session).
	 * @var array
	 */
	public $user_info;


	/**
	 * Init.
	 */
	public function init() {
		$this->user_info = auth::require_user();
	}

  /**
   * Require certain user type.
   */
  public function require_user_type($type, $redirect_to = null) {
    if ($this->user_info['type'] == $type) {
      return true;
    }

		if (is_null($redirect_to)) {
			$redirect_to = $CFG['FRWK']['AUTH']['require_user']['redirect_to'];
		}

		if ($redirect_to !== false) {
			utils::redirect($redirect_to);
		}

		return false;
  }
}

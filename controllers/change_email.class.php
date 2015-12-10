<?php
/**
 * change_email controller
 *
 ******************************************************************************/

class change_email_controller extends app_controller {
	/**
	 * Controller attributes.
	 * @var array
	 */
	protected $attr = array(
	);


	/**
	 * Init.
	 */
	public function init() {
		parent::init();
	}

	//////////////////////////////////////////////////////////////////////////////
	//
	// Actions
	//
	//////////////////////////////////////////////////////////////////////////////

	/**
	 * Confirm e-mail address.
	 */
	public function action_index() {
		if ($this->session()->change_successful) {
			$success = true;
		}
		else {
			$success = false;

			$token = token_model::get_model($this->params->skey);
			if ($token && ($user = $token->get_user())) {
				// make sure the new e-mail address is not already registered:
				$another_user = user_model::find_by_email($token->data);
				if (!$another_user) {
					$user->email = $token->data;
					if ($user->save()) {
						$this->session()->change_successful = true;
						$success = true;

						$token->delete();
					}
				}
				else {
				}
			}
		}

		$this->set('success', $success);
	}

	//////////////////////////////////////////////////////////////////////////////
	//
	// Private Methods
	//
	//////////////////////////////////////////////////////////////////////////////

}

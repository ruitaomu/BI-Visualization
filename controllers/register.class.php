<?php
/**
 * register controller
 *
 ******************************************************************************/

class register_controller extends app_controller {
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
	 * Register.
	 */
	public function action_index() {
		if ($this->req->is('post')) {
			$user = new user_model();

			if ($user->save_from_req()) {
				$this->session()->registration_successful = true;
				$user->send_confirm_email();

				$this->redirect(array('action' => 'welcome'));
			}

			$this->set('errors', $user->get_errors());
		}

		$this->pass();
	}

	/**
	 * Confirm e-mail address.
	 */
	public function action_confirm_email() {
		if ($this->session()->confirm_successful) {
			$success = true;
		}
		else {
			$success = false;

			$token = token_model::get_model($this->params->skey);
			if ($token && ($user = $token->get_user())) {
				$user->email_confirmed = 1;
				$user->status = 'A';
				if ($user->save()) {
					$user->send_welcome_email();

					$this->session()->confirm_successful = true;
					$success = true;

					$token->delete();
				}
			}
		}

		$this->set('success', $success);
	}

	/**
	 * Confirmation page after a user registration.
	 */
	public function action_welcome() {
		// only show this page if we had a successful registration:
		if (!$this->session()->registration_successful) {
			$this->redirect();
		}
	}

	//////////////////////////////////////////////////////////////////////////////
	//
	// Private Methods
	//
	//////////////////////////////////////////////////////////////////////////////

}

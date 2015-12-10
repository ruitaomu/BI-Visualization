<?php
/**
 * login controller
 *
 ******************************************************************************/

class login_controller extends app_controller {
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
	 * Login.
	 */
	public function action_index() {
		// user already logged in:
		if (!is_null($this->session()->user_info)) {
			$this->redirect_logged_in_user();
		}
    $x = new email_sender();

		// we have a "remember me" cookie:
		if (isset($_COOKIE['remember_me'])) {
			$token = token_model::get_model($_COOKIE['remember_me']);
			if ($token) {
				$user = new user_model($token->user_id);
				if ($user->exists()) {
					$user->attach_to_session();
					$this->redirect_logged_in_user();
				}
			}

			// we get here if we have an invalid token, so we clear the cookie:
			setcookie('remember_me', '', time() - 30*86400, '/');
		}

		// perform login:
		$failed = false;
		if ($this->req->is('post')) {
			$email = $this->params->email;
			$password = $this->params->password;

			if ($user = user_model::login($email, $password)) {
				// keep user logged in:
				if ($this->params->remember_me == 'Y') {
					$token = token_model::create($user->id, array(
						'purpose' => 'remember_me',
						'expires_on' => 0
					));
					if ($token) {
						setcookie('remember_me', $token->skey, time() + 30*86400, '/');
					}
				}

				$user->attach_to_session();
				$this->redirect_logged_in_user();
			}

			$failed = true;
			sleep(2);
		}
		$this->set('failed', $failed);

		$this->pass('email');
		$this->pass('redirect_url');
	}

	/**
	 * Forgot password.
	 */
	public function action_forgot_password() {
		$failed = false;
		$email = $this->params->email;
		$user = new user_model(array('email' => $email));
		if ($user->exists()) {
			$user->send_reset_password_email();

      return response::ajax_success(true);
		}
    else {
      return response::ajax_error(array(
        'email' => array(
          'custom' => _('This e-mail address is not registered.')
        )
      ));
    }
	}

	/**
	 * Reset password.
	 */
	public function action_reset_password() {
		$success = false;

		$token = token_model::get_model($this->params->skey);
		if ($token && ($user = $token->get_user())) {
			$success = true;

			if ($this->req->is('post')) {
				$user->password = $this->params->password;
				if ($user->save()) {
					$token->delete();

					$user->attach_to_session();
					$this->redirect_logged_in_user();
				}

				$this->set('errors', $user->get_errors());
			}
		}

		$this->set('success', $success);
	}

	//////////////////////////////////////////////////////////////////////////////
	//
	// Private Methods
	//
	//////////////////////////////////////////////////////////////////////////////

	/**
	 * Redirect a logged in user.
	 */
	private function redirect_logged_in_user() {
		$redirect_url = $this->params->redirect_url;
		if (!empty($redirect_url)) {
			$this->redirect($redirect_url);
		}

		$this->redirect(array('controller' => 'dashboard'));
	}
}

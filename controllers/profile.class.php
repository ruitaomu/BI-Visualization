<?php
/**
 * profile controller
 *
 ******************************************************************************/

class profile_controller extends front_controller {
	/**
	 * Controller attributes.
	 * @var array
	 */
	protected $attr = array(
	);

	/**
	 * User model.
	 * @var object
	 */
	public $user = null;


	/**
	 * Init.
	 */
	public function init() {
		parent::init();

		$this->user = new user_model($this->session()->user_info['id'], array(
			'auto_init' => true
		));

		$this->set('topnav', 'user');
	}

	//////////////////////////////////////////////////////////////////////////////
	//
	// Actions
	//
	//////////////////////////////////////////////////////////////////////////////

	/**
	 * index.
	 */
	public function action_index() {
		if ($this->req->is('post')) {
      $data = $this->params->get_if_set(
        'first_name', 'last_name', 'email', 'password'
      );
			if ($this->user->save($data)) {
				// this will refresh the session user information:
				$this->user->attach_to_session();

				$this->session()->flash(_('Profile updated successfully!'));

				$this->redirect();
			}

			$this->set('errors', $this->user->get_errors());
		}

		$this->set($this->user->get());
		$this->pass();
	}

	/**
	 * Change e-mail.
	 */
	public function action_change_email_ajax() {
		$email = $this->params->email;

		// check if the e-mail address is not registered:
		$user = user_model::find_by_email($email);
		if ($user) {
			return response::ajax_error(array(
				'email' => array(
					'custom' => _('This e-mail address is already registered.')
				)
			));
		}

		$this->user->send_change_email($email);

		return response::ajax_success();
	}

	/**
	 * Change password.
	 */
	public function action_change_password_ajax() {
		// verify current password:
		if (!$this->user->verify_password($this->params->current_password)) {
			sleep(2);
			return response::ajax_error(array(
				'current_password' => array(
					'custom' => _('Wrong password.')
				)
			));
		}

		// change password:
		$this->user->password = $this->params->password;
		if ($this->user->save()) {
			return response::ajax_success();
		}
		else {
			return response::ajax_error($this->user->get_errors());
		}
	}

	//////////////////////////////////////////////////////////////////////////////
	//
	// Private Methods
	//
	//////////////////////////////////////////////////////////////////////////////

}

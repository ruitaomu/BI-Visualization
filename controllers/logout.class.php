<?php
/**
 * logout controller
 *
 ******************************************************************************/

class logout_controller extends app_controller {
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
	 * index.
	 */
	public function action_index() {
		// delete session:
		$this->session()->destroy();

		// delete any "remember me" cookie:
		if (isset($_COOKIE['remember_me'])) {
			token_model::erase($_COOKIE['remember_me']);
			setcookie('remember_me', '', time() - 30*86400, '/');
		}

		$this->redirect('');
	}

	//////////////////////////////////////////////////////////////////////////////
	//
	// Private Methods
	//
	//////////////////////////////////////////////////////////////////////////////

}

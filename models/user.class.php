<?php
/**
 * user model
 *
 ******************************************************************************/

class user_model extends app_model {
	protected $validation_sets = array(
		'default' => array(
			'first_name' => array(
				'required'
			),
			'last_name' => array(
				'required'
			),
			'email' => array(
				'required',
				'email'
			),
			'password' => array(
				'required' => array(
					'skip_on_update' => true
				)
			)
		)
	);

	protected $uniques = array(
		'email' => array(
			'error_message' => 'This email address is already registered.'
		),
		'username' => array(
			'skip_if_empty' => true,
			'error_message' => 'This username is already registered.'
		)
	);


	//////////////////////////////////////////////////////////////////////////////
	//
	// Hooks
	//
	//////////////////////////////////////////////////////////////////////////////

	protected function before_save() {
		// in case we get a new password, make sure it's properly stored (salted
		// and hashed):
		if (isset($this->new_data['password'])) {
			if (!empty($this->new_data['password'])) {
				$password = $this->new_data['password'];
				$salt = uniqid();
				$this->new_data['password'] = md5("$password|$salt");
				$this->new_data['salt'] = $salt;
			}
			else {
				unset($this->new_data['password']);
			}
		}
	}

	protected function after_init() {
		$this->rec_data['name'] = $this->first_name . ' ' . $this->last_name;
	}

	//////////////////////////////////////////////////////////////////////////////
	//
	// Instance Methods
	//
	//////////////////////////////////////////////////////////////////////////////

	/**
	 * Set roles.
	 */
	public function set_roles($roles, $id = null) {
		if (!($id = $this->require_id($id))) return false;

		$tb = tb('user_role');

		// clear current:
		$this->query("DELETE FROM $tb WHERE user_id = '$id'");

		// set new:
		if (is_array($roles)) {
			$hash = array('user_id' => $id);
			foreach ($roles as $role_id) {
				$hash['role_id'] = $role_id;
				$this->db()->add_record($hash, $tb);
			}
		}
	}

	/**
	 * Get roles.
	 */
	public function get_roles($id = null) {
		if (!($id = $this->require_id($id))) return array();
		
		$tb = tb('user_role');

		$roles = array();
		$q = $this->query("SELECT role_id FROM $tb WHERE user_id = '$id'");
		while (is_array($res = $q->getrow())) {
			$roles[$res['role_id']] = $res['role_id'];
		}

		return $roles;
	}

	/**
	 * Get permissions.
	 */
	public function get_permissions($id = null) {
		if (!($id = $this->require_id($id))) return array();

    // check if we have a role with all permissions:
    $tb = tb('role');
		$tbur = tb('user_role');
    $qstr = implode(' ', array(
      "SELECT star_permission",
      "FROM $tb AS t1",
      "WHERE id IN (SELECT role_id FROM $tbur WHERE user_id = '$id')",
      "ORDER BY star_permission DESC",
      "LIMIT 1"
    ));
    $q = $this->query($qstr);
    while (is_array($res = $q->getrow())) {
      if ($res['star_permission'] == 1) {
        $perms = array_keys(auth::get_system_permission_list(null, true));
        $permissions = array();
        foreach ($perms as $p) {
          $permissions[$p] = $p;
        }
        return $permissions;
      }
    }

		$tbrp = tb('role_permission');
		$qstr = implode(' ', array(
			"SELECT permission",
			"FROM $tbrp",
			"WHERE role_id IN (SELECT role_id FROM $tbur WHERE user_id = '$id')"
		));

		$permissions = array();
		$q = $this->query($qstr);
		while (is_array($res = $q->getrow())) {
			$permissions[$res['permission']] = $res['permission'];
		}

		return $permissions;
	}

	/**
	 * Attach this user to the current session.
	 */
	public function attach_to_session($id = null) {
		if (!$this->require_instance($id)) return false;

		$this->frwk->session()->user_info = array(
			'id' => $this->id,
      'type' => $this->user_type,
			//'username' => $this->username,
			'email' => $this->email,
			'name' => $this->name
			//'email_confirmed' => $this->email_confirmed,
			//'root_access' => $this->root_access,
			//'permissions' => $this->get_permissions()
		);
	}

	/**
	 * Verify password.
	 */
	public function verify_password($password, $id = null) {
		if (!$this->require_instance($id)) return false;

		return ($this->password == md5("$password|{$this->salt}"));
	}

	/**
	 * Send the "welcome" e-mail.
	 */
	public function send_welcome_email($id = null) {
		if (!$this->require_instance($id)) return false;

		$email_sender = new email_sender();
		$email_sender->sendView(
			array(
				'to' => "{$this->name} <{$this->email}>",
				'subject' => 'Welcome!'
			),
			'welcome',
			array(
				'first_name' => $this->first_name
			)
		);
	}

	/**
	 * Send the "confirm" e-mail.
	 */
	public function send_confirm_email($id = null) {
		if (!$this->require_instance($id)) return false;

		$token = token_model::create($this->id, array(
			'purpose' => 'confirm_email'
		));
		if (!$token) {
			return false;
		}

		$link = utils::href(
			array(
				'module' => '',
				'controller' => 'register',
				'action' => 'confirm-email'
			),
			array(
				'skey' => $token->skey
			),
			true
		);

		$email_sender = new email_sender();
		$email_sender->sendView(
			array(
				'to' => "{$this->name} <{$this->email}>",
				'subject' => 'Confirm E-mail'
			),
			'confirm',
			array(
				'first_name' => $this->first_name,
				'link' => $link
			)
		);
	}

	/**
	 * Send the "reset password" e-mail.
	 */
	public function send_reset_password_email($id = null) {
		if (!$this->require_instance($id)) return false;

		$token = token_model::create($this->id, array(
			'purpose' => 'reset_password',
			'expires_on' => time() + 1*86400
		));
		if (!$token) {
			return false;
		}

		$link = utils::href(
			array(
				'module' => '',
				'controller' => 'login',
				'action' => 'reset-password'
			),
			array(
				'skey' => $token->skey
			),
			true
		);

		$email_sender = new email_sender();
		$email_sender->sendView(
			array(
				'to' => "{$this->name} <{$this->email}>",
				'subject' => 'Reset Password'
			),
			'reset_password',
			array(
				'first_name' => $this->first_name,
				'link' => $link
			)
		);
	}

	/**
	 * Send the "change" e-mail.
	 */
	public function send_change_email($email, $id = null) {
		if (!$this->require_instance($id)) return false;

		$token = token_model::create($this->id, array(
			'purpose' => 'change_email',
			'data' => $email
		));
		if (!$token) {
			return false;
		}

		$link = utils::href(
			array(
				'module' => '',
				'controller' => 'change-email'
			),
			array(
				'skey' => $token->skey
			),
			true
		);

		$email_sender = new email_sender();
		$email_sender->sendView(
			array(
				'to' => $email,
				'subject' => 'Confirm New E-mail'
			),
			'change',
			array(
				'first_name' => $this->first_name,
				'link' => $link
			)
		);
	}

  /**
   * Delete user.
   */
  public function delete($id = null) {
    if (!($id = $this->require_id($id))) {
      return false;
    }

    // delete user - role association:
    $tb = tb('user_role');
    $this->db()->query("DELETE FROM $tb WHERE user_id = :id", array(
      'id' => $id
    ));

    return parent::delete($id);
  }

	//////////////////////////////////////////////////////////////////////////////
	//
	// Collection Methods
	//
	//////////////////////////////////////////////////////////////////////////////


	//////////////////////////////////////////////////////////////////////////////
	//
	// Private Methods
	//
	//////////////////////////////////////////////////////////////////////////////


	//////////////////////////////////////////////////////////////////////////////
	//
	// Static Methods
	//
	//////////////////////////////////////////////////////////////////////////////

	/**
	 * Login by verifying a username/password combination and returning the user
	 * record if successful.
	 */
	public static function login($s, $password) {
		$where_str = implode(' AND ', array(
			'(' . implode(' OR ', array(
				//'(username IS NOT NULL AND LOWER(username) = LOWER(:s))',
				'(LOWER(email) = LOWER(:s))',
			)) . ')',
			"status = 'A'"
		));

		$data = array(
			's' => $s
		);

		$user = new user_model();

		$tb = $user->attr('tb');
		if (is_array($res = $user->db()->get_fields('*', $tb, $where_str, $data))) {
			if ($user->init($res)) {
				if ($user->verify_password($password)) {
					return $user;
				}
			}
		}

		return null;
	}

	/**
	 * Find a user by email address.
	 */
	public static function find_by_email($email) {
		$where_str = 'LOWER(email) = LOWER(:email)';

		$data = array(
			'email' => $email
		);

		$user = new user_model();

		$tb = $user->attr('tb');
		if (is_array($res = $user->db()->get_fields('*', $tb, $where_str, $data))) {
			if ($user->init($res)) {
				return $user;
			}
		}

		return null;
	}

	/**
	 * User statuses.
	 */
	public static function status_opt() {
		return array(
			'A' => _('Active'),
			'P' => _('Pending Verification'),
			'B' => _('Banned')
		);
	}

	/**
	 * User types.
	 */
	public static function type_opt() {
		return array(
			1 => _('Admin'),
			2 => _('Employee')
		);
	}
}

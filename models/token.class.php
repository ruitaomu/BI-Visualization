<?php
/**
 * token model
 *
 ******************************************************************************/

class token_model extends app_model {
	protected $validation_sets = array(
		'default' => array(
		)
	);

	protected $uniques = array(
	);


	//////////////////////////////////////////////////////////////////////////////
	//
	// Hooks
	//
	//////////////////////////////////////////////////////////////////////////////


	//////////////////////////////////////////////////////////////////////////////
	//
	// Instance Methods
	//
	//////////////////////////////////////////////////////////////////////////////

	/**
	 * Get the user associated with this token.
	 */
	public function get_user() {
		if (!$this->require_instance()) return false;

		$user = new user_model($this->user_id);
		if ($user->exists()) {
			return $user;
		}

		return null;
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
	 * Create a token.
	 */
	public static function create($user_id, $params = array()) {
		$data = $params + array(
			'user_id' => $user_id,
			'skey' => md5(uniqid()),
			'expires_on' => time() + 30*86400
		);

		$token = new token_model();
		if ($token->save($data)) {
			return $token;
		}

		return null;
	}

	/**
	 * Get a model instance.
	 */
	public static function get_model($skey) {
		$token = new token_model();

		// get a token record by its skey and make sure the IP matches and it's not
		// expired:
		$where_str = implode(' AND ', array(
			'skey = :skey',
			'(ip IS NULL OR ip = :ip)',
			'(expires_on = 0 OR expires_on > :t)'
		));

		$data = array(
			'skey' => $skey,
			'ip' => $_SERVER['REMOTE_ADDR'],
			't' => time()
		);

		$tb = $token->attr('tb');
		$res = $token->db()->get_fields('*', $tb, $where_str, $data);
		if (is_array($res)) {
			$token->init($res);
			return $token;
		}

		return null;
	}

	/**
	 * Erase a token.
	 */
	public static function erase($skey) {
		$token = new token_model();
		$token->del(array('fields' => array('skey' => $skey)));
	}
}

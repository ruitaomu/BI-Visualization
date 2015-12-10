<?php
/**
 * role model
 *
 ******************************************************************************/

class role_model extends app_model {
	protected $validation_sets = array(
		'default' => array(
			'name' => array(
				'required'
			)
		)
	);

	protected $uniques = array(
		'name' => array(
			'error_message' => 'This role already exists.'
		)
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
	 * Set permissions.
	 */
	public function set_permissions($permissions, $id = null) {
		if (!$this->require_instance($id)) return false;
		
		$tb = tb('role_permission');

		// clear current:
		$this->query("DELETE FROM $tb WHERE role_id = '{$this->id}'");

		// set new:
		if (is_array($permissions)) {
			// get all allowed permissions:
			$allowed = auth::get_system_permission_list(null, true);
			
			$hash = array('role_id' => $this->id);
			foreach ($permissions as $permission) {
				if (!isset($allowed[$permission])) {
					continue;
				}

				$hash['permission'] = $permission;
				$this->db()->add_record($hash, $tb);
			}
		}
	}

	/**
	 * Get permissions.
	 */
	public function get_permissions($id = null) {
		if (!$this->require_instance($id)) return array();
		
		// get all allowed permissions:
		$allowed = auth::get_system_permission_list(null, true);

		if ($this->star_permission == 1) {
			return $allowed;
		}
		else {
			$tb = tb('role_permission');
			$permissions = array();
			$qstr = "SELECT permission FROM $tb WHERE role_id = '{$this->id}'";
			$q = $this->query($qstr);
			while (is_array($res = $q->getrow())) {
				if (isset($allowed[$res['permission']])) {
					$permissions[$res['permission']] = $allowed[$res['permission']];
				}
			}
			return $permissions;
		}
	}

  /**
   * Delete role.
   */
  public function delete($id = null) {
    if (!($id = $this->require_id($id))) {
      return false;
    }

    // delete user - role association:
    $tb = tb('user_role');
    $this->db()->query("DELETE FROM $tb WHERE role_id = :id", array(
      'id' => $id
    ));

    return parent::delete($id);
  }

	//////////////////////////////////////////////////////////////////////////////
	//
	// Collection Methods
	//
	//////////////////////////////////////////////////////////////////////////////

	/**
	 * Del.
	 */
	public function del($ids = null) {
		if (is_array($ids) && ($n = count($ids))) {
			// delete all permissions associated with these roles:
			$tb = tb('role_permission');
			$in_str = implode(',', array_fill(0, $n, '?'));
			$this->db()->query("DELETE FROM $tb WHERE role_id IN ($in_str)", $ids);

			// delete roles:
			parent::del(array('ids' => $ids));

			return true;
		}

		return false;
	}

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

}

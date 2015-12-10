<?php
/**
 * roles controller
 *
 ******************************************************************************/

class roles_controller extends front_controller {
	/**
	 * Controller attributes.
	 * @var array
	 */
	protected $attr = array(
	);

	/**
	 * Associated model.
	 * @var object
	 */
	public $model = null;


	/**
	 * Init.
	 */
	public function init() {
		parent::init();
		auth::require_permissions(array(
			'all' => array('manage_roles')
		));

		$this->model = new role_model();

		$this->set('topnav', 'manage');
	}

	//////////////////////////////////////////////////////////////////////////////
	//
	// Actions
	//
	//////////////////////////////////////////////////////////////////////////////

	/**
	 * Implement basic CRUD operations.
	 */

	public function action_index() {
		$this->set('items', $this->model->all());
	}

	public function action_create() {
		return $this->creupd();
	}

	public function action_update() {
		return $this->creupd();
	}

	public function action_delete() {
		$ids = $this->params->ids;
		if (is_array($ids) && count($ids) > 0) {
			$n = 0;
			foreach ($ids as $id) {
				$this->model->load($id);
				if (!$this->model->exists() || !$this->model->access_allowed()) {
					continue;
				}

				if ($this->model->delete()) {
					$n++;
				}
			}

			if ($n) {
				$this->session()->flash(_("Successfully deleted $n record(s)."));
			}
		}

		$this->redirect();
	}

	/**
	 * Datatables AJAX source (for large data sets).
	 */
	//public function action_datatables_ajax() {
	//	return $this->model->datatables(array(
	//		// table columns:
	//		'cols' => array('id', 'name', 'created_on'),
	//		// searchable columns:
	//		'search_cols' => array('name')
	//	));
	//}

	//////////////////////////////////////////////////////////////////////////////
	//
	// Private Methods
	//
	//////////////////////////////////////////////////////////////////////////////

	/**
	 * Create/Update.
	 */
	private function creupd() {
		$this->view = 'creupd';
		$id = $this->params->get('id', 0);
		$this->model->load($id);
		$item = array();

		if ($id > 0) {
			if (!$this->model->exists() || !$this->model->access_allowed()) {
				return response::access_denied();
			}
		}

		if ($this->req->is('post')) {
			if ($this->params->mode == 'creupd') {
				if ($this->model->save_from_req()) {
					$this->model->set_permissions($this->params->permissions);

					$this->session()->flash(_('Data saved successfully.'));
					
					if ($this->req->is('ajax')) {
						return response::ajax_success($this->model->get());
					}
					$this->redirect();
				}
				
				// get model errors:
				$errors = $this->model->get_errors();

				if ($this->req->is('ajax')) {
					return response::ajax_error($errors);
				}

				$this->set('errors', $errors);
			}
		}

		if ($id > 0) {
			$item = $this->model->get();
			$this->set($item);
			$this->set('permissions', $this->model->get_permissions());
		}
		$this->pass();
		$this->pass_permissions();

		$this->set('permission_list', auth::get_system_permission_list());
	}

	/**
	 * Pass any received permissions to the view layer in a correct format.
	 */
	private function pass_permissions() {
		$permissions = $this->params->permissions;
		if (is_array($permissions)) {
			$results = array();
			foreach ($permissions as $permission_label) {
				$results[$permission_label] = true;
			}
			$this->set('permissions', $results);
		}
	}
}

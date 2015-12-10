<?php
/**
 * users controller
 *
 ******************************************************************************/

class users_controller extends front_controller {
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

    // make sure only admins can access this:
    $this->require_user_type(1);

		$this->model = new user_model();

    $u_name = preg_replace('/._controller$/', '', get_called_class());
    $this->set('u_name', ucfirst($u_name));

    switch ($u_name) {
    case 'admin':
      $this->set('topnav', 'settings');
      $u_type = 1;
      break;
    case 'employee':
      $this->set('topnav', 'employees');
      $u_type = 2;
      break;
    }

    $this->u_name = $u_name;
    $this->u_type = $u_type;
	}

  /**
   * Render.
   */
  public function render() {
    $this->view = '../users/' . $this->view;
    return parent::render();
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
    $this->set('count', user_model::get_count(array(
      'user_type' => $this->u_type
    )));
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
		  $user_info = $this->session()->user_info;
			$n = 0;
			foreach ($ids as $id) {
        if ($id == $user_info['id']) {
          continue;
        }

				$this->model->load($id);
				if (!$this->model->exists() || !$this->model->access_allowed()) {
					continue;
				}

				if ($this->model->delete()) {
					$n++;
				}
			}

			if ($n) {
        $this->session()->flash(
          "Successfully deleted $n {$this->u_name}" . ($n == 1 ? '' : 's') . "."
        );
			}
		}

		$this->redirect();
	}

	/**
	 * Datatables AJAX source (for large data sets).
	 */
	public function action_datatables_ajax() {
		return $this->model->datatables(array(
      'where_str' => "user_type = {$this->u_type}",
			// table columns:
			'cols' => array('id', 'email', 'created_on'),
			// searchable columns:
			'search_cols' => array('email', 'first_name', 'last_name')
		));
	}

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
      if ($id == $this->user_info['id']) {
        $this->redirect(array('controller' => 'profile'));
      }

			if (!$this->model->exists() || !$this->model->access_allowed()) {
				return response::access_denied();
			}
		}

		$user_info = $this->session()->user_info;

		if ($this->req->is('post')) {
			if ($this->params->mode == 'creupd') {
        $data = array();
        if (!$id) {
          $data['user_type'] = $this->u_type;
        }

				if ($this->model->save_from_req($data)) {
          $u_name = ucfirst($this->u_name);
          if ($id > 0) {
					  $this->session()->flash(_("$u_name updated successfully."));
          }
          else {
					  $this->session()->flash(_("$u_name created successfully."));
          }
					
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
      $this->set('user_type_opt', user_model::type_opt());
		}
		$this->pass();
	}
}

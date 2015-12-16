<?php
/**
 * testers controller
 *
 ******************************************************************************/

class testers_controller extends front_controller {
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

		$this->model = new tester_model();

    $this->set('topnav', 'testers');
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
    $this->set('count', tester_model::get_count());
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
        $this->session()->flash(
          "Successfully deleted $n tester" . ($n == 1 ? '' : 's') . "."
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
      'select' => "*, CONCAT(first_name, ' ', last_name) AS name, YEAR(NOW()) - YEAR(dob) - (DATE_FORMAT(NOW(), '%m%d') < DATE_FORMAT(dob, '%m%d')) as age",
			// table columns:
			'cols' => array('id', 'name', 'age', 'created_on'),
			// searchable columns:
			'search_cols' => array('first_name', 'last_name')
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
			if (!$this->model->exists() || !$this->model->access_allowed()) {
				return response::access_denied();
			}
		}

		if ($this->req->is('post')) {
			if ($this->params->mode == 'creupd') {
				if ($this->model->save_from_req()) {
          if ($id > 0) {
					  $this->session()->flash(_("Tester updated successfully."));
          }
          else {
					  $this->session()->flash(_("Tester created successfully."));
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
		}
		$this->pass();
    $this->set('experience_id_opt', attribute_model::values('experience'));
	}
}

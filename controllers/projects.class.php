<?php
/**
 * projects controller
 *
 ******************************************************************************/

class projects_controller extends front_controller {
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

		$this->model = new project_model();

    $this->set('topnav', 'projects');
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
    $this->set('count', project_model::get_count());
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
          "Successfully deleted $n project" . ($n == 1 ? '' : 's') . "."
        );
			}
		}

		$this->redirect();
	}

	/**
	 * Datatables AJAX source (for large data sets).
	 */
	public function action_datatables_ajax() {
    $tb1 = $this->model->attr('tb');
    $tb2 = tb('customer');

		return $this->model->datatables(array(
      'select' => 't1.*, t2.name AS customer',
      'from' => "$tb1 AS t1, $tb2 AS t2",
      'where_str' => 't2.id = t1.customer_id',

			// table columns:
			'cols' => array('id', 'title', 'customer', 'num_testers', 'created_on'),
			// searchable columns:
			'search_cols' => array('t1.title', 't2.name')
		));
	}

  public function action_data() {
		$id = $this->params->get('id', 0);
		$this->model->load($id);
		$item = array();

    $this->set('tab', 'data');

		if ($id > 0) {
			if (!$this->model->exists() || !$this->model->access_allowed()) {
				return response::access_denied();
			}

      $this->set($this->model->get());
		}
  }

  public function action_visualisation() {
		$id = $this->params->get('id', 0);
		$this->model->load($id);
		$item = array();

    $this->set('tab', 'visualisation');

		if ($id > 0) {
			if (!$this->model->exists() || !$this->model->access_allowed()) {
				return response::access_denied();
			}

      $this->set($this->model->get());
		}
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

    $this->set('tab', 'general');

		if ($id > 0) {
			if (!$this->model->exists() || !$this->model->access_allowed()) {
				return response::access_denied();
			}
		}

		if ($this->req->is('post')) {
			if ($this->params->mode == 'creupd') {
				if ($this->model->save_from_req()) {
          if ($id > 0) {
					  $this->session()->flash(_("Project updated successfully."));
            $next_action = 'update';
          }
          else {
					  $this->session()->flash(_("Project created successfully."));
            $next_action = 'data';
          }
					
					if ($this->req->is('ajax')) {
						return response::ajax_success($this->model->get());
					}

          $this->redirect(utils::href(
            array(
              'action' => $next_action
            ),
            array(
              'id' => $this->model->id
            )
          ));
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

    $this->set('customer_id_opt', customer_model::get_opt());
    $this->set('game_type_id_opt', attribute_model::values('game_type'));
    $this->set('game_hardware_id_opt', attribute_model::values('game_hardware'));
	}
}

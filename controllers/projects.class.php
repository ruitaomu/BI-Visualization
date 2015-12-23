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

      // get project testers:
      $this->set('testers', $this->model->get_testers());

      // get all available testers:
      $testers_opt = tester_model::get_opt('id', "CONCAT(first_name, ' ', last_name)");
      $available_testers = array();
      foreach ($testers_opt as $tester_id => $tester_name) {
        $available_testers[] = array('id' => $tester_id, 'text' => $tester_name);
      }
      $this->set('available_testers_json', json_encode($available_testers));

      // get the supposed order of index file columns:
      $index_data = attribute_model::values('index_data');
      array_unshift($index_data, 'Time');
      $this->set('index_cols', implode(', ', $index_data));
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

  public function action_add_tester() {
		$id = $this->params->get('id', 0);
		$this->model->load($id);

		if ($id > 0) {
			if (!$this->model->exists() || !$this->model->access_allowed()) {
				return response::access_denied();
			}

      $this->model->add_tester($this->params->tester_id);

			return response::ajax_success();
		}
  }

  public function action_del_tester() {
		$id = $this->params->get('id', 0);
		$this->model->load($id);

		if ($id > 0) {
			if (!$this->model->exists() || !$this->model->access_allowed()) {
				return response::access_denied();
			}

      $this->model->del_tester($this->params->tester_id, $this->params->what);

			return response::ajax_success();
		}
  }

  public function action_set_video_hashed_id() {
		$id = $this->params->get('id', 0);
		$this->model->load($id);

		if ($id > 0) {
			if (!$this->model->exists() || !$this->model->access_allowed()) {
				return response::access_denied();
			}

      $tester_id = $this->params->tester_id;
      $video_hashed_id = $this->params->video_hashed_id;

      $this->model->set_video_hashed_id($tester_id, $video_hashed_id);

			return response::ajax_success();
		}
  }

  public function action_upload_index() {
		$id = $this->params->get('id', 0);
		$this->model->load($id);

		if ($id > 0) {
			if (!$this->model->exists() || !$this->model->access_allowed()) {
				return response::access_denied();
			}

      $result = $this->model->upload_index($this->params->tester_id);

      if ($result !== true) {
        return response::ajax_error($result);
      }
      else {
			  return response::ajax_success();
      }
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

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
    $filters = $this->params->all();
    $this->set('filters_json', json_encode($filters));

    $this->set('count', project_model::get_count($filters));
    $this->set('tab', 'list');
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

    $where_str = array('t2.id = t1.customer_id');
    $filters = $this->params->filters;
    if (is_array($filters)) {
      foreach ($filters as $k => $v) {
        $where_str[] = "t1.$k = '$v'";
      }
    }
    $where_str = implode(' AND ', $where_str);

		return $this->model->datatables(array(
      'select' => 't1.*, t2.name AS customer',
      'from' => "$tb1 AS t1, $tb2 AS t2",
      'where_str' => $where_str,

			// table columns:
			'cols' => array('id', 'title', 'customer', 'num_testers', 'created_on'),
			// searchable columns:
			'search_cols' => array('t1.title', 't2.name')
		));
	}

  public function action_project_data() {
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

      $this->set('experience_id_opt', attribute_model::values('experience'));
      $this->set('existing_video_id_opt', project_model::existing_videos());
		}
  }

  public function action_project_data_visualisation() {
		$id = $this->params->get('id', 0);
		$this->model->load($id);
		$item = array();

    $this->set('tab', 'visualisation');

		if ($id > 0) {
			if (!$this->model->exists() || !$this->model->access_allowed()) {
				return response::access_denied();
			}

      // get the list of testers for this project:
      $tester_opt = $this->model->get_testers_opt();
      $this->set('tester_opt', $tester_opt);

      $tester_id = $this->params->tester_id;
      if (empty($tester_id)) {
        $tester_ids = array_keys($tester_opt);
        if (count($tester_ids) > 0) {
          $tester_id = $tester_ids[0];
        }
      }

      $this->set('tester_id', $tester_id);

      if (!empty($tester_id)) {
        $tags = $this->model->get_tags($tester_id);
        $this->set('tags_json', json_encode($tags));

        $index_data = $this->model->get_index_data($tester_id);
        $this->set('index_data_json', json_encode($index_data));

        $index_attr = array_values(attribute_model::values('index_data'));
        $this->set('index_attr_json', json_encode($index_attr));

        $ma = array_values(attribute_model::values('ma'));
        $ma_attr = array(array('id' => 0, 'text' => 'Moving Average'));
        $ma_attr = array();
        foreach ($ma as $x) {
          $ma_attr[] = array('id' => $x, 'text' => $x);
        }
        $this->set('ma_attr_json', json_encode($ma_attr));

        $tester_data = $this->model->get_testers($tester_id);
        $this->set('tester_data', $tester_data[0]);
      }

      $this->set($this->model->get());
		}
  }

  public function action_project_tag_analysis() {
		$id = $this->params->get('id', 0);
		$this->model->load($id);
		$item = array();

    $this->set('tab', 'tag_analysis');

		if ($id > 0) {
			if (!$this->model->exists() || !$this->model->access_allowed()) {
				return response::access_denied();
			}

      if ($this->req->is('post')) {
        $params = json_decode($this->params->json, true);

        $index_data = $this->model->get_tag_analysis_data($params);

        if (isset($params['csv']) && $params['csv']) {
          header('Content-Type: text/csv');
          header('Content-Disposition: attachment; filename=data.csv');
          header('Pragma: no-cache');
          header('Expires: 0');

          foreach ($index_data as $row) {
            print implode(',', $row) . "\r\n";
          }

          return false;
        }
        else {
          return response::ajax_success($index_data);
        }
      }

      // get the list of testers for this project:
      $tester_opt = $this->model->get_testers_opt();
      $this->set('tester_opt', $tester_opt);

      $tags = $this->model->get_all_tags();
      $this->set('tags', $tags);

      $index_attr = array_values(attribute_model::values('index_data'));
      $this->set('index_attr_json', json_encode($index_attr));

      $ma = array_values(attribute_model::values('ma'));
      $ma_attr = array(array('id' => 0, 'text' => 'Moving Average'));
      $ma_attr = array();
      foreach ($ma as $x) {
        $ma_attr[] = array('id' => $x, 'text' => $x);
      }
      $this->set('ma_attr_json', json_encode($ma_attr));

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

  public function action_upload_tags() {
		$id = $this->params->get('id', 0);
		$this->model->load($id);

		if ($id > 0) {
			if (!$this->model->exists() || !$this->model->access_allowed()) {
				return response::access_denied();
			}

      $result = $this->model->upload_tags($this->params->tester_id);

      if ($result !== true) {
        return response::ajax_error($result);
      }
      else {
			  return response::ajax_success();
      }
		}
  }

  public function action_download() {
		$id = $this->params->get('id', 0);
		$this->model->load($id);

		if ($id > 0) {
			if (!$this->model->exists() || !$this->model->access_allowed()) {
				return response::access_denied();
			}

      $this->model->download($this->params->tester_id, $this->params->what);
		}

    return false;
  }

  public function action_data() {
    $this->set('tab', 'data');

    $this->set('customer_opt', customer_model::get_opt());

    $this->set('project_filters', attribute_model::get_tree('project'));

    $index_attr = array_values(attribute_model::values('index_data'));
    $this->set('index_attr_json', json_encode($index_attr));

    $ma = array_values(attribute_model::values('ma'));
    $ma_attr = array(array('id' => 0, 'text' => 'Moving Average'));
    foreach ($ma as $x) {
      $ma_attr[] = array('id' => $x, 'text' => $x);
    }
    $this->set('ma_attr_json', json_encode($ma_attr));

    $this->set('filters', $this->params->all());
  }

  /**
   * Combine the index data from multiple projects/testers.
   */
  public function action_index_data() {
		$filters = $this->params->all();

    $result = array();
    $projects = project_model::get_opt($filters);
    foreach ($projects as $id => $title) {
      $testers = $this->model->get_testers(null, $id);
      foreach ($testers as $tester) {
        $data = $this->model->get_index_data($tester['tester_id'], $id);
        foreach ($data as $name => $values) {
          if (!isset($result[$name])) {
            $result[$name] = array(
              'series' => array(),
              'sets' => 0
            );
          }

          $result[$name]['sets']++;

          for ($i = 0; $i < count($values['series']); $i++) {
            if (isset($result[$name]['series'][$i])) {
              $result[$name]['series'][$i] += $values['series'][$i];
            }
            else {
              $result[$name]['series'][$i] = $values['series'][$i];
            }
          }
        }
      }
    }

    foreach ($result as $name => $data) {
      $sum = 0;
      for ($i = 0; $i < count($result[$name]['series']); $i++) {
        $result[$name]['series'][$i] /= $result[$name]['sets'];
        $sum += $result[$name]['series'][$i];
      }
      $result[$name]['avg'] = $sum / count($result[$name]['series']);
      unset($result[$name]['sets']);
    }

    return response::ajax_success($result);
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
            $next_action = 'project-data';
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
    $this->set('age_group_id_opt', attribute_model::values('age_group'));
	}
}

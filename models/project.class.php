<?php
/**
 * project model
 *
 ******************************************************************************/

class project_model extends app_model {
	protected $validation_sets = array(
		'default' => array(
			'title' => array(
				'required'
      ),
      'customer_id' => array(
        'required'
      ),
      'game_type_id' => array(
        'required'
      ),
      'game_version' => array(
        'required',
        'regexp' => array(
          'regexp' => '/^[0-9]+(\.[0-9]+)*$/',
          'error_message' => 'This field must contain a valid version number.'
        )
      ),
      'game_hardware_id' => array(
        'required'
      )
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
   * Add a tester to this project.
   */
  public function add_tester($tester_id, $id = null) {
    if (!($id = $this->require_id($id))) {
      return false;
    }

    $tb = tb('project_tester');
    $hash = array(
      'project_id' => $id,
      'tester_id' => $tester_id,
      'created_on' => time()
    );

    $this->db()->add_record($hash, $tb);
    $this->save(array(':num_testers' => 'num_testers + 1'));

    return true;
  }

  /**
   * Delete tester data.
   */
  public function del_tester($tester_id, $what, $id = null) {
    if (!($id = $this->require_id($id))) {
      return false;
    }

    $tb = tb('project_tester');
    $where_str = "project_id = '$id' AND tester_id = :tester_id";
    $info = $this->db()->get_fields('*', $tb, $where_str, array(
      'tester_id' => $tester_id
    ));

    // delete video from Wistia, if any:
    if ($what == 'video' || $what == 'all') {
      if (!empty($info['wistia_video_hashed_id'])) {
        $url = $this->frwk->cfg['WISTIA']['delete_url'];
        $url = str_replace('#ID', $info['wistia_video_hashed_id'], $url);
        utils::http_post($url, array('_method' => 'delete'));

        if ($what != 'all') {
          $hash = array('wistia_video_hashed_id' => '');
          $this->db()->update_record($hash, $tb, "id = '$info[id]'");
        }
      }
    }

    // delete index file:
    if ($what == 'index' || $what == 'all') {
      $path = $this->frwk->cfg['ROOT_DIR'] . "/data/index_files/$info[id].csv";
      if (file_exists($path)) {
        unlink($path);
      }

      if ($what != 'all') {
        $hash = array('index_file' => '');
        $this->db()->update_record($hash, $tb, "id = '$info[id]'");
      }
    }

    // delete record:
    if ($what == 'all') {
      $this->db()->query("DELETE FROM $tb WHERE id = '$info[id]'");
      $this->save(array(':num_testers' => 'num_testers - 1'));
    }

    return true;
  }

  /**
   * Set Wistia video hashed ID.
   */
  public function set_video_hashed_id($tester_id, $video_hashed_id, $id = null) {
    if (!($id = $this->require_id($id))) {
      return false;
    }

    $tb = tb('project_tester');
    $hash = array(
      'tester_id' => $tester_id,
      'wistia_video_hashed_id' => $video_hashed_id
    );
    $where_str = "project_id = '$id' AND tester_id = :tester_id";
    $this->db()->update_record($hash, $tb, $where_str);

    return true;
  }

  /**
   * Get all testers for a project.
   */
  public function get_testers($id = null) {
    if (!($id = $this->require_id($id))) {
      return array();
    }

    $tb = tb('project_tester');
    $tb_tester = tb('tester');
    $qstr = implode(' ', array(
      "SELECT t1.*, CONCAT(t2.first_name, ' ', t2.last_name) AS name ",
      "FROM $tb AS t1, $tb_tester AS t2",
      "WHERE t1.project_id = '$id' AND t2.id = t1.tester_id",
      "ORDER BY t1.id DESC"
    ));
    $q = $this->query($qstr);
    $results = [];
    while (is_array($res = $q->getrow())) {
      $results[] = $res;
    }

    return $results;
  }

  /**
   * Upload index file.
   */
  public function upload_index($tester_id, $id = null) {
    if (!($id = $this->require_id($id))) {
      return false;
    }

    $tb = tb('project_tester');
    $where_str = "project_id = '$id' AND tester_id = :tester_id";
    $_id = $this->db()->get_fields('id', $tb, $where_str, array(
      'tester_id' => $tester_id
    ));

    $src = $_FILES['file']['tmp_name'];

    $cols = attribute_model::values('index_data');
    $n = count($cols) + 1;

    $file = file($src);
    $row = str_getcsv($file[0]);

    if (count($row) != $n) {
      return 'file doesn\'t match index attributes';
    }
    else {
      $dst = $this->frwk->cfg['ROOT_DIR'] . "/data/index_files/$_id.csv";

      move_uploaded_file($src, $dst);

      $hash = array(
        'tester_id' => $tester_id,
        'index_file' => '1'
      );
      $where_str = "project_id = '$id' AND tester_id = :tester_id";
      $this->db()->update_record($hash, $tb, $where_str);

      return true;
    }
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

}

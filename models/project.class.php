<?php
/**
 * project model
 *
 ******************************************************************************/
require($CFG['ROOT_DIR'] . '/include/vendors/PHPExcel-1.8.1/Classes/PHPExcel/IOFactory.php');

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
      ),
      'age_group_id' => array(
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
   * Get the testers of this project.
   */
  public function get_testers_opt($id = null) {
    if (!($id = $this->require_id($id))) {
      return false;
    }

    $tb = tb('project_tester');
    $tb_tester = tb('tester');

    $qstr = implode(' ', array(
      "SELECT t2.id, CONCAT(t2.first_name, ' ', t2.last_name) AS name",
      "FROM $tb AS t1, $tb_tester AS t2",
      "WHERE t1.project_id = '$id' AND t2.id = t1.tester_id"
    ));
    $q = $this->query($qstr);

    $results = array();

    while (is_array($res = $q->getrow())) {
      $results[$res['id']] = $res['name'];
    }

    return $results;
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
      $ext = pathinfo($info['index_file'], PATHINFO_EXTENSION);
      $path = $this->frwk->cfg['ROOT_DIR'] . "/data/index_files/$info[id].$ext";
      if (file_exists($path)) {
        unlink($path);
      }

      if ($what != 'all') {
        $hash = array('index_file' => '');
        $this->db()->update_record($hash, $tb, "id = '$info[id]'");
      }
    }

    // delete tags file:
    if ($what == 'tags' || $what == 'all') {
      $tb_tag = tb('tag');
      $this->query("DELETE FROM $tb_tag WHERE project_tester_id = '$info[id]'");

      $ext = pathinfo($info['tags_file'], PATHINFO_EXTENSION);
      $path = $this->frwk->cfg['ROOT_DIR'] . "/data/tags_files/$info[id].$ext";
      if (file_exists($path)) {
        unlink($path);
      }

      if ($what != 'all') {
        $hash = array('tags_file' => '');
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
  public function get_testers($tester_id = null, $id = null) {
    if (!($id = $this->require_id($id))) {
      return array();
    }

    $tb = tb('project_tester');
    $tb_tester = tb('tester');
    $qstr = implode(' ', array(
      "SELECT t1.*, CONCAT(t2.first_name, ' ', t2.last_name) AS name ",
      "FROM $tb AS t1, $tb_tester AS t2",
      "WHERE t1.project_id = '$id' AND t2.id = t1.tester_id",
      (!is_null($tester_id) ? 'AND t1.tester_id = :tester_id' : ''),
      "ORDER BY t1.id DESC"
    ));
    $q = $this->query($qstr, array('tester_id' => $tester_id));
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

    if ($this->valid_index_file($_FILES['file'])) {
      $ext = pathinfo($_FILES['file']['name'], PATHINFO_EXTENSION);
      $dst = $this->frwk->cfg['ROOT_DIR'] . "/data/index_files/$_id.$ext";

      move_uploaded_file($_FILES['file']['tmp_name'], $dst);

      $hash = array(
        'tester_id' => $tester_id,
        'index_file' => $_FILES['file']['name']
      );
      $where_str = "project_id = '$id' AND tester_id = :tester_id";
      $this->db()->update_record($hash, $tb, $where_str);

      return true;
    }
    else {
      return 'file doesn\'t match index attributes';
    }
  }

  /**
   * Upload tags file.
   */
  public function upload_tags($tester_id, $id = null) {
    if (!($id = $this->require_id($id))) {
      return false;
    }

    $tb = tb('project_tester');
    $where_str = "project_id = '$id' AND tester_id = :tester_id";
    $_id = $this->db()->get_fields('id', $tb, $where_str, array(
      'tester_id' => $tester_id
    ));

    $f = fopen($_FILES['file']['tmp_name'], 'r');
    $header = null;
    $tag_sequences = array();
    $tags = array();
    while (($row = fgetcsv($f, 1024)) !== false) {
      if (!$header) {
        $header = $row;
      }
      else {
        $tag_arr = explode('-', $row[7]);
        $tag = $tag_arr[0];

        if (!isset($tag_sequences[$tag])) {
          $tag_sequences[$tag] = 0;
        }

        switch (count($tag_arr)) {
        case 2:
          $type = $tag_arr[1];
          $seq = ($type == 's' ? ++$tag_sequences[$tag] : $tag_sequences[$tag]);
          break;

        case 3:
          $seq = $tag_arr[1];
          $type = $tag_arr[2];
          break;
        }

        $tagseq = "$tag-$seq";
        $tags[$tagseq]['tag'] = $tag;
        $tags[$tagseq]['seq'] = $seq;
        $tags[$tagseq]["t_$type"] = $row[4];
      }
    }
    fclose($f);

    $ext = pathinfo($_FILES['file']['name'], PATHINFO_EXTENSION);
    $dst = $this->frwk->cfg['ROOT_DIR'] . "/data/tags_files/$_id.$ext";

    move_uploaded_file($_FILES['file']['tmp_name'], $dst);

    $tb_tag = tb('tag');
    foreach ($tags as $tag) {
      $tag['project_tester_id'] = $_id;
      $tag['project_id'] = $id;
      $tag['tester_id'] = $tester_id;

      $this->db()->add_record($tag, $tb_tag);
    }

    $hash = array(
      'tester_id' => $tester_id,
      'tags_file' => $_FILES['file']['name']
    );
    $where_str = "project_id = '$id' AND tester_id = :tester_id";
    $this->db()->update_record($hash, $tb, $where_str);

    return true;
  }

  /**
   * Get tags for a tester on this project.
   */
  public function get_tags($tester_id, $tags = array(), $id = null) {
    if (!($id = $this->require_id($id))) {
      return false;
    }

    $tags_filter = array();
    foreach ($tags as $tag => $seqs) {
      $seqs = implode(',', array_map(function($seq) { return "'$seq'"; }, $seqs));
      $tags_filter[] = "(tag = '$tag' AND seq IN ($seqs))";
    }
    $tags_filter = implode(' OR ', $tags_filter);

    $tb = tb('tag');
    $qstr = implode(' ', array(
      "SELECT *",
      "FROM $tb",
      "WHERE project_id = '$id' AND tester_id = :tester_id",
      (!empty($tags_filter) ? "AND ($tags_filter)" : ''),
      "ORDER BY tag, seq"
    ));
    $q = $this->query($qstr, array('tester_id' => $tester_id));

    $results = array('tag' => array());
    while (is_array($res = $q->getrow())) {
      if (!isset($results['min_ts']) || $results['min_ts'] > $res['t_s']) {
        $results['min_ts'] = $res['t_s'];
      }
      if (!isset($results['max_ts']) || $results['max_ts'] < $res['t_e']) {
        $results['max_ts'] = $res['t_e'];
      }

      if (!isset($results['tag'][$res['tag']])) {
        $results['tag'][$res['tag']] = array();
      }

      $results['tag'][$res['tag']][] = array(
        'seq' => $res['seq'],
        't_s' => $res['t_s'],
        't_e' => $res['t_e']
      );
    }

    return $results;
  }

  /**
   * Get all tags (for all tester) on this project and indicate which testers
   * has which tag.
   */
  public function get_all_tags($id = null) {
    if (!($id = $this->require_id($id))) {
      return false;
    }

    $tb = tb('tag');
    $qstr = implode(' ', array(
      "SELECT *",
      "FROM $tb",
      "WHERE project_id = '$id'",
      "ORDER BY tag, seq"
    ));
    $q = $this->query($qstr);

    $results = array();
    while (is_array($res = $q->getrow())) {
      if (!isset($results[$res['tag']])) {
        $results[$res['tag']] = array(
          'testers' => array(),
          'seq' => array()
        );
      }

      $results[$res['tag']]['testers']['t-' . $res['tester_id']] = true;

      if (!isset($results[$res['tag']]['seq'][$res['seq']])) {
        $results[$res['tag']]['seq'][$res['seq']] = 't-' . $res['tester_id'];
      }
      else {
        $results[$res['tag']]['seq'][$res['seq']] .= " t-$res[tester_id]";
      }
    }

    foreach ($results as $tag => $data) {
      $results[$tag]['testers'] = implode(' ', array_keys($data['testers']));
    }

    return $results;
  }

  /**
   * Get index data for a tester on this project.
   */
  public function get_index_data($tester_id, $id = null) {
    if (!($id = $this->require_id($id))) {
      return false;
    }

    $tb = tb('project_tester');
    $where_str = "project_id = '$id' AND tester_id = :tester_id";
    $info = $this->db()->get_fields('*', $tb, $where_str, array(
      'tester_id' => $tester_id
    ));

    if (empty($info['index_file'])) {
      return null;
    }

    $ext = 'xlsx';
    $path = $this->frwk->cfg['ROOT_DIR'] . "/data/index_files/$info[id].$ext";
    $objPHPExcel = PHPExcel_IOFactory::load($path);
    foreach ($objPHPExcel->getWorksheetIterator() as $worksheet) {
      $data = $worksheet->toArray();
      if (count($data) > 1) {
        $results = array();
        $header = null;

        foreach ($data as $row) {
          if (is_null($header)) {
            $header = $row;
            for ($i = 0; $i < count($header); $i++) {
              $header[$i] = strtolower($header[$i]);
              $results[$header[$i]] = array(
                'series' => array(),
                'sum' => 0,
                'count' => 0
              );
            }
          }
          else {
            for ($i = 0; $i < count($row); $i++) {
              $results[$header[$i]]['series'][] = $row[$i];
              $results[$header[$i]]['sum'] += $row[$i];
              $results[$header[$i]]['count'] += 1;
            }
          }
        }

        for ($i = 0; $i < count($header); $i++) {
          $results[$header[$i]]['avg'] = $results[$header[$i]]['sum'] / $results[$header[$i]]['count'];
          unset($results[$header[$i]]['sum']);
          unset($results[$header[$i]]['count']);
        }

        return $results;
      }
    }
  }

  /**
   * Get tag analysis data for this project.
   */
  public function get_tag_analysis_data($params, $id = null) {
    if (!($id = $this->require_id($id))) {
      return false;
    }

    $results = array();

    foreach ($params['testers'] as $tester_id) {
      $tags = $this->get_tags($tester_id, $params['tags']);
      $index_data = $this->get_index_data($tester_id);

      // slice index data based on selected tags and add it to the results:
      foreach ($index_data as $attr => $data) {
        foreach ($tags['tag'] as $tag => $seqs) {
          foreach ($seqs as $seq) {
            $start = max(0, min(floor($seq['t_s'] / 400) - 1, count($data['series']) - 1));
            $end = max(0, min(floor($seq['t_e'] / 400) - 1, count($data['series']) - 1));
            $segment = array_slice($data['series'], $start, $end - $start + 1);
            if ($params['tail']) {
              $segment = array_reverse($segment);
            }

            if (!isset($results[$attr])) {
              $results[$attr] = array('series' => array(), 'counts' => array());
            }

            for ($i = 0; $i < count($segment); $i++) {
              if (!isset($results[$attr]['series'][$i])) {
                $results[$attr]['series'][$i] = array(
                  'sum' => $segment[$i],
                  'count' => 1
                );
              }
              else {
                $results[$attr]['series'][$i]['sum'] += $segment[$i];
                $results[$attr]['series'][$i]['count'] += 1;
              }
            }
          }
        }
      }
    }

    // calculate average for all series:
    foreach ($results as $attr => $data) {
      $sum = 0;
      for ($i = 0; $i < count($data['series']); $i++) {
        $results[$attr]['counts'][$i] = $data['series'][$i]['count'];
        $results[$attr]['series'][$i] = $data['series'][$i]['sum'] / $data['series'][$i]['count'];
        $sum += $results[$attr]['series'][$i];
      }
      $results[$attr]['avg'] = $sum / count($results[$attr]['series']);

      if ($params['tail']) {
        $results[$attr]['series'] = array_reverse($results[$attr]['series']);
        $results[$attr]['counts'] = array_reverse($results[$attr]['counts']);
      }
    }

    return $results;
  }

  /**
   * Download tags or index files for a tester.
   */
  public function download($tester_id, $what, $id = null) {
    if (!($id = $this->require_id($id))) {
      return false;
    }

    $tb = tb('project_tester');
    $where_str = "project_id = '$id' AND tester_id = :tester_id";
    $info = $this->db()->get_fields('*', $tb, $where_str, array(
      'tester_id' => $tester_id
    ));

    switch ($what) {
    case 'index':
      $ext = pathinfo($info['index_file'], PATHINFO_EXTENSION);
      $path = $this->frwk->cfg['ROOT_DIR'] . "/data/index_files/$info[id].$ext";
      $name = $info['index_file'];
      break;

    case 'tags':
      $ext = pathinfo($info['tags_file'], PATHINFO_EXTENSION);
      $path = $this->frwk->cfg['ROOT_DIR'] . "/data/tags_files/$info[id].$ext";
      $name = $info['tags_file'];
      break;
    }

    if (file_exists($path)) {
      header('Content-Type: application/octet-stream');
      header('Content-Disposition: attachment; filename="' . $name . '"');
      header('Expires: 0');
      header('Cache-Control: must-revalidate');
      header('Content-Length: ' . filesize($path));
      readfile($path);
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

  /**
   * Check if an index file is valid (i.e.: the number of columns matches the
   * number of index attributes defined).
   */
  private function valid_index_file($file) {
    $cols = attribute_model::values('index_data');
    return true;
  }

	//////////////////////////////////////////////////////////////////////////////
	//
	// Static Methods
	//
	//////////////////////////////////////////////////////////////////////////////

	public static function get_opt($params = array()) {
    $model = new self();

    $where_str = array();
    foreach ($params as $name => $value) {
      if (!empty($value)) {
        $where_str[] = "$name = :$name";
      }
    }
    $where_str = implode(' AND ', $where_str);

    return $model->opt('id', 'title', $where_str, $params);
  }

  /**
   * Get project counts by hardware. This function's return is optimised for
   * consumption by a Flot chart.
   */
  public static function get_count_by_attr($attr) {
    $model = new self();
    $attr_values = attribute_model::values($attr);
    $results = array();

    $qstr = implode(' ', array(
      "SELECT {$attr}_id AS attr_id, COUNT(*) AS count",
      "FROM {$model->attr('tb')}",
      "GROUP BY {$attr}_id"
    ));
    $q = $model->query($qstr);
    while (is_array($res = $q->getrow())) {
      $results[] = array(
        'label' => $attr_values[$res['attr_id']],
        'data' => $res['count']
      );
    }

    return $results;
  }

  /**
   * Get all videos already uploaded.
   */
  public static function existing_videos() {
    $model = new self();
    $results = array();

    $tb = tb('project_tester');
    $tb_project = tb('project');
    $tb_tester = tb('tester');
    $qstr = implode(' ', array(
      "SELECT DISTINCT wistia_video_hashed_id, first_name, last_name, title",
      "FROM $tb AS t1, $tb_project as t2, $tb_tester AS t3",
      "WHERE t1.wistia_video_hashed_id != '' AND t2.id = t1.project_id",
      "AND t3.id = t1.tester_id"
    ));

    $q = $model->query($qstr);
    while (is_array($res = $q->getrow())) {
      $name = "$res[title] / $res[first_name] $res[last_name]";
      $results[$res['wistia_video_hashed_id']] = $name;
    }

    return $results;
  }
}

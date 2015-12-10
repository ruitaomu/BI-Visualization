<?php
/**
 * app model
 *
 ******************************************************************************/

class app_model extends model {
	/**
	 * Check if a user is allowed to access this instance of the model.
	 */
	public function access_allowed($user_info = null) {
		// no instance loaded, access allowed:
		if (!$this->require_instance()) {
			return true;
		}

		if ($this->user_id || $this->account_id) {
			// make sure we have a user:
			if (is_null($user_info)) {
				$user_info = $this->frwk->session()->user_info;
			}
			if (!is_array($user_info)) {
				return false;
			}

			// model has user access constraints:
			if ($this->user_id) {
				if (!$user_info['root_access']) {
					if ($this->user_id != $user_info['id']) {
						return false;
					}
				}
			}

			// model has account access constraints:
			if ($this->account_id) {
				if (!$user_info['root_access']) {
					if ($this->account_id != $user_info['account_id']) {
						return false;
					}
				}
			}
		}

		// allow access:
		return true;
	}

	/**
	 * Datatables source.
	 */
	public function datatables($options) {
		$params =& $this->frwk->req->params;
		$data = array();

		// default options:
		$opt = array(
			'select' => '*',
			'from' => $this->attr('tb')
		);

		// overwrite defaults:
		utils::array_extend($opt, $options);

		// paging:
		$limit_str = '';
		$iDisplayStart = $params->iDisplayStart;
		$iDisplayLength = $params->get('iDisplayLength', '-1');
		if (!is_null($iDisplayStart) && $iDisplayLength != '-1') {
			$limit_str = "LIMIT $iDisplayStart, $iDisplayLength";
		}

		// ordering:
		$order_by_str = '';
		if ($params->iSortCol_0 !== null) {
			$order_by_arr = array();
			for ($i = 0; $i < intval($params->iSortingCols); $i++) {
				$col_index = intval($params->get("iSortCol_$i"));
				if ($params->get("bSortable_$col_index") == 'true') {
					$dir = ($params->get("sSortDir_$i") == 'asc' ? 'ASC' : 'DESC');
					$order_by_arr[] = $opt['cols'][$col_index] . ' ' . $dir;
				}
			}
			$order_by_str = implode(', ', $order_by_arr);
		}

		// filtering:
		$where_arr = array();

		if (isset($opt['where_str'])) {
			$where_arr[] = $opt['where_str'];
		}

		$sSearch = $params->sSearch;
		if (!empty($sSearch)) {
			$data['search'] = $sSearch;
			$search_arr = array();
			for ($i = 0; $i < count($opt['search_cols']); $i++) {
				$s = $opt['search_cols'][$i] . " LIKE CONCAT('%', :search, '%')";
				$search_arr[] = $s;
			}
			if (count($search_arr)) {
				$where_arr[] = '(' . implode(' OR ', $search_arr) . ')';
			}
		}

		$where_str = implode(' AND ', $where_arr);

		// construct query:
		$qstr = implode(' ', array(
			"SELECT SQL_CALC_FOUND_ROWS $opt[select]",
			"FROM $opt[from]",
			(!empty($where_str) ? "WHERE $where_str" : ''),
			(isset($opt['group_by_str']) ? "GROUP BY $opt[group_by_str]" : ''),
			(!empty($order_by_str) ? "ORDER BY $order_by_str" : ''),
			$limit_str
		));

		$results = array(
			'sEcho' => intval($params->sEcho),
			'iTotalRecords' => 0,
			'iTotalDisplayRecords' => 0,
			'aaData' => array()
		);

		$q = $this->query($qstr, $data);
		$q->getall();
		while (is_array($res = $q->getrow())) {
			if (isset($opt['callback'])) {
				$res = call_user_func($opt['callback'], $res);
			}
			$results['aaData'][] = $res;
		}

		// data set length before limit:
		$q = $this->query("SELECT FOUND_ROWS()");
		if (is_array($res = $q->getrow())) {
			$results['iTotalDisplayRecords'] = intval(array_shift($res));
		}

		// total data set length:
		$n = $this->db()->get_fields(
			'COUNT(*)',
			$opt['from'],
			trim(implode(' ', array(
				(isset($opt['where_str']) ? $opt['where_str'] : '1'),
				(isset($opt['group_by_str']) ? "GROUP BY $opt[group_by_str]" : '')
			)))
		);
		$results['iTotalRecords'] = intval($n);

		return $results;
	}

  /**
   * Get the number of records with specific properties.
   */
  public static function get_count($params = array()) {
    $model_class = get_called_class();
    $model = new $model_class();
    $tb = $model->attr('tb');

    $where_arr = array();
    foreach ($params as $field => $value) {
      $where_arr[] = "$field = :$field";
    }
    $where_str = implode(' AND ', $where_arr);

    return $model->db()->get_fields('COUNT(*)', $tb, $where_str, $params);
  }

	/**
	 * Get records in an "opt" form (i.e.: list of key => value pairs).
	 */
	public static function get_opt($key='id', $value='name', $where_str='', $data=array()) {
    $model_class = get_called_class();
    $model = new $model_class();

    return $model->opt($key, $value, $where_str, $data);
  }
}

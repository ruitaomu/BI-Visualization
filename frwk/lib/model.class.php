<?php
/**
 * model.class.php
 *
 ******************************************************************************/

class model {
	/**
	 * Framework reference.
	 * @var object
	 */
	protected $frwk;

	/**
	 * Model attributes.
	 * @var array
	 */
	protected $attr = array(
		// model name:
		'name' => '',

		// database table name:
		'tb' => '',

		// database connection:
		'db_label' => 'default',

		// auto save data each time a field is set:
		'auto_save' => false,

		// auto reload model after each save operation:
		'auto_reload' => false,

		// auto initialize after a save operation:
		'auto_init' => false,

		// enable validation:
		'validate' => true,

		// default validation label:
		'vlabel' => 'default'
	);

	/**
	 * Validation sets.
	 * @var array
	 */
	protected $validation_sets = array();

	/**
	 * Validation rules.
	 * @var array
	 */
	protected $vrules = array();

	/**
	 * Uniques.
	 * @var array
	 */
	protected $uniques = array();

	/**
	 * Database record ID (simple primary key).
	 * @var mixed
	 */
	protected $id;

	/**
	 * Record data (from latest load).
	 * @var array
	 */
	protected $rec_data = array();

	/**
	 * New record data (before save).
	 * @var array
	 */
	protected $new_data = array();

	/**
	 * Last errors generated.
	 * @var array
	 */
	protected $errors = null;

	/**
	 * Last executed query.
	 * @var object
	 */
	private $q;


	/**
	 * Constructor.
	 */
	public function __construct($fields = null, $attr = array()) {
		$this->frwk = framework::get();
		$this->attr($attr);

		// model name:
		$this->attr('name', preg_replace('/_model$/', '', get_class($this)));

		// default database table name, if not specified:
		$tb = $this->attr('tb');
		if (empty($tb)) {
			$cfgname = tb($this->attr('name'));
			$this->attr('tb', ($cfgname ? $cfgname : $this->attr('name')));
		}

		// set initial validation rules:
		$vlabel = $this->attr('vlabel');
		if (!empty($vlabel)) {
			$this->set_validation_rules($vlabel);
		}

		// load record from database:
		if (!is_null($fields)) {
			$this->load($fields);
		}
	}

	//////////////////////////////////////////////////////////////////////////////
	//
	// Magic Methods
	//
	//////////////////////////////////////////////////////////////////////////////

	/**
	 * Set a field.
	 */
	public function __set($name, $value) {
		$this->set(array($name => $value));
	}

	/**
	 * Get a field.
	 */
	public function __get($name) {
		return $this->get(true, $name);
	}

  /**
   * Check if a field is set.
   */
  public function __isset($name) {
    return (isset($this->rec_data[$name]) || isset($this->new_data[$name]));
  }

	//////////////////////////////////////////////////////////////////////////////
	//
	// Setters & Getters
	//
	//////////////////////////////////////////////////////////////////////////////

	/**
	 * Set multiple fields.
	 */
	public function set($data, $override = true, $disable_auto_save = false) {
		if ($override) {
			$this->new_data = $data + $this->new_data;
		}
		else {
			$this->new_data += $data;
		}

		if (!$disable_auto_save && $this->attr('auto_save')) {
			$this->save();
		}
	}

	/**
	 * Get multiple fields.
	 * First parameter could be boolean, to indicate whether to retrieve new
	 * fields (not saved to DB yet) or not.
	 */
	public function get() {
		$args = func_get_args();
		$new = (count($args) && is_bool($args[0]) ? array_shift($args) : false);
		
		// all fields requested:
		if (!count($args)) {
			return ($new ? $this->new_data + $this->rec_data : $this->rec_data);
		}
		
		$res = array();
		foreach ($args as $arg) {
			// return new field if requested and defined, otherwise fallback to
			// rec_data and finally return null if that's also not found:
			if ($new && isset($this->new_data[$arg])) {
				$res[$arg] = $this->new_data[$arg];
			}
			elseif (isset($this->rec_data[$arg])) {
				$res[$arg] = $this->rec_data[$arg];
			}
			else {
				$res[$arg] = null;
			}
		}

		return (count($res) == 1 ? array_shift($res) : $res);
	}

	/**
	 * Attribute setter & getter.
	 */
	public function attr() {
		return utils::attr($this->attr, func_get_args());
	}

	//////////////////////////////////////////////////////////////////////////////
	//
	// Model Operations
	//
	//////////////////////////////////////////////////////////////////////////////

	/**
	 * Generic load function based on passed parameters.
	 */
	public function load($fields = null) {
		if (is_null($fields)) $fields = $this->id;
		if (!$fields) return;

		// $fields could be a scalar in which case we assume it's the value for the
		// ID field:
		if (!is_array($fields)) $fields = array('id' => $fields);

		if (!count($fields)) {
			return;
		}

		$this->clear();

		if ($this->errors = $this->before_load($fields)) {
			return false;
		}

		$where_arr = array();
		foreach ($fields as $field => $value) $where_arr[] = "$field = :$field";
		$where_str = implode(' AND ', $where_arr);

		$tb = $this->attr('tb');

		if ($this->init($this->db()->get_fields('*', $tb, $where_str, $fields))) {
			if ($this->errors = $this->after_load()) {
				return false;
			}

			return true;
		}
		
		return false;
	}

	/**
	 * Initialize this object with given record data.
	 */
	public function init($data) {
		$this->clear();

		if (is_array($data)) {
			$this->rec_data = $data;
			$this->id = $data['id'];

			if ($this->errors = $this->after_init()) {
				return false;
			}

			return true;
		}

		return false;
	}

	/**
	 * Check if current object represents a record in the database.
	 */
	public function exists() {
		return !is_null($this->id);
	}

	/**
	 * Clear object.
	 */
	public function clear() {
		$this->rec_data = array();
		$this->new_data = array();
		$this->id = null;
		$this->errors = null;
	}

	/**
	 * Save (either create or update).
	 */
	public function save($data = null) {
		if (!is_null($data)) {
			$this->set($data);
		}

		$sw = $this->exists();

		if ($this->errors = $this->before_save(!$sw)) {
			return false;
		}

		// there's nothing to save:
		if (!count($this->new_data)) {
			return false;
		}
		
		// execute appropriate save operation:
		if (isset($this->new_data['id'])) unset($this->new_data['id']);
		$ret = ($sw ? $this->_update() : $this->_create());
		
		if ($ret && ($this->errors = $this->after_save(!$sw))) {
			return false;
		}
		
		return $ret;
	}

	/**
	 * Create.
	 */
	protected function _create() {
		if ($this->errors = $this->before_create()) {
			return false;
		}

		if (!isset($this->new_data['created_on'])) {
			$this->new_data['created_on'] = time();
		}
		if (!isset($this->new_data['updated_on'])) {
			$this->new_data['updated_on'] = time();
		}

		if ($this->attr('validate') && !$this->validate()) {
			return false;
		}

		if ($this->errors = $this->after_create_validation()) {
			return false;
		}

		$tb = $this->attr('tb');
		if (($id = $this->db()->add_record($this->new_data, $tb)) > 0) {
			if ($this->attr('auto_reload')) {
				$this->load($id);
			}
			else {
				if ($this->attr('auto_init')) {
					$this->init($this->new_data + $this->rec_data);
				}
				else {
					$this->rec_data = $this->new_data + $this->rec_data;
					$this->new_data = array();
					$this->id = $this->rec_data['id'] = $id;
				}
			}
			
			if ($this->errors = $this->after_create()) {
				return false;
			}

			return true;
		}
		else {
		}
		
		return false;
	}

	/**
	 * Update.
	 */
	protected function _update() {
		if ($this->errors = $this->before_update()) {
			return false;
		}
		
		if (!isset($this->new_data['updated_on'])) {
			$this->new_data['updated_on'] = time();
		}

		if ($this->attr('validate') && !$this->validate()) {
			return false;
		}

		if ($this->errors = $this->after_update_validation()) {
			return false;
		}

		$tb = $this->attr('tb');
		$id = $this->id;
		if ($this->db()->update_record($this->new_data, $tb, "id = '$id'")) {
			if ($this->attr('auto_reload')) {
				$this->load();
			}
			else {
				if ($this->attr('auto_init')) {
					$this->init($this->new_data + $this->rec_data);
				}
				else {
					$this->rec_data = $this->new_data + $this->rec_data;
					$this->new_data = array();
				}
			}

			if ($this->errors = $this->after_update()) {
				return false;
			}

			return true;
		}
		else {
		}
		
		return false;
	}

	/**
	 * Delete.
	 */
	public function delete($id = null) {
		if (!($id = $this->require_id($id))) return false;

		$this->query("DELETE FROM {$this->attr('tb')} WHERE id = :id", array(
			'id' => $id
		));
		$this->clear();

		return true;
	}

	//////////////////////////////////////////////////////////////////////////////
	//
	// Helper Methods
	//
	//////////////////////////////////////////////////////////////////////////////

	/**
	 * Save with data received in the request.
	 */
	public function save_from_req($data = array()) {
		return $this->save($data + $this->frwk->req->params->all());
	}

	/**
	 * Get the number of rows affected by the last query executed with
	 * $this->query().
	 */
	public function rows_affected() {
		if ($this->q) {
			return $this->q->numrows();
		}

		return 0;
	}

	//////////////////////////////////////////////////////////////////////////////
	//
	// Error Handling
	//
	//////////////////////////////////////////////////////////////////////////////

	/**
	 * Get errors.
	 */
	public function get_errors() {
		if (is_array($this->errors)) {
			$errors = array();
			foreach ($this->errors as $field => $test) {
				if (is_array($test)) {
					$errors[$field] = $test;
				}
				else {
					$errors[$field] = array();
					$error_message = '';
					if (isset($this->vrules[$field][$test]['error_message'])) {
						$error_message = $this->vrules[$field][$test]['error_message'];
					}
					$errors[$field][$test] = $error_message;
				}
			}
			return $errors;
		}

		return $this->errors;
	}

	//////////////////////////////////////////////////////////////////////////////
	//
	// Instance Methods
	//
	//////////////////////////////////////////////////////////////////////////////

	/**
	 * require_instance.
	 */
	protected function require_instance($id = null) {
		$id = (!is_null($id) ? $id : $this->id);
		if (!$id) return false;

		if ($this->id != $id) {
			$this->load($id);
		}

		return true;
	}

	/**
	 * require_id.
	 */
	protected function require_id($id = null) {
		$id = (!is_null($id) ? $id : $this->id);
		return $id;
	}

	//////////////////////////////////////////////////////////////////////////////
	//
	// Collection Methods
	//
	//////////////////////////////////////////////////////////////////////////////

	/**
	 * Get records from this model.
	 */
	public function all($fields='*', $where_str='', $data=array(), $key='id') {
		$tb = $this->attr('tb');

		return $this->db()->get_records($fields, $tb, $where_str, $data, $key);
	}

	/**
	 * Get records in an "opt" form (i.e.: list of key => value pairs).
	 */
	public function opt($key='id', $value='name', $where_str='', $data=array()) {
		$qstr = implode(' ', array(
			"SELECT $key, $value",
			"FROM {$this->attr('tb')}",
			(!empty($where_str) ? "WHERE $where_str" : '')
		));
		$q = $this->db()->query($qstr, $data);

		$results = array();
		while (is_array($res = $q->getrow())) {
			$results[$res[$key]] = $res[$value];
		}
		return $results;
	}

	/**
	 * Delete records.
	 */
	public function del($params = array()) {
		$where_str = '';
		$data = (isset($params['data']) ? $params['data'] : array());

		if (isset($params['where_str'])) {
			$where_str = $params['where_str'];
		}
		elseif (isset($params['ids']) && is_array($params['ids'])) {
			if (($n = count($params['ids']))) {
				$in_str = implode(',', array_fill(0, $n, '?'));
				$where_str = "id IN ($in_str)";
				$data = $params['ids'];
			}
		}
		elseif (isset($params['fields'])) {
			$where_arr = array();
			foreach ($params['fields'] as $field => $value) {
				$where_arr[] = "$field = :$field";
			}
			$where_str = implode(' AND ', $where_arr);
			$data = $params['fields'];
		}

		if (empty($where_str)) {
			return false;
		}

		$this->query("DELETE FROM {$this->attr('tb')} WHERE $where_str", $data);

		return true;
	}

	//////////////////////////////////////////////////////////////////////////////
	//
	// Hooks
	//
	//////////////////////////////////////////////////////////////////////////////
	
	protected function before_load($fields) {
	}
	protected function after_load() {
	}

	protected function before_init() {
	}
	protected function after_init() {
	}

	protected function before_save() {
	}
	protected function after_save($is_new) {
	}

	protected function before_create() {
	}
	protected function after_create() {
	}

	protected function before_update() {
	}
	protected function after_update() {
	}

	protected function after_create_validation() {
	}
	protected function after_update_validation() {
	}

	//////////////////////////////////////////////////////////////////////////////
	//
	// Validation
	//
	//////////////////////////////////////////////////////////////////////////////

	/**
	 * Perform validation.
	 */
	public function validate() {
		// field validation:
		$sw = $this->exists();
		$this->errors = validation::validate($this->new_data, $this->vrules, $sw);
		if ($this->errors) {
			return false;
		}

		// uniques:
		if ($this->errors = $this->check_uniques()) {
			return false;
		}

		return true;
	}

	/**
	 * Get validation rules.
	 */
	public function get_validation_rules() {
		$args = func_get_args();

		if (!count($args)) {
			return $this->vrules;
		}

		$rules = array();
		foreach ($args as $arg) {
			if (is_array($arg)) {
				$r = $arg;
			}
			else {
				$r = array();

				$cfglabel = "{$this->attr('name')}_model_$arg";
				if (isset($this->frwk->cfg['VALIDATION'][$cfglabel])) {
					$r += $this->frwk->cfg['VALIDATION'][$cfglabel];
				}

				if (isset($this->validation_sets[$arg])) {
					$r += $this->validation_sets[$arg];
				}
			}

			$rules = $r + $rules;
		}

		return validation::fix($rules);
	}

	/**
	 * Set validation rules.
	 */
	public function set_validation_rules() {
		$args = func_get_args();
		$fn = array($this, 'get_validation_rules');

		return ($this->vrules = call_user_func_array($fn, $args));
	}

	/**
	 * Enforce unique constraints.
	 */
	protected function check_uniques() {
		$id = ($this->id ? $this->id : 0);

		foreach ($this->uniques as $field => $params) {
			// only look at newly set fields:
			if (!isset($this->new_data[$field])) {
				continue;
			}

			$data = array(
				'value' => $this->new_data[$field]
			);

			// skip empty value if indicated to do so:
			if (empty($data['value'])) {
				if (isset($params['skip_if_empty']) && $params['skip_if_empty']) {
					continue;
				}
			}

			$where_arr = array(
				"id != '$id'",
				"LOWER($field) = LOWER(:value)"
			);

			if (isset($params['where_str']) && !empty($params['where_str'])) {
				$where_arr[] = $params['where_str'];
			}

			if (isset($params['within'])) {
				$within = $params['within'];
				if (!is_array($within)) $within = array($within);

				foreach ($within as $within_field) {
					$data[$within_field] = $this->get(true, $within_field);
					$where_arr[] = "LOWER($within_field) = LOWER(:$within_field)";
				}
			}

			$where_str = implode(' AND ', $where_arr);
			$tb = $this->attr('tb');

			if ($this->db()->get_fields('id', $tb, $where_str, $data) > 0) {
				return array($field => array('unique' => $params['error_message']));
			}
		}
	}

	//////////////////////////////////////////////////////////////////////////////
	//
	// Database
	//
	//////////////////////////////////////////////////////////////////////////////

	/**
	 * Get database connection object.
	 */
	public function db($label = null) {
		return $this->frwk->db(($label ? $label : $this->attr('db_label')));
	}

	/**
	 * Execute a query.
	 */
	public function query($qstr, $data = array(), $label = null) {
		return ($this->q = $this->db($label)->query($qstr, $data));
	}
}

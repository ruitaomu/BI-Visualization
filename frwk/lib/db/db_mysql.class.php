<?php

/**
 * A simple class providing MySQL database access to PHP applications in an OOP
 * style (using PDO).
 *
 * @author Catalin Ciocov
 * @license http://www.opensource.org/licenses/mit-license.php
 */

class db_mysql {

	/**
	 * Database connection handler (PDO object).
	 * @var object
	 */
	public $dbh;

	/**
	 * Last executed query.
	 * @var object
	 */
	private $q;

	/**
	 * Internal cache for table structure.
	 * @var array { table name => table structure, ... }
	 */
	private $_cache = array();


	/**
	 * Constructor. Connect to the database server using the supplied info.
	 * @param string $dbname
	 * @param string $dbuser
	 * @param string $dbpass
	 * @param string $dbhost
	 */
	public function __construct($dbname, $dbuser, $dbpass, $dbhost = 'localhost') {
		$dsn = "mysql:dbname=$dbname;host=$dbhost;charset=utf8";
		$this->dbh = new PDO($dsn, $dbuser, $dbpass);
		$this->dbh->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
	}

	/**
	 * Execute a query.
	 * @param string $qstr The query string.
	 * @param array $data The parameters for the given query string.
	 * @return object A db_mysql_query object.
	 */
	public function query($qstr, $data = array()) {
		if ($this->q) {
			$this->q->free();
		}
		return ($this->q = new db_mysql_query($this, $qstr, $data));
	}

	/**
	 * Get the number of rows/records affected by the last query.
	 * @return int
	 */
	public function rows_affected() {
		return ($this->q ? $this->q->numrows() : 0);
	}

	/**
	 * Get the last ID generated for an auto-increment field.
	 * @return int
	 */
	public function last_id() {
		return $this->dbh->lastInsertId();
	}

	/**
	 * Describe a table (its structure). This is used by add_record() and
	 * update_record() and is optimized for multiple use by an internal
	 * cache.
	 * @param string $tbname The name of the table.
	 * @return array
	 */
	public function describe($tbname) {
		if (!isset($this->_cache[$tbname])) {
			$this->_cache[$tbname] = array();
			$q = $this->query("SHOW COLUMNS FROM $tbname");
			while (is_array($res = $q->getrow())) {
				$this->_cache[$tbname][] = $res;
			}
		}
		return $this->_cache[$tbname];
	}

	/**
	 * Get the last error produced.
	 */
	public function error() {
		return $this->dbh->errorInfo();
	}

	/**
	 * Get the value of multiple fields from 1 record.
	 * @param string $fields The name of the fields separated by commas.
	 * @param string $tbname The name of the table.
	 * @param string $where_str A WHERE string to select the desired record.
	 * @param array $data The parameters for the given query string.
	 * @return An array { field => value, ... } or false if no record found.
	 */
	public function get_fields($fields, $tbname, $where_str = '', $data = array()) {
		$qstr = "SELECT $fields FROM $tbname" . (!empty($where_str) ? " WHERE $where_str" : '') . ' LIMIT 1';
		$q = $this->query($qstr, $data);
		if (is_array($res = $q->getrow())) {
			return (count($res) > 1 ? $res : array_shift($res));
		}
		return null;
	}

	/**
	 * Get the value of multiple fields from multiple records.
	 * @param string $fields The name of the fields separated by commas.
	 * @param string $tbname The name of the table.
	 * @param string $where_str A WHERE string to select the desired records.
	 * @param string $key_field The record field to use as key in the return array.
	 * @param callback $callback A function to process each retrieved record before adding it to the returned result.
	 * @return An array [{ field => value, ... }, ...] or false if no records found.
	 */
	public function get_records($fields, $tbname, $where_str = '', $data = array(), $key_field = '', $callback = false) {
		$qstr = "SELECT $fields FROM $tbname" . (!empty($where_str) ? " WHERE $where_str" : '');
		$q = $this->query($qstr, $data);
		if ($q->numrows() > 0) {
			$results = array();
			while (is_array($res = $q->getrow())) {
				if (!empty($key_field)) {
					$results[$res[$key_field]] = ($callback === false ? $res : call_user_func($callback, $res));
				}
				else {
					$results[] = ($callback === false ? $res : call_user_func($callback, $res));
				}
			}
			return $results;
		}
		return null;
	}

	/**
	 * Add a record to a table. This function looks at the table structure
	 * to determine what fields are required and picks them up from the
	 * supplied array.
	 * @param array $hash Where to look for field values { field => value, ... }
	 * @param string $tbname The table where to add the new record.
	 * @return The result of last_id() or false if the operation fails.
	 */
	public function add_record($hash, $tbname, $update_on_duplicate = false) {
		$fields = array();
		$values = array();
		$update = array();
		foreach ($this->describe($tbname) as $column) {
			if (isset($hash[$column['Field']])) {
				$fields[] = $column['Field'];
				$values[] = ':' . $column['Field'];
				if ($update_on_duplicate) {
					$update[] = "$column[Field] = :$column[Field]";
				}
			}
			elseif (isset($hash[':' . $column['Field']])) {
				$fields[] = $column['Field'];
				$values[] = $hash[':'. $column['Field']];
				if ($update_on_duplicate) {
					$update[] = "$column[Field] = " . $hash[':'. $column['Field']];
				}
			}
		}
		$fields_str = implode(', ', $fields);
		$values_str = implode(', ', $values);
		$qstr = "INSERT INTO $tbname ($fields_str) VALUES ($values_str)";
		if ($update_on_duplicate) {
			$qstr .= ' ON DUPLICATE KEY UPDATE ' . implode(', ', $update);
		}
		$q = $this->query($qstr, $hash);
		return $this->last_id();
	}

	/**
	 * Update a record in a table. This function looks at the table
	 * structure to determine what fields can be updated and updates only
	 * those present in the supplied array.
	 * @param array $hash Where to look for field values { field => value, ... }
	 * @param string $tbname The table where to add the new record.
	 * @param string $where_str A WHERE string to select the record that needs to be updated.
	 * @return boolean
	 */
	public function update_record($hash, $tbname, $where_str) {
		$values = array();
		foreach ($this->describe($tbname) as $column) {
			if (isset($hash[$column['Field']])) {
				$values[] = "$column[Field] = :$column[Field]";
			}
			elseif (isset($hash[':' . $column['Field']])) {
				$values[] = "$column[Field] = " . $hash[':' . $column['Field']];
			}
		}
		$values_str = implode(', ', $values);
		$q = $this->query("UPDATE $tbname SET $values_str WHERE $where_str", $hash);
		//return ($q->numrows() > 0);
		return true;
	}
}


class db_mysql_query {

	/**
	 * Internal reference to the database object associated with this query.
	 * @var object
	 */
	private $dbo;

	/**
	 * Prepared statement object.
	 * @var object
	 */
	private $sth;

	/**
	 * Whether we use named placeholders or not.
	 * @var boolean
	 */
	private $named_placeholders = true;

	/**
	 * The names of all query parameters.
	 * @var array
	 */
	private $param_names;

	/**
	 * Result set.
	 * @var array
	 */
	private $res;


	/**
	 * Constructor. Execute the specified query using the specified database
	 * object.
	 * @param object $db The database object.
	 * @param string $qstr The query string.
	 * @param array $data The query data.
	 */
	public function __construct(db_mysql &$dbo, $qstr, $data) {
		$this->dbo = $dbo;
		$this->extract_param_names($qstr);
		$this->sth = $this->dbo->dbh->prepare($qstr);
		$this->execute($data);
	}

	/**
	 * Extract parameter names from query string.
	 */
	private function extract_param_names($qstr) {
		if (strpos($qstr, '?') !== false) {
			$this->named_placeholders = false;
		}
		else {
			$this->param_names = array();
			if (preg_match_all('/:(\w+)/', $qstr, $matches)) {
				$this->param_names = $matches[1];
			}
		}
	}

	/**
	 * Execute this query.
	 */
	public function execute($data) {
		$this->res = null;
		return $this->sth->execute($this->filter_data($data));
	}

	/**
	 * Filter out any non query parameters from a data array.
	 */
	public function filter_data($data) {
		if (!$this->named_placeholders) {
			return $data;
		}

		$new_data = array();
		foreach ($this->param_names as $p) {
			$new_data[$p] = (isset($data[$p]) ? $data[$p] : null);
		}
		return $new_data;
	}

	/**
	 * Get the next row from the result set.
	 */
	public function getrow() {
		return ($this->res ? array_shift($this->res) : $this->sth->fetch(PDO::FETCH_ASSOC));
	}

	/**
	 * Get entire result from server into a local variable, to allow another
	 * query to run.
	 */
	public function getall() {
		$this->res = $this->sth->fetchAll(PDO::FETCH_ASSOC);
	}

	/**
	 * Get the number of rows that are in the result set.
	 */
	public function numrows() {
		return $this->sth->rowCount();
	}

	/**
	 * Get the last error produced.
	 */
	public function error() {
		return $this->sth->errorInfo();
	}
	
	/**
	 * Free.
	 */
	public function free() {
		$this->sth->closeCursor();
	}
}

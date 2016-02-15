<?php
/**
 * attribute model
 *
 ******************************************************************************/

class attribute_model extends app_model {
	protected $validation_sets = array(
		'default' => array(
      'name' => array(
        'required'
      ),
      'value' => array(
        'required'
      )
		)
	);

	protected $uniques = array(
    'value' => array(
      'within' => 'name',
			'error_message' => 'This attribute value is already defined.'
		)
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
   * Delete this record.
   */
  public function delete($id = null) {
    if (!($id = $this->require_id($id))) {
      return false;
    }

    $tb = $this->attr('tb');
    $ts = time();
    
    $this->query( "UPDATE $tb SET deleted_on = $ts WHERE id = $id");

    $this->clear();

    return true;
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

  /**
   * Add attribute.
   */
  public static function add($name, $value) {
    $model = new self();
    $tb = $model->attr('tb');

    $data = array(
      'name' => $name,
      'value' => $value,
      ':pos' => "(SELECT COUNT(*)+1 FROM $tb AS t1 WHERE name = :name AND deleted_on = 0)"
    );

    if (!$model->save($data)) {
      // check if we have an existing/deleted attribute and bring it back:
      $existing = new self(array('name' => $name, 'value' => $value));
      if ($existing->exists() && $existing->deleted_on > 0) {
        $pos = self::get_count(array('name' => $name, 'deleted_on' => 0));
        $existing->save(array(
          'deleted_on' => 0,
          'pos' => $pos + 1
        ));

        return $existing;
      }
    }

    return $model;
  }

  /**
   * Delete attribute.
   */
  public static function remove($id) {
    $model = new self();
    $model->delete($id);
  }

  /**
   * Get all values for a given attribute name.
   */
  public static function values($name) {
    $model = new self();
    $tb = $model->attr('tb');

    $qstr = "SELECT id, value FROM $tb WHERE name = :name AND deleted_on = 0 ORDER BY pos";
    $qparams = array('name' => $name);

    $values = array();
    $q = $model->query($qstr, $qparams);
    while (is_array($res = $q->getrow())) {
      $values[$res['id']] = $res['value'];
    }

    return $values;
  }

  /**
   * Update position for given IDs.
   */
  public static function update_pos($ordered_ids) {
    $model = new self();
    $tb = $model->attr('tb');

    if (count($ordered_ids)) {
      $pos = 1;

      foreach ($ordered_ids as $id) {
        $qstr = "UPDATE $tb SET pos = :pos WHERE id = :id";
        $model->db()->query($qstr, array(
          'pos' => $pos,
          'id' => $id
        ));

        $pos++;
      }
    }

    return true;
  }

  /**
   * Get all attributes, ready for display.
   */
  public static function get_tree($section = null) {
    $tree = array(
      'project' => array(
        'label' => 'Project Attributes',
        'list' => array(
          'game_type' => array(
            'label' => 'Game Type Dropdown',
            'placeholder' => 'Game Type',
            'list' => self::values('game_type')
          ),
          'game_hardware' => array(
            'label' => 'Game Hardware Dropdown',
            'placeholder' => 'Game Hardware',
            'list' => self::values('game_hardware')
          ),
          'age_group' => array(
            'label' => 'Age Group',
            'placeholder' => 'Age Group',
            'list' => self::values('age_group')
          )
        )
      ),
      'index' => array(
        'label' => 'Index Attributes',
        'list' => array(
          'index_data' => array(
            'label' => 'Index Data',
            'placeholder' => 'Index Type',
            'list' => self::values('index_data')
          )
        )
      ),
      'tester' => array(
        'label' => 'Tester Attributes',
        'list' => array(
          'experience' => array(
            'label' => 'Experience Dropdown',
            'placeholder' => 'Experience',
            'list' => self::values('experience')
          )
        )
      ),
      'ma' => array(
        'label' => 'Moving Average',
        'list' => array(
          'ma' => array(
            'label' => 'Moving Average Dropdown',
            'placeholder' => 'MA period (seconds)',
            'list' => self::values('ma')
          )
        )
      )
    );

    if (!is_null($section)) {
      return $tree[$section];
    }
    else {
      return $tree;
    }
  }
}

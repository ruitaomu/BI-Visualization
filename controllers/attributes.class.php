<?php
/**
 * attributes controller
 *
 ******************************************************************************/

class attributes_controller extends app_controller {
	/**
	 * Controller attributes.
	 * @var array
	 */
	protected $attr = array(
	);


	/**
	 * Init.
	 */
	public function init() {
		parent::init();

    // make sure only admins can access this:
    $this->require_user_type(1);

    $this->set('topnav', 'settings');
	}

	//////////////////////////////////////////////////////////////////////////////
	//
	// Actions
	//
	//////////////////////////////////////////////////////////////////////////////

	/**
	 * index.
	 */
	public function action_index() {
    $tab = $this->params->get('tab', 'project');
    $this->set('tab', $tab);

    $this->set('tree', attribute_model::get_tree());
	}

  /**
   * Add attribute.
   */
  public function action_add_attribute() {
    $name = $this->params->name;
    $value = $this->params->value;
    
    $attribute = attribute_model::add($name, $value);
    if ($attribute->exists()) {
      return $attribute->id + 0;
    }
    else {
      return $attribute->get_errors();
    }
  }

  /**
   * Delete attribute.
   */
  public function action_del_attribute() {
    attribute_model::remove($this->params->id);
    return 1;
  }

  /**
   * Sort attributes.
   */
  public function action_sort() {
    $ordered_ids = explode(',', $this->params->get('ordered_ids', ''));
    attribute_model::update_pos($ordered_ids);
    return true;
  }

	//////////////////////////////////////////////////////////////////////////////
	//
	// Private Methods
	//
	//////////////////////////////////////////////////////////////////////////////

}

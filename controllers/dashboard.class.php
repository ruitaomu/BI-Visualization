<?php
/**
 * dashboard controller
 *
 ******************************************************************************/

class dashboard_controller extends front_controller {
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

		$this->set('topnav', 'dashboard');
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
    $this->set(array(
      'projects' => project_model::get_count(),
      'testers' => tester_model::get_count(),
      'tags' => $this->db()->get_fields('COUNT(DISTINCT tag)', tb('tag'))
    ));
	}

	//////////////////////////////////////////////////////////////////////////////
	//
	// Private Methods
	//
	//////////////////////////////////////////////////////////////////////////////

}

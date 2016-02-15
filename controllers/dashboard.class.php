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

    $charts = array(
      'game_hardware' => array(
        'data' => project_model::get_count_by_attr('game_hardware')
      ),
      'game_type' => array(
        'data' => project_model::get_count_by_attr('game_type')
      ),
      'age_group' => array(
        'data' => project_model::get_count_by_attr('age_group')
      )
    );

    $this->set('charts_json', json_encode($charts));
	}

	//////////////////////////////////////////////////////////////////////////////
	//
	// Private Methods
	//
	//////////////////////////////////////////////////////////////////////////////

}

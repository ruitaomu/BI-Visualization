<?php
/**
 * tester model
 *
 ******************************************************************************/

class tester_model extends app_model {
	protected $validation_sets = array(
		'default' => array(
			'first_name' => array(
				'required'
      ),
			'last_name' => array(
				'required'
      ),
      'dob' => array(
        'required'
      ),
      'gender' => array(
        'required'
      ),
      'experience_id' => array(
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
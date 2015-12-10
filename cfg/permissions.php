<?php
/**
 * System Permissions
 *
 ******************************************************************************/

$CFG['PERMISSIONS'] = array(
	'System Configuration' => array(
		'manage_roles' => array(
			'name' => 'Manage Roles',
			'desc' => ''
		),

		'manage_users' => array(
			'name' => 'Manage Users',
			'desc' => ''
		)
	),

	'Application Features' => array(
		'manage_customers' => array(
			'name' => 'Manage Customers',
			'desc' => ''
    ),

		'manage_projects' => array(
			'name' => 'Manage Projects',
			'desc' => ''
    )
  )
);

/**
 * Define some permission lists to keep views simple.
 */
$CFG['P_ADMIN'] = implode(',', array_merge(
	array_keys($CFG['PERMISSIONS']['System Configuration'])
));

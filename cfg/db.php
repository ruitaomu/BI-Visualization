<?php
/**
 * Database Configuration
 *
 ******************************************************************************/

// database connections:
$CFG['DB'] = array(
	'default' => array(
		'name' => 'eegdashboard',
		'user' => 'eegdashboard',
		'pass' => 'eegdashboard',
		'host' => 'localhost',
		'type' => 'mysql'
	)
);

// prefix for table names:
$CFG['DB_PREFIX'] = '';

// table names:
$CFG['DBTABLE_TOKEN'] = $CFG['DB_PREFIX'] . 'token';
$CFG['DBTABLE_ROLE'] = $CFG['DB_PREFIX'] . 'role';
$CFG['DBTABLE_ROLEPERMISSION'] = $CFG['DB_PREFIX'] . 'role_permission';
$CFG['DBTABLE_USER'] = $CFG['DB_PREFIX'] . 'user';
$CFG['DBTABLE_USERROLE'] = $CFG['DB_PREFIX'] . 'user_role';

<?php
/**
 * Application Configuration
 *
 ******************************************************************************/

// Wistia settings:
$CFG['WISTIA'] = array(
  // password used to access the API:
  'pass' => '4c832d0b3f1533d5348f315bc98d40aed90a908f297abf2aa61e643f852d08a0',

  // where to upload videos:
  'project_id' => '1qo2skbafj'
);

$CFG['WISTIA']['upload_url'] = implode('', array(
  'https://upload.wistia.com?api_password=', $CFG['WISTIA']['pass'],
  '&project_id=', $CFG['WISTIA']['project_id']
));

$CFG['WISTIA']['status_url'] = implode('', array(
  'https://api.wistia.com/v1/medias/#ID.json',
  '?api_password=', $CFG['WISTIA']['pass']
));

$CFG['WISTIA']['delete_url'] = implode('', array(
  'https://api.wistia.com/v1/medias/#ID.json',
  '?api_password=', $CFG['WISTIA']['pass']
));

////////////////////////////////////////////////////////////////////////////////
//
// E-Mail Settings
//
////////////////////////////////////////////////////////////////////////////////

$CFG['EMAIL'] = array(
	'provider_name' => 'api_mandrill',

	'from' => 'support@example.com',
	'from_name' => 'EEG Dashboard',

	'support_email' => 'support@example.com'
);

/**
 * E-Mail Providers
 */

// Mandrill:
$CFG['MANDRILL'] = array(
  //TODO: change this for your account!
  'key' => 'D5Mt3fq4BA04oJyYQ3IEmw'
);

// SendGrid:
$CFG['SENDGRID'] = array(
	'username' => '',
	'password' => ''
);

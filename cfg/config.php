<?php
/**
 * Application Configuration
 *
 ******************************************************************************/

// Wistia settings:
$CFG['WISTIA'] = array(
  // password used to access the API:
  'pass' => '2666bfaa87562cb513e0c00d746b393c7cf40efa738e43bc673b30fa19cb63d1',

  // where to upload videos:
  'project_id' => 'ahk4hfmjux'
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
	'provider_name' => 'api_smtp',

	'from' => 'test@brain-intelligence.cn',
	'from_name' => 'EEG Dashboard',

	'support_email' => 'support@example.com'
);

/**
 * E-Mail Providers
 */

// Mandrill:
$CFG['MANDRILL'] = array(
  'key' => 'your key here'
);

// SendGrid:
$CFG['SENDGRID'] = array(
	'username' => '',
	'password' => ''
);

// SMTP:
$CFG['SMTP'] = array(
  'host' => 'smtp.office365.com',
  'port' => 587,
  'user' => 'test@brain-intelligence.cn',
  'pass' => 'Brain@20!6',
  'secure' => 'tls'
);

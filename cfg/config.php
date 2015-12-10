<?php
/**
 * Application Configuration
 *
 ******************************************************************************/


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

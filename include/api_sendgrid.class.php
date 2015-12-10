<?php
/**
 * api_sendgrid.class.php
 * 
 ******************************************************************************/
require_once(dirname(__FILE__) . '/vendors/sendgrid/SendGrid_loader.php');

class api_sendgrid {
	/**
	 * SendGrid object.
	 * @var object
	 */
	public $sendgrid;


	/**
	 * Constructor.
	 */
	public function __construct() {
		global $CFG;

		$this->sendgrid = new SendGrid(
			$CFG['SENDGRID']['username'],
			$CFG['SENDGRID']['password']
		);
	}

	/**
	 * Send a single e-mail.
	 *
	 * $params = array(
	 *	'to' => 'Some One <some.one@example.com>',
	 *	'from' => 'sender@example.com',
	 *	'from_name' => 'Sender',
	 *	'subject' => 'Subject Line',
	 *	'text' => 'Text version.',
	 *	'html' => '<b>HTML</b> version.'
	 * );
	 *
	 * The required fields are: to, from, either text or html.
	 */
	public function send($params) {
		global $CFG;

		$mail = new SendGrid\Mail();

		// to address:
		if (isset($params['to'])) {
			$mail->addTo($params['to']);
		}
		else {
			return false;
		}

		// from address:
		if (isset($params['from'])) {
			$mail->setFrom($params['from']);
		}
		elseif (isset($CFG['EMAIL']['from'])) {
			$mail->setFrom($CFG['EMAIL']['from']);
		}
		else {
			return false;
		}

		// from name:
		if (isset($params['from_name'])) {
			$mail->setFromName($params['from_name']);
		}
		elseif (isset($CFG['EMAIL']['from_name'])) {
			$mail->setFromName($CFG['EMAIL']['from_name']);
		}

		// subject:
		if (isset($params['subject'])) {
			$mail->setSubject($params['subject']);
		}

		// text:
		if (isset($params['text'])) {
			$mail->setText($params['text']);
		}

		// HTML:
		if (isset($params['html'])) {
			$mail->setHtml($params['html']);
		}

		// send the message:
		return $this->sendgrid->smtp->send($mail);
	}
}

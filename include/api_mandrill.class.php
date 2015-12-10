<?php
/**
 * api_mandrill.class.php
 * 
 ******************************************************************************/
require_once(dirname(__FILE__) . '/vendors/mandrill/src/Mandrill.php');

class api_mandrill {
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

		$this->mandrill = new Mandrill($CFG['MANDRILL']['key']);
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

    $message = array();

		// to address:
		if (isset($params['to'])) {
      if (preg_match('/^(.*)<(.*)>$/', $params['to'], $matches)) {
        $to = array(
          'email' => $matches[2],
          'name' => trim($matches[1])
        );

        $message['to'] = array($to);
      }
      else {
        $to = array(
          'email' => $params['to']
        );

        $message['to'] = array($to);
      }
		}
		else {
			return false;
		}

		// from address:
		if (isset($params['from'])) {
      $message['from_email'] = $params['from'];
		}
		elseif (isset($CFG['EMAIL']['from'])) {
      $message['from_email'] = $CFG['EMAIL']['from'];
		}
		else {
			return false;
		}

		// from name:
		if (isset($params['from_name'])) {
      $message['from_name'] = $params['from_name'];
		}
		elseif (isset($CFG['EMAIL']['from_name'])) {
			$message['from_name'] = $CFG['EMAIL']['from_name'];
		}

		// subject:
		if (isset($params['subject'])) {
			$message['subject'] = $params['subject'];
		}

		// text:
		if (isset($params['text'])) {
      $message['text'] = $params['text'];
		}

		// HTML:
		if (isset($params['html'])) {
      $message['html'] = $params['html'];
		}

		// send the message:
    try {
      $result = $this->mandrill->messages->send($message, true);
      return $result;
    }
    catch (Mandrill_Error $e) {
      return null;
    }
	}
}

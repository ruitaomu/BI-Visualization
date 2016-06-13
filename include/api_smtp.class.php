<?php
/**
 * api_sendgrid.class.php
 * 
 ******************************************************************************/
require_once(dirname(__FILE__) . '/vendors/PHPMailer-5.2.16/PHPMailerAutoload.php');

class api_smtp {
	/**
	 * PHPMailer object.
	 * @var object
	 */
	public $mail;


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

		$mail = new PHPMailer;
    $mail->isSMTP();
    $mail->Host = $CFG['SMTP']['host'];
    $mail->Port = $CFG['SMTP']['port'];
    $mail->Username = $CFG['SMTP']['user'];
    $mail->Password = $CFG['SMTP']['pass'];
    $mail->SMTPAuth = true;
    $mail->SMTPSecure = $CFG['SMTP']['secure'];;

    //$mail->SMTPDebug = 3;

		// to address:
		if (isset($params['to'])) {
      $name = $email = '';

      if (preg_match('/^(.*)<(.*)>$/', $params['to'], $matches)) {
        $name = trim($matches[1]);
        $email = $matches[2];
      }
      else {
        $email = $params['to'];
      }

      $mail->addAddress($email, $name);
		}
		else {
			return false;
		}

		// from address:
    $from = '';
		if (isset($params['from'])) {
			$from = $params['from'];
		}
		elseif (isset($CFG['EMAIL']['from'])) {
			$from = $CFG['EMAIL']['from'];
		}
		else {
			return false;
		}

		// from name:
    $from_name = '';;
		if (isset($params['from_name'])) {
			$from_name = $params['from_name'];
		}
		elseif (isset($CFG['EMAIL']['from_name'])) {
			$from_name = $CFG['EMAIL']['from_name'];
		}

    $mail->setFrom($from, $from_name);

		// subject:
		if (isset($params['subject'])) {
			$mail->Subject = $params['subject'];
		}

    $mail->Body = '';

		// text:
		if (isset($params['text'])) {
			$mail->Body = $params['text'];
		}

		// HTML:
		if (isset($params['html'])) {
      $mail->AltBody = $mail->Body;

      $mail->isHTML(true);
			$mail->Body = $params['html'];
		}

		// send the message:
		return $mail->send();
	}
}

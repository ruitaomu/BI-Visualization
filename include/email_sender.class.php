<?php
/**
 * email_sender.class.php
 *
 ******************************************************************************/

class email_sender extends service_provider {
	/**
	 * Constructor.
	 */
	public function __construct($provider_name = null) {
		parent::__construct('EMAIL', $provider_name);
	}

	/**
	 * Send an e-mail from a view.
	 */
	public function sendView($params, $view, $data = array()) {
		global $CFG;

		if (is_file("$CFG[ROOT_DIR]/views/emails/$view" . '_html.tpl')) {
			$params['html'] = view::get()->render("emails/$view" . '_html', $data);
		}
		if (is_file("$CFG[ROOT_DIR]/views/emails/$view" . '_text.tpl')) {
			$params['text'] = view::get()->render("emails/$view" . '_text', $data);
		}

		return $this->send($params);
	}
}

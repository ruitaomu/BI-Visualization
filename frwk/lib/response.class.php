<?php
/**
 * response.class.php
 *
 ******************************************************************************/

class response extends Exception {

	/**
	 * Response types.
	 */
	public static $TYPE_HTTP404 = 'http404';
	public static $TYPE_REDIRECT = 'redirect';
	public static $TYPE_ACCESS_DENIED = 'access_denied';
	public static $TYPE_AJAX_SUCCESS = 'ajax_success';
	public static $TYPE_AJAX_ERROR = 'ajax_error';

	/**
	 * Framework reference.
	 * @var object pointer
	 */
	public $frwk;

	/**
	 * Type of response.
	 * @var string
	 */
	public $type;

	/**
	 * Response parameters (type specific).
	 * @var array
	 */
	public $params;


	/**
	 * Constructor.
	 */
	public function __construct($type, $params) {
		parent::__construct();

		$this->frwk = framework::get();
		$this->type = $type;
		$this->params = $params;
	}

	/**
	 * Out.
	 */
	public function out() {
		return call_user_func(array($this, 'out_' . $this->type));
	}

	//////////////////////////////////////////////////////////////////////////////
	//
	// Type Specific 'out' Functions
	//
	//////////////////////////////////////////////////////////////////////////////

	/**
	 * HTTP404.
	 */
	private function out_http404() {
		switch ($this->frwk->cfg['MODE']) {
		case 'web':
			$view = view::get();
			header('HTTP/1.1 404 Not Found');

			foreach ($this->params as $tpl => $data) {
				return $view->render("http404/$tpl", $data);
			}
			break;
		default:
			break;
		}
	}

	/**
	 * Redirect.
	 */
	private function out_redirect() {
		header('Location: ' . $this->params['url']);
	}

	/**
	 * Access denied.
	 */
	private function out_access_denied() {
		if ($this->frwk->req->is('ajax')) {
			return self::ajax_error(_('Access denied.'));
		}
		else {
			return self::redirect(utils::href(null));
		}
	}

	/**
	 * AJAX success.
	 */
	private function out_ajax_success() {
		return array('ok' => true, 'data' => $this->params);
	}

	/**
	 * AJAX error.
	 */
	private function out_ajax_error() {
		return array('ok' => false, 'errors' => $this->params);
	}

	//////////////////////////////////////////////////////////////////////////////
	//
	// Static
	//
	//////////////////////////////////////////////////////////////////////////////

	/**
	 * Shorthand for a http404 response.
	 */
	public static function http404($params) {
		return new response(self::$TYPE_HTTP404, $params);
	}

	/**
	 * Shorthand for a redirect response.
	 */
	public static function redirect($url, $params = array()) {
		$params['url'] = $url;
		return new response(self::$TYPE_REDIRECT, $params);
	}

	/**
	 * Shorthand for an access denied response.
	 */
	public static function access_denied($params = null) {
		return new response(self::$TYPE_ACCESS_DENIED, $params);
	}

	/**
	 * Shorthand for an AJAX success response.
	 */
	public static function ajax_success($params = null) {
		return new response(self::$TYPE_AJAX_SUCCESS, $params);
	}

	/**
	 * Shorthand for an AJAX error response.
	 */
	public static function ajax_error($params = null) {
		return new response(self::$TYPE_AJAX_ERROR, $params);
	}
}

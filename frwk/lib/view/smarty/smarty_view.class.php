<?php
/**
 * smarty_view.class.php
 *
 ******************************************************************************/
require_once(dirname(__FILE__) . '/Smarty-3.1.13/libs/Smarty.class.php');

class smarty_view {
	/**
	 * Framework reference.
	 * @var object
	 */
	public $frwk;

	/**
	 * Smarty object.
	 * @var object
	 */
	public $smarty;


	/**
	 * Constructor.
	 */
	public function __construct() {
		global $CFG;

		$this->frwk = framework::get();
		$this->smarty = new Smarty();

		$this->smarty->setCompileDir(
			"$CFG[ROOT_DIR]/tmp/smarty/$CFG[MODE]/templates_c"
		);
		$this->smarty->setCacheDir(
			"$CFG[ROOT_DIR]/tmp/smarty/$CFG[MODE]/cache"
		);

		$compile_id_parts = array();

		// theme support:
		$theme = $this->frwk->cfg['THEME'];
		if (!empty($theme)) {
			$this->smarty->addTemplateDir(
				"$CFG[ROOT_DIR]/views/themes/$theme"
			);
			$compile_id_parts[] = $theme;
		}

		$this->smarty->addTemplateDir("$CFG[ROOT_DIR]/views");

		if (count($compile_id_parts)) {
			$this->smarty->compile_id = implode('|', $compile_id_parts);
		}

		$this->smarty->error_reporting = E_ALL & ~E_NOTICE;
		//$this->smarty->force_compile = true;

		$this->smarty->registerPlugin(
			'modifier', 'i18n', array(&$this, 'smarty_i18n')
		);
		$this->smarty->registerPlugin(
			'modifier', 'p_any', array(&$this, 'smarty_p_any')
		);
		$this->smarty->registerPlugin(
			'modifier', 'p_all', array(&$this, 'smarty_p_all')
		);
		$this->smarty->registerPlugin(
			'modifier', 'slug', array(&$this, 'smarty_slug')
		);
		$this->smarty->registerPlugin(
			'modifier', 'json', array(&$this, 'smarty_json')
		);
		$this->smarty->registerPlugin(
			'function', 'href', array(&$this, 'smarty_href')
		);
		$this->smarty->registerPlugin(
			'function', 'show_errors', array(&$this, 'smarty_show_errors')
		);
		$this->smarty->registerPlugin(
			'function', 'flash', array(&$this, 'smarty_flash')
		);
		$this->smarty->registerPlugin(
			'function', 'assets_url', array(&$this, 'smarty_assets_url')
		);
	}

	/**
	 * Render.
	 */
	public function render($view, $data = array()) {
		$this->smarty->assign($data + $this->get_default_data());

		$view = $view . '.tpl';

		try {
			return $this->smarty->fetch($view);
		}
		catch (Exception $e) {
			return response::http404(array('view' => array('view' => $view)));
		}
	}

	/**
	 * Default data exported to the view layer.
	 */
	private function get_default_data() {
		return array(
			'BASE' => $this->frwk->cfg['BASE_URL'],
			'CFG' => $this->frwk->cfg,
			'SESSION' => $this->frwk->session()->get()
		);
	}

	//////////////////////////////////////////////////////////////////////////////
	//
	// Smarty Plugins
	//
	//////////////////////////////////////////////////////////////////////////////

	public function smarty_i18n($msg) {
		return _($msg);
	}
	
	public function smarty_p_any($p_list) {
		return auth::require_permissions(
			array('any' => preg_split('/\s*,\s*/', $p_list)),
			false
		);
	}

	public function smarty_p_all($p_list) {
		return auth::require_permissions(
			array('all' => preg_split('/\s*,\s*/', $p_list)),
			false
		);
	}

	public function smarty_slug($name) {
		$name = str_replace('"', '', str_replace("'", '', $name));
		$name = preg_replace('/[^a-z0-9]+/i', '-', $name);
		$name = preg_replace('/^\-*|\-*$/', '', $name);

		return strtolower($name);
	}

	public function smarty_json($v) {
		return json_encode($v);
	}

	public function smarty_href($params) {
		return utils::href($params);
	}

	public function smarty_show_errors($params) {
		$ret = '';
		if (isset($params['errors']) && $params['errors']) {
			$form = (isset($params['form']) ? $params['form'] : '');
			$errors = json_encode($params['errors']);
			$ret = "<script type=\"text/javascript\">FRWK.Forms.show_errors('$form', $errors);</script>";
		}
		return $ret;
	}

	public function smarty_flash($params) {
		$name = (isset($params['name']) ? $params['name'] : 'flash');
		$data = $this->frwk->session()->get($name);

		if ($data) {
			if (!is_array($data)) $data = array('message' => $data);
			$data += array(
				'class' => 'success',
				'html' => '<div class="alert alert-%s">%s%s</div>'
			);

			$close = '';
			if (!isset($params['close']) || $params['close']) {
				$close = '<button class="close" data-dismiss="alert">&times;</button>';
			}

			return sprintf($data['html'], $data['class'], $close, $data['message']);
		}
		
		return '';
	}

	public function smarty_assets_url($params) {
		global $CFG;

		$prefix = $CFG['BASE_URL'];
		if (isset($params['absolute']) && $params['absolute']) {
			$prefix = $CFG['ROOT_URL'];
		}

		$theme = '';
		if (isset($CFG['THEME']) && !empty($CFG['THEME'])) {
			$theme = $CFG['THEME'];
		}

		return $prefix . '/assets' . (!empty($theme) ? "/themes/$theme" : '');
	}
}

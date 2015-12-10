<?php
/**
 * frwk controller
 *
 ******************************************************************************/

class frwk_controller extends app_controller {
	/**
	 * Controller attributes.
	 * @var array
	 */
	protected $attr = array(
	);


	/**
	 * Init.
	 */
	public function init() {
		parent::init();
	}

	//////////////////////////////////////////////////////////////////////////////
	//
	// Actions
	//
	//////////////////////////////////////////////////////////////////////////////

	/**
	 * Retrieve validation rules.
	 */
	public function action_validation_rules() {
		global $FRWK_AUTOLOAD_SILENT;

		$label = $this->params->label;

		if (empty($label)) {
			return false;
		}

		if (preg_match('/(.+_model)\:\:(.+)$/', $label, $matches)) {
			$FRWK_AUTOLOAD_SILENT = true;
			$sw = class_exists($matches[1]);
			$FRWK_AUTOLOAD_SILENT = null;
			
			if ($sw) {
				$model = new $matches[1];
				$fn = array($model, 'get_validation_rules');
				
				// support multiple labels separated by commas:
				$labels = explode(',', $matches[2]);

				return call_user_func_array($fn, $labels);
			}
		}

		if (isset($this->frwk->cfg['VALIDATION'][$label])) {
			return validation::fix($this->frwk->cfg['VALIDATION'][$label]);
		}

		return false;
	}

	//////////////////////////////////////////////////////////////////////////////
	//
	// Private Methods
	//
	//////////////////////////////////////////////////////////////////////////////

}

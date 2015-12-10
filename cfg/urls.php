<?php
/**
 * Routing Rules
 *
 ******************************************************************************/

// application specific URLs:
router::set_rules(array(
	// root URL:
	'' => null
));

// generic routes:
router::add_rules(
	'(:any:module)/(:any:controller)/(:any:action)',
	'(:any:module)/(:any:controller)',
	'(:any:controller)/(:any:action)',
	'(:any:controller)',
	'(:any:module)',
	null
);

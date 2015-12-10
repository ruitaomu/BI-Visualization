<!doctype html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{block name='title'}{/block}</title>
<meta name="description" content="{block name='meta_description'}{/block}">
<meta name="keywords" content="{block name='meta_keywords'}{/block}">

<!-- theme -->
<link href="{$BASE}/theme/css/bootstrap.min.css" rel="stylesheet">
<link href="{$BASE}/theme/css/bootstrap-reset.css" rel="stylesheet">
<link href="{$BASE}/theme/assets/font-awesome/css/font-awesome.css" rel="stylesheet">
<link href="{$BASE}/theme/css/style.css" rel="stylesheet">
<link href="{$BASE}/theme/css/style-responsive.css" rel="stylesheet">
<!--[if lt IE 9]>
<script src="{$BASE}/theme/js/html5shiv.js"></script>
<script src="{$BASE}/theme/js/respond.min.js"></script>
<![endif]-->

<!--
<link type="text/css" href="{$BASE}/lib/bootstrap/css/bootstrap.min.css" rel="stylesheet">
<link type="text/css" href="{$BASE}/css/common.css" rel="stylesheet">
-->
{block name='head'}{/block}
<script type="text/javascript" src="{$BASE}/lib/less/less.min.js"></script>
</head>
<body>
{block name='content'}{/block}

<!-- theme -->
<script src="{$BASE}/theme/js/jquery.js"></script>
<script src="{$BASE}/theme/js/bootstrap.min.js"></script>

<!--
<script type="text/javascript" src="{$BASE}/lib/jquery/jquery.min.js"></script>
<script type="text/javascript" src="{$BASE}/lib/bootstrap/js/bootstrap.min.js"></script>
-->
<script type="text/javascript">
	var FRWK = {
		'BASE': '{$BASE}'
	};
</script>
{block name='foot'}{/block}
</body>
</html>

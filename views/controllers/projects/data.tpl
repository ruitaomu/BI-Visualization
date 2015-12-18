{extends 'layouts/front.tpl'}
{block name='head' append}
<link type="text/css" href="{$BASE}/lib/select2/select2.css" rel="stylesheet">
<link type="text/css" href="{$BASE}/lib/select2-bootstrap/select2-bootstrap.css" rel="stylesheet">
<link type="text/css" href="{$BASE}/lib/fileupload/css/jquery.fileupload-ui.css" rel="stylesheet">
<link type="text/css" href="{$BASE}/css/project_data.css" rel="stylesheet">
{/block}
{block name='content'}
<section class="wrapper">
  {flash}
  <section class="panel">
    <div class="panel-heading">
	    <span class="lead">Projects | {$title}</span>
      {include file='controllers/projects/tabs.tpl'}
    </div>
    <div class="panel-body">
      <div id="data_container" class="row">
        {include file='partials/data_widget.tpl'}
        {foreach $testers as $t}
          {include file='partials/data_widget.tpl'}
        {/foreach}
      </div>
    </div>
  </section>
</section>
{/block}
{block name='foot' append}
<script charset="ISO-8859-1" src="//fast.wistia.com/assets/external/E-v1.js"></script>
<script type="text/javascript" src="{$BASE}/lib/select2/select2.js"></script>
<script type="text/javascript" src="{$BASE}/lib/frwk/js/forms.js"></script>
<script type="text/javascript" src="{$BASE}/lib/fileupload/js/vendor/jquery.ui.widget.js"></script>
<script type="text/javascript" src="{$BASE}/lib/fileupload/js/jquery.iframe-transport.js"></script>
<script type="text/javascript" src="{$BASE}/lib/fileupload/js/jquery.fileupload.js"></script>
<script type="text/javascript" src="{$BASE}/js/project_data.js"></script>
<script type="text/javascript">
  var availableTesters = {$available_testers_json};
  var uploadUrl = '{$CFG.WISTIA.upload_url}';
  var statusUrl = '{$CFG.WISTIA.status_url}';
</script>
{show_errors form='creupd' errors=$errors}
{/block}

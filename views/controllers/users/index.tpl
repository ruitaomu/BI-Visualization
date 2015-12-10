{extends 'layouts/front.tpl'}
{block name='head' append}
<link type="text/css" href="{$BASE}/lib/datatables_custom/datatables.css" rel="stylesheet">
{/block}
{block name='content'}
<section class="wrapper">
  {flash}
  <section class="panel">
    <div class="panel-heading">
	    <span class="lead">{$u_name}s | {$count} {$u_name}{if $count != 1}s{/if}</span>
    </div>
    <div class="panel-body">
    	<form action="{href action='delete'}" method="post">
    		<table id="t1" class="table table-striped x-datatables">
    			<thead>
    				<tr>
    					<th width="10"><input type="checkbox"></th>
    					<th>{'Name'|i18n}</th>
    					<th width="120">{'Created on'|i18n}</th>
    				</tr>
    			</thead>
    			<tbody>
    				<tr><td colspan="3">&nbsp;</td></tr>
    			</tbody>
    		</table>
        <!--
    		<button type="submit" class="btn btn-danger">{'Delete Selected'|i18n}</button>
    		<a href="{href action='create'}" class="btn btn-primary">{'Create'|i18n}</a>
        -->
    	</form>
    </div>
  </section>
</section>
{/block}
{block name='foot' append}
<script type="text/javascript" src="{$BASE}/lib/datejs/date.js"></script>
<script type="text/javascript">
	var update_url = "{href action='update'}";
	var profile_url = "{href module='' controller='profile'}";
	var user_id = "{$SESSION.user_info.id}";
	var dtcfg = {
		't1': {
			'bProcessing': true,
			'bServerSide': true,
			'sAjaxSource': "{href action='datatables'}",
			'aoColumns': [
				{
					'mData': 'id',
					'mRender': function(data, type, row) {
						return '<input type="checkbox" name="ids[]" value="' + data + '">';
					}
				},
				{
					'mData': 'email',
					'mRender': function(data, type, row) {
						var url = (row.id == user_id ? profile_url : update_url + '?id=' + row.id);
						return [
							'<a href="' + url + '">', row.first_name + ' ' + row.last_name, '</a>',
							'<br>',
							data
						].join('');
					}
				},
				{
					'mData': 'created_on',
					'mRender': function(data, type, row) {
						return (new Date(parseInt(data) * 1000)).toString('MMM d, yyyy');
					}
				}
			]
		}
	};
</script>
{include file='partials/datatables.tpl'}
{/block}

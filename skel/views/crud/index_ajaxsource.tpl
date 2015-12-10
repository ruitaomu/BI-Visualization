{extends 'layouts/admin.tpl'}
{block name='head' append}
<link type="text/css" href="{$BASE}/lib/datatables_custom/datatables.css" rel="stylesheet">
{/block}
{block name='content'}
<div class="container">
	<h1>{'Sample'|i18n}</h1>
	<p class="lead">
		{''|i18n}
	</p>
	<br>
	{flash}
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
		<button type="submit" class="btn btn-danger">{'Delete Selected'|i18n}</button>
		<a href="{href action='create'}" class="btn btn-primary">{'Create'|i18n}</a>
	</form>
</div>
{/block}
{block name='foot' append}
<script type="text/javascript" src="{$BASE}/lib/datejs/date.js"></script>
<script type="text/javascript">
	var update_url = '{href action="update"}';
	var dtcfg = {
		't1': {
			'bProcessing': true,
			'bServerSide': true,
			'sAjaxSource': "{href action='datatables'}",
			'aoColumnDefs': [
				{ 'aTargets': [0], 'bSortable': false },
				{
					'mData': 'id',
					'mRender': function(data, type, row) {
						return '<input type="checkbox" name="ids[]" value="' + data + '">';
					},
					'aTargets': [0]
				},
				{
					'mData': 'name',
					'mRender': function(data, type, row) {
						return '<a href="' + update_url + '?id=' + row['id'] + '">' + data + '</a>';
					},
					'aTargets': [1]
				},
				{
					'mData': 'created_on',
					'mRender': function(data, type, row) {
						return (new Date(parseInt(data) * 1000)).toString('MMM d, yyyy');
					},
					'aTargets': [2]
				}
			]
		}
	};
</script>
{include file='partials/datatables.tpl'}
{/block}

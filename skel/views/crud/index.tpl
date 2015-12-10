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
				{foreach $items as $item}
					<tr>
						<td><input type="checkbox" name="ids[]" value="{$item.id}"></td>
						<td><a href="{href action='update'}?id={$item.id}">{$item.name}</a></td>
						<td>{$item.created_on|date_format}</td>
					</tr>
				{/foreach}
			</tbody>
		</table>
		<button type="submit" class="btn btn-danger">{'Delete Selected'|i18n}</button>
		<a href="{href action='create'}" class="btn btn-primary">{'Create'|i18n}</a>
	</form>
</div>
{/block}
{block name='foot' append}
{include file='partials/datatables.tpl'}
{/block}

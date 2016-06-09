{extends 'layouts/front.tpl'}
{block name='head' append}
<link type="text/css" href="{$BASE}/lib/datatables_custom/datatables.css" rel="stylesheet">
{/block}
{block name='content'}
<section class="wrapper">
  {flash}
  <section class="panel">
    <div class="panel-heading">
	    <span class="lead">Projects | {$count} Project{if $count != 1}s{/if}</span>
      {include file='controllers/projects/tabs1.tpl'}
    </div>
    <div class="panel-body">
    	<form action="{href action='delete'}" method="post">
    		<table id="t1" class="table table-striped x-datatables">
    			<thead>
    				<tr>
    					<th width="10"><input type="checkbox"></th>
    					<th>{'Title'|i18n}</th>
    					<th>{'Customer'|i18n}</th>
    					<th>{'Number of Testers'|i18n}</th>
    					<th width="120">{'Created on'|i18n}</th>
    				</tr>
    			</thead>
    			<tbody>
    				<tr><td colspan="5">&nbsp;</td></tr>
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
	var update_url = "{href action='project-data'}";
  var filters = {$filters_json};
	var dtcfg = {
		't1': {
			'bProcessing': true,
			'bServerSide': true,
			'sAjaxSource': "{href action='datatables'}",
      'fnServerParams': function(aaData) {
        for (var k in filters) {
          aaData.push({
            'name': 'filters[' + k + ']',
            'value': filters[k]
          });
        }
      },
			'aoColumns': [
				{
					'mData': 'id',
					'mRender': function(data, type, row) {
						return '<input type="checkbox" name="ids[]" value="' + data + '">';
					}
				},
				{
					'mData': 'title',
					'mRender': function(data, type, row) {
            return '<a href="' + update_url + '?id=' + row['id'] + '">' + data + '</a>';
          }
				},
        {
          'mData': 'customer'
        },
        {
          'mData': 'num_testers'
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

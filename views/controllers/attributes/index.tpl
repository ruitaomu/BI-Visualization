{extends 'layouts/front.tpl'}
{block name='content'}
<section class="wrapper">
  <section class="panel">
    <div class="panel-heading">
	    <span class="lead">Settings | Attributes</span>
      <ul class="nav nav-tabs tabs">
        {foreach $tree as $id => $type}
        <li {if $tab eq $id}class="active"{/if}><a href="#tab-{$id}" data-toggle="tab">{$type.label}</a></li>
        {/foreach}
      </ul>
    </div>
    <div class="panel-body">
      <div class="tab-content">
        {foreach $tree as $id => $type}
        <div id="tab-{$id}" class="tab-pane {if $tab eq $id}active{/if}">
          {foreach $type.list as $name => $attr}
          <div class="panel task-widget" style="background-color: #fafafa;">
            <div class="panel-heading">{$attr.label}</div>
            <div class="panel-body">
              <ul class="task-list ui-sortable">
                {foreach $attr.list as $attr_id => $value}
                <li data-id="{$attr_id}">{$value}<i class="fa fa-trash-o"></i></li>
                {/foreach}
              </ul>
              <form class="form-inline" data-name="{$name}">
                <input type="text" class="form-control" placeholder="{$attr.placeholder}" maxlength="64">
                <button class="btn btn-primary">Add</button>
              </form>
            </div>
          </div>
          {/foreach}
        </div>
        {/foreach}
      </div>
    </div>
  </section>
</section>
{/block}
{block name='foot' append}
<script type="text/javascript" src="{$BASE}/lib/jquery-ui/sortable.js"></script>
<script type="text/javascript" src="{$BASE}/lib/frwk/js/forms.js"></script>
<script type="text/javascript">
  $(function() {
    // sort attributes:
    var sortUrl = '{href action="sort"}';
    $('.ui-sortable').sortable({
      'update': function(e, ui) {
        var $ul = $(ui.item).closest('ul');
        var ids = [];

        $ul.children().each(function() {
          ids.push($(this).attr('data-id'));
        });

        $.post(sortUrl, { 'ordered_ids': ids.join(',') });
      }
    });

    // add an attribute:
    var addUrl = '{href action="add-attribute"}';
    $(document).on('submit', 'form.form-inline', function(e) {
      var $form = $(e.target);
      var $input = $form.find('input');
      var name = $form.attr('data-name');
      var value = $input.val();
      
      $.post(addUrl, { name: name, value: value }, function(response) {
        response = JSON.parse(response);
        if (typeof(response) == 'number' && response > 0) {
          var $li = $('<li></li>').attr('data-id', response).text(value);
          $li.append('<i class="fa fa-trash-o"></i>');
          $form.siblings('ul').append($li);
        }

        $input.val('').focus();
      });

      return false;
    });

    // delete attribute:
    var delUrl = '{href action="del-attribute"}';
    $(document).on('click', '.ui-sortable li i', function(e) {
      var $li = $(e.target).closest('li');

      $.post(delUrl, { id: $li.attr('data-id') }, function() {
        $li.remove();
      });
    });
  });
</script>
{/block}

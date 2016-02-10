<div class="panel filters">
  <div class="panel-heading">
    Filters
  </div>
  <div class="panel-body">
    <form id="filters">
      <select name="customer_id" class="form-control" placeholder="Customer">
        <option value="">Customer</option>
        {html_options options=$customer_opt selected=$filters.customer_id}
      </select>
      {foreach $project_filters.list as $name => $attr}
        <select name="{$name}_id" class="form-control" placeholder="{$attr.placeholder}">
          <option value="">{$attr.placeholder}</option>
          {html_options options=$attr.list selected=$filters["{$name}_id"]}
        </select>
      {/foreach}
      <div style="text-align: center; margin-top: 15px;">
        <button class="btn btn-primary">Apply</button>
        {if $tab eq 'data'}
          <br><br>
          <a href="javascript:;" id="view-projects">View Projects in this Group</a>
        {/if}
      </div>
    </form>
  </div>
</div>

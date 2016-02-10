<ul class="nav nav-tabs tabs">
  <li class="{if $tab eq 'general'}active{/if}"><a href="{if $id}../update/?id={$id}{else}../create/{/if}">General</a></li>
  <li class="{if $tab eq 'data'}active{/if} {if !$id}disabled{/if}"><a href="{if $id}../project-data/?id={$id}{else}javascript:;{/if}">Data</a></li>
  <li class="{if $tab eq 'visualisation'}active{/if} {if !$id}disabled{/if}"><a href="{if $id}../project-data-visualisation/?id={$id}{else}javascript:;{/if}">Visualisation</a></li>
</ul>

<header class="header white-bg">
  <div class="navbar-header">
    <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
      <span class="fa fa-bars"></span>
    </button>
    <a href="{$BASE}/" class="logo" >EEG<span>Dashboard</span></a>
    <div class="horizontal-menu navbar-collapse collapse">
      <ul class="nav navbar-nav">
				<li id="topnav_dashboard"><a href="{href controller='dashboard'}">{'Dashboard'|i18n}</a></li>
				<li id="topnav_customers"><a href="javascript:;">{'Customers'|i18n}</a></li>
				<li id="topnav_projects"><a href="javascript:;">{'Projects'|i18n}</a></li>
				<li id="topnav_testers"><a href="javascript:;">{'Testers'|i18n}</a></li>
				{if $SESSION.user_info.type eq 1}
				<li id="topnav_employees"><a href="{href controller='employees'}">{'Employees'|i18n}</a></li>
				<li id="topnav_settings" class="dropdown">
          <a data-toggle="dropdown" class="dropdown-toggle" href="javascript:;">{'Settings'|i18n} <i class="fa fa-angle-down"></i></a>
          <ul class="dropdown-menu">
            <li><a href="javascript:;">Attributes</a></li>
            <li><a href="{href controller='admins'}">Manage Admins</a></li>
          </ul>
        </li>
        {/if}
      </ul>
    </div>
    <div class="top-nav">
      <ul class="nav pull-right top-menu">
        <li class="dropdown">
          <a data-toggle="dropdown" class="dropdown-toggle" href="javascript:;"><span class="fa fa-user fa-lg" style="padding: 8px 0;"></span>&nbsp;&nbsp;<span class="username">{$SESSION.user_info.name}</span> <b class="fa fa-angle-down"></b></a>
          <ul class="dropdown-menu extended logout">
            <div class="log-arrow-up"></div>
            {if $SESSION.user_info.type eq 1}
            <li style="width: 50%;"><a href="{href controller='profile'}"><i class="fa fa-suitcase"></i>Profile</a></li>
            <li style="width: 50%;"><a href="javascript:;"><i class="fa fa-cog"></i>Settings</a></li>
            {else}
            <li style="width: 100%;"><a href="{href controller='profile'}"><i class="fa fa-suitcase"></i>Profile</a></li>
            {/if}
            <li><a href="{href controller='logout'}"><i class="fa fa-key"></i>Log Out</a></li>
          </ul>
        </li>
      </ul>
    </div>
  </div>
</header>

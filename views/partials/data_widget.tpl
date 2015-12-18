<div class="data-widget {if $t}added{/if} {if $t.wistia_video_hashed_id}has-video{/if} col-lg-3 col-md-4 col-sm-6">
  <div class="add"><span>+</span><br>click to add project data</div>
  <form data-action-add-tester="{href action='add-tester'}?id={$id}" data-action-del-tester="{href action='del-tester'}?id={$id}" data-action-set-video-hashed-id="{href action='set-video-hashed-id'}?id={$id}" {if $t}data-tester_id="{$t.tester_id}"{/if}>
    <div class="panel">
      <div class="panel-heading">
        <span class="tester-name">{if $t}{$t.name}{else}&nbsp;{/if}</span>
        <div class="tester-select">
          <input type="hidden" name="tester_id" class="form-control" placeholder="Select Tester">
        </div>
        <div class="delete">
          <div class="dropdown">
            <a href="javascript:;" data-toggle="dropdown"><i class="fa fa-trash-o"></i></a>
            <ul class="dropdown-menu dropdown-menu-right">
              <li><a href="javascript:;" data-delete="video">Delete video</a></li>
              <li><a href="javascript:;">Delete index file</a></li>
              <li><a href="javascript:;">Delete tags file</a></li>
              <li class="divider"></li>
              <li><a href="javascript:;" data-delete="all">Delete Everything</a></li>
            </ul>
          </div>
        </div>
      </div>
      <div class="panel-body">
        <div class="embed-responsive embed-responsive-16by9">
          <div class="embed-responsive-item">
            {if $t.wistia_video_hashed_id}
              <div class="wistia_responsive_padding" style="padding:56.25% 0 0 0;position:relative;"><div class="wistia_responsive_wrapper" style="height:100%;left:0;position:absolute;top:0;width:100%;"><iframe src="//fast.wistia.net/embed/iframe/{$t.wistia_video_hashed_id}?videoFoam=true" allowtransparency="true" frameborder="0" scrolling="no" class="wistia_embed" name="wistia_embed" allowfullscreen mozallowfullscreen webkitallowfullscreen oallowfullscreen msallowfullscreen width="100%" height="100%"></iframe></div></div>
            {/if}
            <div class="file-control fileinput-button file-control-video">
              <input type="file" class="fileupload" name="file">
              <div class="placeholder">
                <i class="fa fa-video-camera fa-5x"></i>
                <span>click to upload video</span>
              </div>
            </div>
            <div class="upload-progress"></div>
          </div>
        </div>

        <div class="block block-index">
          <div class="file-control fileinput-button">
            <input type="file" class="fileupload">
            <div class="placeholder">
              <i class="fa fa-paperclip fa-2x"></i>
              <span>upload index file</span>
            </div>
          </div>
        </div>

        <div class="block block-tags">
          <div class="file-control fileinput-button">
            <input type="file" class="fileupload">
            <div class="placeholder">
              <i class="fa fa-tags fa-2x"></i>
              <span>upload tags file</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </form>
</div>
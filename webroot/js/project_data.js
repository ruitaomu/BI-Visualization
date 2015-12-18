(function() {
  $(function() {
    $('.data-widget.added').each(function() {
      var $el = $(this);

      if (!$el.is('.has-video')) {
        setupVideoUpload($el);
      }
    });

    // add a new tester input widget to the UI:
    $('#data_container').on('click', '.data-widget:first-child', function(e) {
      var $el;

      // check if we already have a "new" widget:
      $el = $('#data_container').find('.data-widget.new');
      if ($el.length) {
        $el.removeClass('in');
        setTimeout(function() { $el.addClass('in'); }, 250);
        return;
      }
      
      var $el = $(e.target).closest('.data-widget');
      $clone = $el.clone().addClass('empty new fade');
      $el.after($clone);

      setupTesterDropdown($clone.find('[name="tester_id"]'));

      setTimeout(function() { $clone.addClass('in'); }, 250);
    });

    // delete tester data:
    $('#data_container').on('click', 'a[data-delete]', function(e) {
      var $el = $(e.target),
          $form = $el.closest('form'),
          $widget = $el.closest('.data-widget'),
          what = $el.attr('data-delete');

      if (!confirm("Are you sure?")) {
        return false;
      }

      $.ajax({
        url: $form.attr('data-action-del-tester'),
        method: 'post',
        dataType: 'json',
        data: {
          ajax: 1,
          tester_id: $form.attr('data-tester_id'),
          what: what
        },
        success: function(json) {
          if (json.ok) {
            if (what == 'all') {
              $widget.remove();
            }
            else {
              if (what == 'video') {
                $widget.find('.wistia_responsive_padding').remove();
              }

              $widget.removeClass('has-' + what);
            }
          }
        }
      });
    });
  });

  function setupVideoUpload($el) {
    var url = uploadUrl;

    $el.find('.file-control-video input')
    .attr('data-url', url)
    .fileupload({
      add: function(e, data) {
        var file = data.files[0];

        if (!(/(\.|\/)(mp4|mov|wmv|avi|mpe?g)$/i).test(file.name)) {
          return;
        }

        var $_el = $el.find('.embed-responsive-item');

        data.context = {
          '$el': $el,
          '$progresstext': $_el.find('.placeholder span'),
          '$progressbar': $_el.find('.upload-progress')
        };

        $_el.find('.fileinput-button').addClass('uploading');
        data.submit();
      },

      progress: showUploadProgress,

      done: function(e, data) {
        var id = data.result.hashed_id;

        var embed = '<div class="wistia_responsive_padding" style="padding:56.25% 0 0 0;position:relative;"><div class="wistia_responsive_wrapper" style="height:100%;left:0;position:absolute;top:0;width:100%;"><iframe src="//fast.wistia.net/embed/iframe/' + id + '?videoFoam=true" allowtransparency="true" frameborder="0" scrolling="no" class="wistia_embed" name="wistia_embed" allowfullscreen mozallowfullscreen webkitallowfullscreen oallowfullscreen msallowfullscreen width="100%" height="100%"></iframe></div></div>';

        // save the video id:
        var $form = data.context.$el.find('form');
        $.ajax({
          url: $form.attr('data-action-set-video-hashed-id'),
          method: 'post',
          dataType: 'json',
          data: {
            ajax: 1,
            tester_id: $form.attr('data-tester_id'),
            video_hashed_id: id
          }
        });

        // wait for the video to be processed:
        data.context.$progresstext.text('processing: 0%');
        data.context.$progressbar.css('width', 0);

        var url = statusUrl.replace(/#ID/, id);
        var pollingInterval = 1500;
        wait();

        function wait() {
          $.getJSON(url, function(json) {
            var progress = Math.floor(json.progress * 100);
            if (json.status == 'queued') {
              pollingInterval = 1500;
              data.context.$progresstext.text('processing: waiting in queue...');
            }
            else {
              pollingInterval = 750;
              data.context.$progresstext.text('processing: ' + progress + '%');
            }
            data.context.$progressbar.css('width', progress + '%');

            if (json.progress == 1) {
              setTimeout(function() {
                data.context.$el.addClass('has-video');
                data.context.$el.find('.embed-responsive-item').append(embed);
                data.context.$progressbar.css('width', 0);
                data.context.$progresstext.text('click to upload video');
                data.context.$el.find('.embed-responsive-item .fileinput-button').removeClass('uploading');
              }, 1000);
            }
            else {
              setTimeout(wait, pollingInterval);
            }
          });
        }
      }
    }).on('fileuploadprocessalways', function (e, data) {
      console.log(data);
    });
  }

  function showUploadProgress(e, data) {
    var progress = parseInt(data.loaded / data.total * 100, 10);
    data.context.$progresstext.text('uploading: ' + progress + '%');
    data.context.$progressbar.css('width', progress + '%');
  }

  function setupTesterDropdown($select) {
    // get already added testers to this project and remove them from all
    // available testers:
    var existingTesters = getExistingTesters();
    var testers = [];
    for (var i = 0; i < availableTesters.length; i++) {
      if (existingTesters.indexOf(availableTesters[i].id + '') == -1) {
        testers.push(availableTesters[i]);
      }
    }

    $select.select2({
      minimumResultsForSearch: 10,
      data: testers
    }).on('change', function(e) {
      addTester();
    });
  }

  function getExistingTesters() {
    var ids = [];
    $('.data-widget.added').each(function() {
      ids.push($(this).find('form').attr('data-tester_id'));
    });
    return ids;
  }

  function addTester() {
    var $el = $('.data-widget.empty'),
        $form = $el.find('form'),
        data = $el.find('[name="tester_id"]').select2('data');


    $.ajax({
      url: $form.attr('data-action-add-tester'),
      method: 'post',
      dataType: 'json',
      data: {
        ajax: 1,
        tester_id: data.id
      },
      success: function(json) {
        if (json.ok) {
          $el.find('.tester-name').text(data.text);
          $form.attr('data-tester_id', data.id);
          $el.removeClass('empty').addClass('added');
          
          setupVideoUpload($el);
        }
      }
    });
  }
})();

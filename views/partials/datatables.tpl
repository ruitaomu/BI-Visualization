<script type="text/javascript" src="{$BASE}/lib/datatables/media/js/jquery.dataTables.min.js"></script>
<script type="text/javascript" src="{$BASE}/lib/datatables_custom/datatables.js"></script>
<script type="text/javascript">
	$(function() {
		var $instances = $('table.x-datatables');

		// initialize:
		$instances.each(function() {
			var $el = $(this);
			var id = $el.attr('id');

			var cfg = $.extend(true, {
				'sDom': "<'row'<'col-lg-6'f><'col-lg-6'l>r>t<'row'<'col-lg-6'i><'col-lg-6'p>>",
				'sPaginationType': 'bootstrap',
				
				'oLanguage': {
					'sLengthMenu': "_MENU_ {'records'|i18n}",
					'sZeroRecords': "{'No data available'|i18n}",

					'sSearch': [
						'<a href="javascript:;" class="btn btn-danger">{"Delete Selected"|i18n}</a>',
						'<a href="{href action="create"}" class="btn btn-primary">{"Create"|i18n}</a>',
						'<div class="input-group"><span class="input-group-addon"><i class="fa fa-search"></i></span>_INPUT_</div>'
					].join(' ')
				},

				'aoColumnDefs': [
					{ 'aTargets': [0], 'bSortable': false }
				],

				// disable initial sorting:
				'aaSorting': [],

				// by default, don't save state:
				'bStateSave': false
			}, (id && typeof(dtcfg) != 'undefined' && dtcfg[id] ? dtcfg[id] : {}));

			// callback when the data table is initialized:
			var fnInitComplete = null;
			if (typeof(cfg['fnInitComplete']) == 'function') {
				fnInitComplete = cfg['fnInitComplete'];
				cfg['fnInitComplete'] = function(oSettings, json) {
					if (fnInitComplete) {
						fnInitComplete(oSettings, json);
					}
				};
			}

			// callback on every draw event:
			var fnDrawCallback = null;
			if (typeof(cfg['fnDrawCallback']) == 'function') {
				fnDrawCallback = cfg['fnDrawCallback'];
			}
			cfg['fnDrawCallback'] = function(oSettings) {
        $el.closest('.dataTables_wrapper').find('div.dataTables_filter input').addClass('form-control');
        $el.closest('.dataTables_wrapper').find('div.dataTables_length select').addClass('form-control');

				$el.find('input[type=checkbox]').prop('checked', false);

				if (fnDrawCallback) {
					fnDrawCallback(oSettings);
				}
			};

			if (cfg['bServerSide']) {
				$el.dataTable(cfg).fnSetFilteringDelay(450);
			}
			else {
				$el.dataTable(cfg);
			}
		});

		$instances.find('thead input[type=checkbox]').click(function(e) {
			var $el = $(this);
			$el.closest('table').find('tbody input[type=checkbox]').prop('checked', $el.prop('checked'));
		});
		$instances.on('click', 'input[type=checkbox]', function(e) {
			var $el = $(e.target);
			if (!$el.prop('checked')) {
				$el.closest('table').find('thead input[type=checkbox]').prop('checked', false);
			}
		});

		$instances.closest('form').find('.btn-danger').click(function(e) {
			if (confirm("{'Are you sure you want to delete selected records?'|i18n}")) {
				$(e.target).closest('form').submit();
				return true;
			}

			return false;
		});
	});
</script>

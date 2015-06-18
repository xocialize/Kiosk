$(function() {
	Simulate.init(); // Trigger Simulate functions
});

var Simulate = {

	loadOldMessages: function () {
		var $message_scrollbar = $('.message-scrollbar');
		$message_scrollbar.siblings('li.loading').show();
		setTimeout(function () {
			$message_scrollbar.find('a').not('.not-read').clone().appendTo($message_scrollbar.children('ul.message-list'));
			$message_scrollbar.perfectScrollbar('update');
			$message_scrollbar.siblings('li.loading').hide();
		}, 1000);
	},

	loadOldNotifications: function () {
		var $notification_scrollbar = $('.notification-scrollbar');
		$notification_scrollbar.siblings('li.loading').show();
		setTimeout(function () {
			$notification_scrollbar.find('a').not('.not-read').clone().appendTo($notification_scrollbar.children('ul.notification-list'));
			$notification_scrollbar.perfectScrollbar('update');
			$notification_scrollbar.siblings('li.loading').hide();
		}, 1000);
	},

	handleFakeUserStatus: function () {
		var randomChatList = function () {
			var rand = Math.round( Math.random() * (8000-500)) + 500;
			setTimeout(function () {
				rand%2==0 ? toOnlineUsers() : toOfflineUsers();
				randomChatList();
			}, rand);
		}
		randomChatList();

		var toOnlineUsers = function () {
			var clone = $('#offline-users li:nth-child(2)');
			clone.find('.status').addClass('online');
			clone.clone().prependTo('#online-users');
			clone.remove();
		}
		var toOfflineUsers = function () {
			var clone = $('#online-users li:nth-child(2)');
			clone.find('.status').removeClass('online');
			clone.clone().appendTo('#offline-users');
			clone.remove();
		}
	},

	loadThemeSwitcher: function () {
		var html = '<div class="theme-switcher">'+
			'<div class="switch-icon"><span>Theme Settings</span> <i class="fa fa-cog fa-spin open-switcher"></i><i class="fa fa-times close-switcher"></i></div>'+
			'<div class="switch-content">'+
				'<div class="checkbox">'+
					'<label><input type="checkbox" id="switcherRtl" value="">RTL Support</label>'+
				'</div><!--.checkbox-->'+
				'<div class="checkbox">'+
					'<label><input type="checkbox" id="switcherPanelAnimations" value="">Panel Animations</label>'+
				'</div><!--.checkbox-->'+
				'<div class="checkbox">'+
					'<label><input type="checkbox" id="switcherMenuAnimations" value="" checked="checked">Menu Animations</label>'+
				'</div><!--.checkbox-->'+
				'<div class="checkbox">'+
					'<label><input type="checkbox" id="switcherCollapsedMenu" value="">Collapsed Menu</label>'+
				'</div><!--.checkbox-->'+
				'<div class="checkbox">'+
					'<label><input type="checkbox" id="switcherScrollableMenu" value="" checked="checked">Scrollable Menu</label>'+
				'</div><!--.checkbox-->'+
				'<div class="checkbox">'+
					'<label><input type="checkbox" id="switcherAutoScrollMenu" value="">Auto Scroll Menu</label>'+
				'</div><!--.checkbox-->'+
				'<div class="checkbox">'+
					'<label><input type="checkbox" id="switcherStaticHeader" value="">Static Header</label>'+
				'</div><!--.checkbox-->'+
				'<div class="checkbox">'+
					'<label><input type="checkbox" id="switcherFixedBrandSidebar" value="">Fixed Brand &amp; Sidebar</label>'+
				'</div><!--.checkbox-->'+
				'<div class="checkbox">'+
					'<label><input type="checkbox" id="switcherFixedFooter" value="">Fixed Footer</label>'+
				'</div><!--.checkbox-->'+
				'<div class="checkbox">'+
					'<label><input type="checkbox" id="switcherBoxedLayout" value="">Boxed Layout</label>'+
				'</div><!--.checkbox-->'+
				'<div class="checkbox">'+
					'<label><input type="checkbox" id="switcherLightSidebar" value="">Light Sidebar</label>'+
				'</div><!--.checkbox-->'+
				'<div class="checkbox">'+
					'<label><input type="checkbox" id="switcherSidebarOverContent" value="">Sidebar Over Content</label>'+
				'</div><!--.checkbox-->'+
				'<legend>Colors</legend>'+
				'<ul class="colors">'+
					'<li><a href="javascript:;" class="active" data-theme="default.css"><span class="badge badge-peter-river">&nbsp;</span></a></li>'+
					'<li><a href="javascript:;" data-theme="amethyst.css"><span class="badge badge-amethyst">&nbsp;</span></a></li>'+
					'<li><a href="javascript:;" data-theme="emerald.css"><span class="badge badge-emerald">&nbsp;</span></a></li>'+
					'<li><a href="javascript:;" data-theme="pomegranate.css"><span class="badge badge-pomegranate">&nbsp;</span></a></li>'+
					'<li><a href="javascript:;" data-theme="pumpkin.css"><span class="badge badge-pumpkin">&nbsp;</span></a></li>'+
					'<li><a href="javascript:;" data-theme="sunflower.css"><span class="badge badge-sunflower">&nbsp;</span></a></li>'+
					'<li><a href="javascript:;" data-theme="clouds.css"><span class="badge badge-clouds">&nbsp;</span></a></li>'+
				'</ul>'+
			'</div>'+
		'</div>';
		$('body').append(html);

		Simulate.listenThemeSettings();
		Simulate.listenThemeColors();
	},

	listenThemeSettings: function () {
		$('.switch-icon').click( function () {
			$(this).parent().toggleClass('open');
		});

		$('.sidebar-moves-content-header, .sidebar-over-content').click(function() {
			$('.theme-switcher').toggle();
		});

		$('#switcherRtl').change( function () {
			Simulate.changeRtl($(this));
		});
		$('#switcherPanelAnimations').change( function () {
			Simulate.changePanelAnimations($(this));
		});
		$('#switcherMenuAnimations').change( function () {
			Simulate.changeMenuAnimations($(this));
		});
		$('#switcherCollapsedMenu').change( function () {
			Simulate.changeCollapsedMenu($(this));
		});
		$('#switcherScrollableMenu').change( function () {
			Simulate.changeScrollableMenu($(this));
		});
		$('#switcherAutoScrollMenu').change( function () {
			Simulate.changeAutoScrollMenu($(this));
		});
		$('#switcherStaticHeader').change( function () {
			Simulate.changeStaticHeader($(this));
		});
		$('#switcherFixedBrandSidebar').change( function () {
			Simulate.changeFixedBrandSidebar($(this));
		});
		$('#switcherFixedFooter').change( function () {
			Simulate.changeFooter($(this));
		});
		$('#switcherBoxedLayout').change( function () {
			Simulate.changeBoxedLayout($(this));
		});
		$('#switcherLightSidebar').change( function () {
			Simulate.changeLightSidebar($(this));
		});
		$('#switcherSidebarOverContent').change( function () {
			Simulate.changeSidebarOverContent($(this));
		});
	},

	changeRtl: function (object) {
		if( object.prop('checked') ) {
			Layout.settings.rtl = true;
		} else {
			Layout.settings.rtl = false;
		}
		Layout.handleRtlLayout();
	},
	changePanelAnimations: function (object) {
		if( object.prop('checked') ) {
			Layout.settings.animations = true;
		} else {
			Layout.settings.animations = false;
		}
		Layout.handleLayoutAnimation();
	},

	changeMenuAnimations: function (object) {
		if( object.prop('checked') ) {
			Layout.settings.sidebarMenuAnimation = true;
		} else {
			Layout.settings.sidebarMenuAnimation = false;
		}
	},

	changeCollapsedMenu: function (object) {
		if( object.prop('checked') ) {
			Layout.settings.sidebarMenuCollapsed = true;
		} else {
			Layout.settings.sidebarMenuCollapsed = false;
		}
		Layout.handleSidebarMenu();
	},

	changeScrollableMenu: function (object) {
		if( object.prop('checked') ) {
			Layout.settings.scrollableMenu = true;
		} else {
			Layout.settings.scrollableMenu = false;
		}
		Layout.handleScrollableMenu();
	},

	changeAutoScrollMenu: function (object) {
		if( object.prop('checked') ) {
			Layout.settings.autoScrollMenu = true;
		} else {
			Layout.settings.autoScrollMenu = false;
		}
	},

	changeStaticHeader: function (object) {
		if( object.prop('checked') ) {

			$('#switcherScrollableMenu').prop('checked', false);
			Simulate.changeScrollableMenu($('#switcherScrollableMenu'));

			Layout.settings.staticHeader = true;
			$('#switcherBoxedLayout').prop('disabled', true);
		} else {
			Layout.settings.staticHeader = false;
			$('#switcherBoxedLayout').prop('disabled', false);
		}
		Layout.handleStaticHeader();
	},

	changeFixedBrandSidebar: function (object) {
		if( object.prop('checked') ) {
			Layout.settings.fixedSidebarMenuAndBrand = true;
			$('#switcherStaticHeader, #switcherBoxedLayout').prop('disabled', true);
		} else {
			Layout.settings.fixedSidebarMenuAndBrand = false;
			$('#switcherStaticHeader, #switcherBoxedLayout').prop('disabled', false);
		}
		Layout.handleFixedSidebarMenuAndBrand();
	},

	changeFooter: function (object) {
		if( object.prop('checked') ) {
			Layout.settings.fixedFooter = true;
		} else {
			Layout.settings.fixedFooter = false;
		}
		Layout.handleFixedFooter();
	},

	changeBoxedLayout: function (object) {
		if( object.prop('checked') ) {

			$('#switcherScrollableMenu').prop('checked', false);
			Simulate.changeScrollableMenu($('#switcherScrollableMenu'));

			Layout.settings.boxedLayout = true;
			$('#switcherStaticHeader, #switcherFixedBrandSidebar, #switcherFixedFooter').prop('disabled', true);
		} else {
			Layout.settings.boxedLayout = false;
			$('#switcherStaticHeader, #switcherFixedBrandSidebar, #switcherFixedFooter').prop('disabled', false);
		}
		Layout.handleBoxedLayout();
	},

	changeLightSidebar: function (object) {
		if( object.prop('checked') ) {
			Layout.settings.sidebarLight = true;
		} else {
			Layout.settings.sidebarLight = false;
		}
		Layout.handleSidebarLight();
	},

	changeSidebarOverContent: function (object) {
		if( object.prop('checked') ) {
			Layout.settings.sidebarOverContent = true;
		} else {
			Layout.settings.sidebarOverContent = false;
		}
		Layout.handleSidebarOverContent();
	},

	listenThemeColors: function () {
		$('.colors a').click( function () {
			var theme = $(this).data('theme');
			$('.colors a').removeClass('active');
			$(this).addClass('active');
			$('head link#theme').attr('href', '../../assets/admin1/css/themes/'+theme);

			if( theme === 'clouds.css' ) {
				$('.logo-large').attr('src', '../../assets/admin1/img/logo-blue-large@2x.png');
				$('.logo-small').attr('src', '../../assets/admin1/img/logo-blue-small@2x.png');
			} else {
				$('.logo-large').attr('src', '../../assets/admin1/img/logo-white-large@2x.png');
				$('.logo-small').attr('src', '../../assets/admin1/img/logo-white-small@2x.png');
			}
		});
	},

	init: function () {
		this.handleFakeUserStatus();
		this.loadThemeSwitcher();
	}

}
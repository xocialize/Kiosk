var XOCIALIZE = XOCIALIZE || {};
XOCIALIZE.init = XOCIALIZE.init || {};
XOCIALIZE.userFunction = XOCIALIZE.userFunction || {};

XOCIALIZE.init.run = function(options){
	
	Pleasure.init();
	
	var settings = {
		
	  'scope'		:	null
	  
	};
	
	if ( options ) { 
		$.extend( settings, options );
	  }
	
	$.each(XOCIALIZE.init,function(v){
		
		if (typeof XOCIALIZE.init[v] == 'function') { 
		
			if( v != 'run' ) {
				XOCIALIZE.init[v](settings.scope);
				//console.log('RUNNING: '+v);
			}
			
		} else { console.log(v+' is not function'); }
		
	});
	
}

XOCIALIZE.init['pages'] = function(scope){
	
	console.log("running pages init:"+ currentPage);
	
	switch(currentPage){
		
		case "index":
		
			Index.init();
			
		break;
	
		case "devices":
		
			XOCIALIZE.initDevices();
		
		break;
		
		case "device":
		
			XOCIALIZE.initDevice();
		
		break;	
		
	}
}

XOCIALIZE.initDevices =  function(){
	
	var Selector = $('[data-device-settings]');
	
	$.each(Selector,function(e,v){
	
		$(this).on('click',function(event){
		
			event.preventDefault();
			
			var opts = {};
			
			opts.uri = $(this).attr('href');
			
			XOCIALIZE.getPage(opts);
			
		});	
	});
}

XOCIALIZE.initDevice =  function(){
	
	var Selector = $('[data-device-settings]');
	
	$.each(Selector,function(e,v){
	
		$(this).on('click',function(event){
		
			event.preventDefault();
			
			var opts = {};
			
			opts.uri = $(this).attr('href');
			
			XOCIALIZE.getPage(opts);
			
		});	
	});
}

XOCIALIZE.ajax = function(options){
	
	var settings = {
		
	  'params'		:	null,	
	  'callback'    :	null,	
	  'form'			:	null,
	  'method'		:   null,
	  'dataType'		:   'json',
	  'url'			:	'',
	  'js_token'		:	null,
	  'target'		: 	null,
	  'type'			:	"POST"
	  
	};
	
	if ( options ) { 
		$.extend( settings, options );
	  }
	  
	if (settings.form!=null) { if ( settings.params == null ) { settings.params=$('#'+settings.form).serialize(); } else { settings.params=settings.params+'&'+$('#'+settings.form).serialize(); } }
	  
	if (settings.method!=null) { if ( settings.params == null )  { settings.params='method='+settings.method; } else { settings.params=settings.params+'&method='+settings.method; } }
	
	if (settings.js_token!=null) { if ( settings.params == null )  { settings.params='js_token='+settings.token; } else { settings.params=settings.params+'&js_token='+settings.js_token; } } 
	
	$.ajax({
		
	  dataType: settings.dataType,
	  type: settings.type,
	  data: settings.params,
	  url: settings.url,
	  success: function (response) {
		  
		  console.log("ajax success");
		  
		  console.log(JSON.stringify(response));
		  
			if(typeof settings.callback == 'function'){ settings.callback.call(this,response); }
			
		},
	  error: function(){
		  
		   console.log("ajax error");
		  
			}
	});
	
}

XOCIALIZE.getPage = function(opts){
	
	var settings = {
		
	  'uri'			 :	'/',
	  'userCallback' : null,
	  'target'		 :   '#dynamic_content'
	
	};
	
	if ( opts ) { 
		$.extend( settings, opts );
	  }
	
	var params = 'REQUEST_URI='+settings.uri;
	
	XOCIALIZE.ajax({'url':settings.uri,'params':params,'method':'sub_request','callback':function(data){
		
		$(settings.target).empty().html(data.content);
		
		if(typeof data.page != "undefined"){ currentPage = data.page; }
		
		if(typeof (window.currentState) == 'undefined') { window.currentState=settings.uri; } else { currentState=settings.uri }
		
		console.log(currentState);
		
		history.pushState({ state:settings.uri }, data.title , settings.uri);
		
		XOCIALIZE.init.run({scope:'dynamic_content'});
		
		//MATERIAL.appInit(settings);
		
		if(typeof settings.userCallback == 'function'){ settings.userCallback.call(this,data); }
				
		
		
	}});
	
};

//stolen from http://snippets.dzone.com/posts/show/2099
XOCIALIZE.daysInMonth = function (iMonth, iYear)
{
    return 32 - new Date(iYear, iMonth, 32).getDate();
}



XOCIALIZE.getAge = function(bDay) {
    
    var dob = new Date(Date.parse(bDay));
    
    var ageis = dob.age(new Date());
    
    return ageis;
    
}

XOCIALIZE.timeAgo = function(date1, date2, granularity){
	
	var self = this;
	
	periods = [];
	periods['week'] = 604800;
	periods['day'] = 86400;
	periods['hour'] = 3600;
	periods['minute'] = 60;
	periods['second'] = 1;
	
	if(!granularity){
		granularity = 5;
	}
	
	(typeof(date1) == 'string') ? date1 = new Date(date1).getTime() / 1000 : date1 = new Date().getTime() / 1000;
	(typeof(date2) == 'string') ? date2 = new Date(date2).getTime() / 1000 : date2 = new Date().getTime() / 1000;
	
	if(date1 > date2){
		difference = date1 - date2;
	}else{
		difference = date2 - date1;
	}

	output = '';
	
	for(var period in periods){
		var value = periods[period];
		
		if(difference >= value){
			time = Math.floor(difference / value);
			difference %= value;
			
			output = output +  time + ' ';
			
			if(time > 1){
				output = output + period + 's ';
			}else{
				output = output + period + ' ';
			}
		}
		
		granularity--;
		if(granularity == 0){
			break;
		}	
	}
	
	return output + ' ago';
}

$.fn.clearForm = function(ezmode) {
  return this.each(function() {
 var type = this.type, tag = this.tagName.toLowerCase();
 if (tag == 'form')
   return $(':input',this).clearForm();
   
 if (type == 'hidden' && typeof (ezmode) != 'undefined' && ezmode=='1')
 	this.value = '';
 else if (type == 'text' || type == 'password' || tag == 'textarea')
   this.value = '';
 else if (type == 'checkbox' || type == 'radio')
   this.checked = false;
 else if (tag == 'select')
   this.selectedIndex = 0;
  });
};


$(function() {
	
	var location = window.history.location || window.location;
	
	$(window).on('popstate', function(e) {
	
		console.log(location.href);
		
		var href = location.href;
		
		var parts = href.split('#');  
		
		var State = parts[0];
		
		console.log(State);
		
		if( State != currentState  || typeof (window.currentState) == "undefined" ){
			
			if(typeof (window.currentState) == 'undefined') { window.currentState=State; } else { currentState=State; }
			
			var opts = {};
			
			opts.uri = currentState;
			
			XOCIALIZE.getPage(opts);
			
		}
	});
});
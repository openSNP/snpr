// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


$(document).ready(function() 
    { 
    
		$('#update_user').bind('ajaxSuccess', function(evt, request, settings) {
			$(this).append("whawheoawjdiuawhndkajuwndwkj");
		});
		$('#update_user').bind('ajaxFailure', function() {
			alert("nay");
		});

    $("#PaperMendeley").tablesorter({sortList: [[2,1]]}); 
		$("#PaperPlos").tablesorter({sortList: [[2,1]]});
		$("#snp_overview").tablesorter();
    } 
);

$(document).ready(function(){
$("body").bind("click", function (e) {
$('.dropdown-toggle, .menu').parent("li").removeClass("open");
});
$(".dropdown-toggle, .menu").click(function (e) {
var $li = $(this).parent("li").toggleClass('open');
return false;
});
});

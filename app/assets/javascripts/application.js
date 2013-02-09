//= require ./nested_form
//= require ./jquery-1.7.1.min
//= require ./jquery.tablesorter.min
//= require ./jquery.ba-hashchange.min
//= require ./jquery.easytabs
//= require ./jquery-ui-1.8.16.custom.min
//= require ./bootstrap-alert
//= require ./bootstrap-modal
//= require ./bootstrap-tooltip
//= require ./bootstrap-popover
//= require ./jquery.jqplot.min
//= require ./jqplot.pieRenderer.min
//= require ./jqplot.highlighter.min
//= require ./jqplot.dateAxisRenderer.min
//= require ./jqplot.cursor.min
//= require ./jqplot.barRenderer.min
//= require ./bootstrap-collapse
//= require_self


$(document).ready(function() { 
    $('#update_user').click(function() {
        $('#update_user').val("Updating...").addClass("disabled");
        setTimeout(function(){ $('#update_user').val("Update Information").removeClass("disabled");},1000);
    });

    $("#PaperMendeley").tablesorter({sortList: [[2,1]]}); 
    $("#PaperPlos").tablesorter({sortList: [[2,1]]});

    $('#remove_help_one').click(function() {
        if( $('#help_three').is(":hidden") && $('#help_two').is(":hidden") ){
            $("#help_block").hide("slow");
        }
        else {
            $('#help_one').hide('slow');
        }
    });$
    $('#remove_help_two').click(function() {
        if( $('#help_one').is(":hidden") && $('#help_three').is(":hidden") ){
            $("#help_block").hide("slow");
        }
        else {
            $('#help_two').hide('slow');
        }
    });
    $('#remove_help_three').click(function() {
        if( $('#help_one').is(":hidden") && $('#help_two').is(":hidden") ){
            $("#help_block").hide("slow");
        }
        else {
            $('#help_three').hide('slow');
        };
    });

    $('#tab-container').easytabs();
    $("body").bind("click", function (e) {
    $('.dropdown-toggle, .menu').parent("li").removeClass("open");
    });
    $(".dropdown-toggle, .menu").click(function (e) {
    var $li = $(this).parent("li").toggleClass('open');
    return false;
    });
});

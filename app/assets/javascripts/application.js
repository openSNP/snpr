//= require jquery
//= require jquery_ujs
//= require jquery.ui.all
//= require ./dalliance-compiled.js
//= require ./jquery.jqplot.min
//= require ./jqplot.barRenderer.min.js
//= require ./jqplot.cursor.min.js
//= require ./jqplot.dateAxisRenderer.min.js
//= require ./jqplot.highlighter.min.js
//= require ./jqplot.pieRenderer.min.js
//= require ./jquery.easytabs
//= require jquery_nested_form
//= require bootstrap.min
//= require_self
// = require_tree .

$(document).ready(function() {
    $('#update_user').click(function() {
        $('#update_user').val("Updating...").addClass("disabled");
        setTimeout(function(){ $('#update_user').val("Update Information").removeClass("disabled");},1000);
    });

    //$("#PaperMendeley").tablesorter({sortList: [[2,1]]});
    //$("#PaperPlos").tablesorter({sortList: [[2,1]]});

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

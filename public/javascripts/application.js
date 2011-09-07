// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function() 
    { 
        $("#PaperMendeley").tablesorter({sortList: [[2,1]]}); 
	$("#PaperPlos").tablesorter({sortList: [[2,1]]});
	$("#snp_overview").tablesorter();
	
    } 
);


function AddCommentId(ItemId)
{
document.Form.new_comment.snp_comment[comment_text].value = document.Form.new_comment.snp_comment[comment_text].value + '@#' + ItemId+':';
} 

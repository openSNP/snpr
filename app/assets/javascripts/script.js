(function(window, document) {
  'use strict';
  $(document).ready(function() {

    var $searchButton = $('[data-js="search-button"]');
    var $searchForm = $('[data-js="search-form"]');
    var $panelHeader = $('[data-js="panel-header"]');
    var $extendButton = $('[data-js="extend-button"]');
    var $pictureReplyButton = $('[data-js="picture-reply-button"]');
    var $snpReplyButton = $('[data-js="snp-reply-button"]');

    $('[data-toggle="tooltip"]').tooltip();

    function sendCommentId(e, text) {
      e.value = text + e.value
    }

    $searchButton.on('click', function (event) {
      event.preventDefault();
      if ($searchForm.hasClass('showed')) {
        $searchForm.animate({top: '0'});
      } else {
        $searchForm.animate({top: '50px'});
      }
      $searchForm.toggleClass('showed');
    });

    $panelHeader.on('click', function (event) {
      event.preventDefault();
      if ($(this).siblings('.test-faq__title-extend').text() === '+') {
        $(this).siblings('.test-faq__title-extend').text('-');
      } else if ($(this).siblings('.test-faq__title-extend').text() === '-') {
        $(this).siblings('.test-faq__title-extend').text('+');
      }
    });

    $extendButton.on('click', function (event) {
      event.preventDefault();
      if ($(this).text() === '+') {
        $(this).text('-');
      } else if ($(this).text() === '-') {
        $(this).text('+');
      }
    });

    $pictureReplyButton.on('click', function (event) {
      event.preventDefault();
      sendCommentId(document.new_comment.picture_phenotype_comment_comment_text, '@#' + this.id);
      return false;
    });

    $snpReplyButton.on('click', function (event) {
      event.preventDefault();
      sendCommentId(document.new_comment.snp_comment_comment_text, '@#' + this.id);
      return false;
    });

  });

})(window, document);

(function(window, document) {
  'use strict';
  $(document).ready(function() {

    var snpApp = function () {
      var $searchButton = $('[data-js="search-button"]');
      var $searchForm = $('[data-js="search-form"]');
      var $panelHeader = $('[data-js="panel-header"]');
      var $extendButton = $('[data-js="extend-button"]');
      var $pictureReplyButton = $('[data-js="picture-reply-button"]');
      var $snpReplyButton = $('[data-js="snp-reply-button"]');

      var init = function  () {
        $('[data-toggle="tooltip"]').tooltip();
        initEvent();
      };

      var initEvent = function () {
        $searchButton.on('click', searchButtonCallback);
        $panelHeader.on('click', panelHeaderCallback);
        $extendButton.on('click', extendButtonCallback);
        $pictureReplyButton.on('click', pictureReplyButtonCallback);

        $snpReplyButton.on('click', snpReplyButtonCallback);
      };

      var sendCommentId = function (e, text) {
        e.value = text + e.value;
      };

      var searchButtonCallback = function (event) {
        event.preventDefault();
        if ($searchForm.hasClass('showed')) {
          $searchForm.animate({top: '0'});
        } else {
          $searchForm.animate({top: '50px'});
        }
        $searchForm.toggleClass('showed');
      };

      var panelHeaderCallback = function (event) {
        event.preventDefault();
        if ($(this).siblings('.faq__title-extend').text() === '+') {
          $(this).siblings('.faq__title-extend').text('-');
        } else if ($(this).siblings('.faq__title-extend').text() === '-') {
          $(this).siblings('.faq__title-extend').text('+');
        }
      };

      var extendButtonCallback = function (event) {
        event.preventDefault();
        if ($(this).text() === '+') {
          $(this).text('-');
        } else if ($(this).text() === '-') {
          $(this).text('+');
        }
      };

      var pictureReplyButtonCallback = function (event) {
        event.preventDefault();
        sendCommentId(document.new_comment.picture_phenotype_comment_comment_text, '@#' + this.id);
        return false;
      };

      var snpReplyButtonCallback = function (event) {
        event.preventDefault();
        sendCommentId(document.new_comment.snp_comment_comment_text, '@#' + this.id);
        return false;
      };

      return {
        init: init
      };

    };

    snpApp().init();
  });
})(window, document);

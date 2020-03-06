$(function() {

  var commentForm = null;

  function init() {
    commentForm = $('#commentForm').detach().removeAttr('id');
    $('.addCommentLink').click(addCommentForm);
    $('.deleteCommentLink').click(deleteComment);
    $('body').on('click', '.commentSaveButton', saveComment);
    $('body').on('click', '.commentCancelButton', hideCommentForm);
  }

  function addCommentForm() {
    // clone the form and populate some fields
    var c = commentForm.clone(true);
    c.find('input[name="objectType"]').val($(this).data('objectType'));
    c.find('input[name="objectId"]').val($(this).data('objectId'));

    // show it beneath the answer actions
    var anchor = $(this).closest('div');
    c.insertAfter(anchor);
    c.find('textarea').focus();

    // hide the link
    $(this).hide();

    return false;
  }

  function hideCommentForm() {
    var f = $(this).closest('form');

    // put the "add comment" link back in the previous div
    f.prev('div').find('.addCommentLink').show();

    // remove the form
    f.remove();

    return false;
  }

  function saveComment() {
    $('body').addClass('waiting');

    var form = $(this).closest('form');
    $.post(
      URL_PREFIX + 'ajax/save-comment',
      form.serialize()
    ).done(function(successMsg, textStatus, xhr) {

      window.location.reload();

    }).fail(function(errorMsg) {

      if (errorMsg.responseJSON) {
        alert(errorMsg.responseJSON);
      }

    }).always(function() {

      $('body').removeClass('waiting');

    });

    return false;
  }

  function deleteComment() {
    var msg = $(this).data('confirmMsg');
    if (!confirm(msg)) {
      return false;
    }

    $('body').addClass('waiting');

    var comment = $(this).closest('.comment');
    var commentId = $(this).data('commentId');
    $.get(URL_PREFIX + 'ajax/delete-comment/' + commentId)
      .done(function(successMsg) {

        comment.slideToggle();

      }).fail(function(errorMsg) {

        if (errorMsg.responseJSON) {
          alert(errorMsg.responseJSON);
        }

      }).always(function() {

        $('body').removeClass('waiting');

      });

    return false;
  }

  init();

});

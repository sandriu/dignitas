<?php

$id = Request::get('id');
$answerId = Request::get('answerId'); // answer to be highlighted
$deleteAnswerId = Request::get('deleteAnswerId');

$statement = Statement::get_by_id($id);
if (!$statement) {
  FlashMessage::add(_('The statement you are looking for does not exist.'));
  Util::redirectToHome();
}

if (!$statement->isViewable()) {
  FlashMessage::add(_('This statement was deleted and is only visible to privileged users.'));
  Util::redirectToHome();
}

if ($deleteAnswerId) {
  $answer = Answer::get_by_id($deleteAnswerId);
  if (!$answer) {
    FlashMessage::add(_('No such answer exists.'));
  } else if ($answer->statementId != $statement->id) {
    FlashMessage::add(_('The answer does not belong to this statement.'));
  } else if (!$answer->isDeletable()) {
    FlashMessage::add(_('You cannot delete this answer.'));
  } else {
    $answer->markDeleted(Ct::REASON_BY_USER);
    FlashMessage::add(_('Answer deleted.'), 'success');
  }

  Util::redirect(Router::link('statement/view') . '/' . $answer->statementId);
}

if ($statement->hasPendingEdit() && User::may(User::PRIV_REVIEW)) {
  Smart::assign([
    'pendingEditReview' => Review::getForObject($statement, Ct::REASON_PENDING_EDIT),
  ]);
}

Smart::addResources('flag', 'imageModal', 'simplemde');
Smart::assign([
  'answerId' => $answerId,
  'answers' => $statement->getAnswers(),
  'newAnswer' => Answer::create($statement->id),
  'referrer' => Router::link('statement/view', true) . '/' . $statement->id,
  'statement' => $statement,
]);
Smart::display('statement/view.tpl');

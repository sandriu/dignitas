<?php

$id = Request::get('id');

$entity = Entity::get_by_id($id);
if (!$entity) {
  FlashMessage::add(_('The entity you are looking for does not exist.'));
  Util::redirectToHome();
}

if ($entity->hasPendingEdit() && User::may(User::PRIV_REVIEW)) {
  Smart::assign([
    'pendingEditReview' => Review::getForObject($entity, Ct::REASON_PENDING_EDIT),
  ]);
}

Smart::assign([
  'entity' => $entity,
  'statements' => $entity->getStatements(),
]);
Smart::addResources('flag');
Smart::display('entity/view.tpl');

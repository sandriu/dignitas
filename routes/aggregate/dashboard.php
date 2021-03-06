<?php

if (!User::getActive()) {
  Util::redirectToLogin(); // just ensure user is logged in
}

if (User::may(User::PRIV_REVIEW) && !Ban::exists(Ban::TYPE_REVIEW)) {
  // get reasons of reviews that are
  // (a) pending,
  // (b) not signed off by the current user and
  // (c) visible to the current user
  $reasons = Model::factory('Review')
    ->table_alias('r')
    ->select('r.reason')
    ->distinct()
    ->raw_join(
      'left join review_log',
      'r.id = rl.reviewId and rl.userId = ?',
      'rl',
      [User::getActiveId()])
    ->where('r.status', Review::STATUS_PENDING)
    ->where_null('rl.id');
  if (!User::isModerator()) {
    $reasons = $reasons->where('moderator', false);
  }
  $reasons = $reasons
    ->order_by_asc('reason')
    ->find_many();

  $reasons = Util::objectProperty($reasons, 'reason');
  Smart::assign('activeReviewReasons', $reasons);
}

$statementsBadVerdicts = Statement::getStatementsWithBadVerdicts();

Smart::assign([
  'numBadVerdicts' => $statementsBadVerdicts['count'],
]);

Smart::display('aggregate/dashboard.tpl');

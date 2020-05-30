<?php

class User extends Proto {
  use MarkdownTrait, UploadTrait;

  // privileges and their required reputation
  const PRIV_ADD_ENTITY = -100;
  const PRIV_EDIT_ENTITY = 2000;
  const PRIV_DELETE_ENTITY = 10000;

  const PRIV_ADD_STATEMENT = -100;
  const PRIV_EDIT_STATEMENT = 2000;
  const PRIV_DELETE_STATEMENT = 10000;

  const PRIV_ADD_ANSWER = -100;
  const PRIV_EDIT_ANSWER = 2000;
  const PRIV_DELETE_ANSWER = 10000;

  const PRIV_UPVOTE_STATEMENT = 15;
  const PRIV_DOWNVOTE_STATEMENT = 125;
  const PRIV_UPVOTE_ANSWER = 15;
  const PRIV_DOWNVOTE_ANSWER = 125;
  const PRIV_UPVOTE_COMMENT = 15;
  const PRIV_DOWNVOTE_COMMENT = 125;

  const PRIV_FLAG = 15;

  const PRIV_COMMENT = 50;

  const PRIV_ADD_TAG = 1500;
  const PRIV_EDIT_TAG = 1500;
  const PRIV_DELETE_TAG = 5000;

  const PRIV_UPLOAD_ATTACHMENT = 100;

  // PRIV_REVIEW is assumed to be greater than or equal to PRIV_EDIT_*.
  // If that ever changes, then review/view.php should disable the edit button
  // accordingly.
  const PRIV_REVIEW = 2000;

  // flag earning
  const BASE_FLAGS_PER_DAY = 10;
  const REPUTATION_FOR_NEW_FLAG = 2000;
  const MAX_FLAGS_PER_DAY = 100;

  // action log
  const ACTION_LOG_PAGE_SIZE = 20;

  private static $active = null; // user currently logged in

  function getMarkdownFields() {
    return [ 'aboutMe' ];
  }

  function getObjectType() {
    return self::TYPE_USER;
  }

  private function getFileSubdirectory() {
    return 'user';
  }

  private function getFileRoute() {
    return 'user/image';
  }

  static function getActive() {
    return self::$active;
  }

  static function getActiveId() {
    return self::$active ? self::$active->id : 0;
  }

  static function setActive($userId) {
    UserExt::setField($userId, 'lastSeen', time());
    self::$active = self::get_by_id($userId);
  }

  function getLastSeen() {
    return UserExt::getField($this->id, 'lastSeen');
  }

  function getReputation() {
    return UserExt::getField($this->id, 'reputation', 1);
  }

  function setReputation($rep) {
    UserExt::setField($this->id, 'reputation', $rep);
  }

  function grantReputation($delta) {
    $this->setReputation($this->getReputation() + $delta);
  }

  function getNumPendingEdits() {
    return UserExt::getField($this->id, 'numPendingEdits');
  }

  function incrementPendingEdits() {
    $this->changeNumPendingEdits(1);
  }

  function decrementPendingEdits() {
    $this->changeNumPendingEdits(-1);
  }

  private function changeNumPendingEdits(int $delta) {
    $value = $this->getNumPendingEdits() + $delta;
    UserExt::setField($this->id, 'numPendingEdits', $value);
  }

  static function getFlagsPerDay() {
    if (!self::$active) {
      return 0;
    }

    $r = self::$active->getReputation();
    $earned = (int)($r / self::REPUTATION_FOR_NEW_FLAG);
    return min(self::BASE_FLAGS_PER_DAY + $earned,
               self::MAX_FLAGS_PER_DAY);
  }

  static function getRemainingFlags() {
    $pending = Model::factory('Flag')
      ->table_alias('f')
      ->join('review', ['f.reviewId', '=', 'r.id'], 'r')
      ->where('f.userId', self::getActiveId())
      ->where('r.status', Review::STATUS_PENDING)
      ->where_gte('f.createDate', Ct::ONE_DAY_IN_SECONDS)
      ->count();

    return self::getFlagsPerDay() - $pending;
  }

  function getNumActionPages() {
    $numActions = Model::factory('Action')
      ->where('userId', $this->id)
      ->count();
    return ceil($numActions / self::ACTION_LOG_PAGE_SIZE);
  }

  /**
   * @param int $page 1-based page to load
   */
  function getActionPage(int $page) {
    return Model::factory('Action')
      ->where('userId', $this->id)
      ->order_by_desc('createDate')
      ->offset(($page - 1) * self::ACTION_LOG_PAGE_SIZE)
      ->limit(self::ACTION_LOG_PAGE_SIZE)
      ->find_many();
  }

  // Checks if the user can claim this email when registering or editing their profile.
  // Returns null on success or an error message on failure. Assumes $email is not empty.
  static function canChooseEmail($email) {
    if (!$email) {
      return _('info-must-enter-email');
    }

    $u = self::get_by_email($email);
    if ($u && $u->id != self::getActiveId()) {
      return _('info-email-taken');
    }

    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
      return _('info-incorrect-email');
    }

    return null;
  }

  // returns null on success or an error message on failure
  static function validateNickname($nickname) {
    if (!preg_match('/^(\p{L}|\d)(\p{L}|\d|[-_.]){2,29}$/u', $nickname)) {
      return _('info-nickname-syntax');
    }
    return null;
  }

  // returns null on success or an error message on failure
  static function validateNewPassword($password, $password2) {
    if (!$password) {
      return _('info-must-enter-password');
    } else if (!$password2) {
      return _('info-must-enter-password-2');
    } else if ($password != $password2) {
      return _('info-password-mismatch');
    } else if (strlen($password) < 8) {
      return _('info-password-length');
    } else {
      return null;
    }
  }

  // checks whether the active user has the privilege
  static function may($privilege) {
    $u = self::$active;
    return $u && (($u->getReputation() >= $privilege) || $u->moderator);
  }

  static function isModerator() {
    $u = self::$active;
    return $u && $u->moderator;
  }

  // checks whether the active user has the privilege and bounces them if not
  static function enforce($privilege) {
    // redirect to log in page if there is no active user
    if (!self::$active) {
      Util::redirectToLogin();
    } else if (!self::may($privilege)) {
      FlashMessage::add(sprintf(
        _('info-minimum-reputation-%s'),
        Str::formatNumber($privilege)));
      Util::redirectToHome();
    }
  }

  /**
   * Checks if the active user is a moderator and bounces them if not.
   */
  static function enforceModerator() {
    // redirect to log in page if there is no active user
    if (!self::$active) {
      Util::redirectToLogin();
    } else if (!self::isModerator()) {
      FlashMessage::add(_('info-moderator-only'));
      Util::redirectToHome();
    }
  }

  /**
   * Checks if the active user may flag the given object.
   *
   * @param Flaggable $obj A flaggable object
   * @param boolean $throw Whether to also throw an exception with a detailed message
   * @return boolean Returns true iff the user should be allowed to flag
   * @throws Exception If the user should not be allowed to flag and $throw = true
   */
  static function canFlag($obj, $throw = false) {
    try {
      // check the user's reputation
      if (!self::may(self::PRIV_FLAG)) {
        throw new Exception(
          sprintf(_('info-minimum-reputation-flag-%s'),
                  Str::formatNumber(self::PRIV_FLAG)));
      }

      // check the user's remaining flags
      if (self::getRemainingFlags() <= 0) {
        $fpd = self::getFlagsPerDay();
        throw new Exception(
          sprintf(ngettext('info-flag-limit-singular',
                           'info-flag-limit-plural-%d',
                           $fpd), $fpd));
      }

      // check that the object exists
      if (!$obj) {
        throw new Exception(_('info-flag-no-object'));
      }

      // check that the user does not already have a pending flag
      if ($obj->isFlagged()) {
        throw new Exception(_('info-already-flagged'));
      }

      return true;
    } catch (Exception $e) {

      if ($throw) {
        throw $e;
      }

      return false;
    }
  }

  /**
   * Checks if the active user may comment on the given object.
   *
   * @param object $obj A statement or answer
   * @param boolean $throw Whether to also throw an exception with a detailed message
   * @return boolean Returns true iff the user should be allowed to comment
   * @throws Exception If the user should not be allowed to comment and $throw = true
   */
  static function canComment($obj, $throw = false) {
    try {
      $userId = self::getActiveId();

      // owner
      if ($obj instanceof Statement) {
        if ($obj->userId == $userId) {
          return true;
        }
      } else if ($obj instanceof Answer) {
        if ($obj->getStatement()->userId == $userId) {
          return true;
        }
      } else {
        throw new Exception('You cannot comment on items of this type.');
      }

      // sufficient reputation to comment everywhere
      if (self::may(self::PRIV_COMMENT)) {
        return true;
      } else {
        throw new Exception(
          sprintf(_('info-minimum-reputation-comment-%s'),
                  Str::formatNumber(self::PRIV_COMMENT)));
      }
    } catch (Exception $e) {

      if ($throw) {
        throw $e;
      }

      return false;
    }
  }

  function __toString() {
    return $this->nickname;
  }

}

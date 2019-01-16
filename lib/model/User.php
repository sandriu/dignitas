<?php

class User extends BaseObject implements DatedObject {

  private static $active = null; // user currently logged in

  static function getActive() {
    return self::$active;
  }

  static function getActiveId() {
    return self::$active ? self::$active->id : 0;
  }

  static function setActive($userId) {
    self::$active = User::get_by_id($userId);
  }

  // Checks if the user can claim this email when registering or editing their profile.
  // Returns null on success or an error message on failure. Assumes $email is not empty.
  static function canChooseEmail($email) {
    if (!$email) {
      return _('Please enter an email address.');
    }

    $u = User::get_by_email($email);
    if ($u && $u->id != self::getActiveId()) {
      return _('This email address is already taken.');
    }

    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
      return _('This email address looks incorrect.');
    }

    return null;
  }

  // returns null on success or an error message on failure
  static function validateNewPassword($password, $password2) {
    if (!$password) {
      return _('Please enter a password.');
    } else if (!$password2) {
      return _('Please enter your password twice to prevent typos.');
    } else if ($password != $password2) {
      return _("Passwords don't match.");
    } else if (strlen($password) < 8) {
      return _('Your password must be at least 8 characters long.');
    } else {
      return null;
    }
  }

  public function __toString() {
    return $this->email;
  }

}

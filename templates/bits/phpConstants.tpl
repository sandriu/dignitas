{* expose some PHP constants *}
<script>
  const SELECT2_LOCALE = '{LocaleUtil::getSelect2Locale()}';
  const DATEPICKER_LOCALE = '{LocaleUtil::getDatePickerLocale()}';
  const DATEPICKER_FORMAT = '{LocaleUtil::getDatePickerFormat()}';
  const URL_PREFIX = '{Config::URL_PREFIX}';
  const UPLOAD_MIME_TYPES = JSON.parse('{Util::getUploadMimeTypes()|json_encode}');

  // used in the flagging modal
  const TYPE_ENTITY = {Proto::TYPE_ENTITY};

  // used in the vote confirmation alerts
  const TYPE_COMMENT = {Proto::TYPE_COMMENT};

  // used in confirmation and alert modals
  const ALERT_OK_TEXT = '{t}link-ok{/t}';
  const CONFIRM_CANCEL_TEXT = '{t}link-cancel{/t}';
  const CONFIRM_OK_TEXT = '{t}link-confirm{/t}';
</script>

<?php

$path = Request::get('path');

if ($path) {
  $cat = HelpCategory::get_by_path($path);
  if ($cat) {
    Smart::assign('category', $cat);
    Smart::display('help/categoryView.tpl');
  } else {
    $page = HelpPage::get_by_path($path);
    if ($page) {
      Smart::assign([
        'page' => $page,
        'category' => $page->getCategory(),
      ]);
      Smart::display('help/pageView.tpl');
    } else {
      Snackbar::add(_('info-no-such-help-item'));
      Smart::assign('categories', HelpCategory::loadAll());
      Smart::display('help/index.tpl');
    }
  }
} else {
  Smart::assign('categories', HelpCategory::loadAll());
  Smart::display('help/index.tpl');
}

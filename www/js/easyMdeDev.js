delete module; // unset module.exports set by the EasyMDE lib

$(function() {
  /**
   * Customize EasyMDE's toolbar in order to replace icon CSS classes and get
   * rid of the external dependency on Font Awesome.
   **/
  const EASY_MDE_TOOLBAR = [
    {
      name: 'bold',
      action: EasyMDE.toggleBold,
      icon: '<i class="material-icons">format_bold</i>',
      title: 'Bold',
    }, {
      name: 'italic',
      action: EasyMDE.toggleItalic,
      icon: '<i class="material-icons">format_italic</i>',
      title: 'Italic',
    }, {
      name: 'heading',
      action: EasyMDE.toggleHeadingSmaller,
      icon: '<i class="material-icons">format_size</i>',
      title: 'Heading',
    }, '|', {
      name: 'quote',
      action: EasyMDE.toggleBlockquote,
      icon: '<i class="material-icons">format_quote</i>',
      title: 'Quote',
    }, {
      name: 'unordered-list',
      action: EasyMDE.toggleUnorderedList,
      icon: '<i class="material-icons">format_list_bulleted</i>',
      title: 'Generic List',
    }, {
      name: 'ordered-list',
      action: EasyMDE.toggleOrderedList,
      icon: '<i class="material-icons">format_list_numbered</i>',
      title: 'Numbered List',
    }, '|', {
      name: 'link',
      action: EasyMDE.drawLink,
      icon: '<i class="material-icons">insert_link</i>',
      title: 'Create Link',
    }, {
      name: 'image',
      action: EasyMDE.drawImage,
      icon: '<i class="material-icons">insert_photo</i>',
      title: 'Insert Image',
    }, '|', {
      name: 'preview',
      action: EasyMDE.togglePreview,
      icon: '<i class="material-icons">visibility</i>',
      className: 'no-disable',
      title: 'Toggle Preview',
    }, {
      name: 'side-by-side',
      action: EasyMDE.toggleSideBySide,
      icon: '<i class="material-icons">view_column</i>',
      className: 'no-disable no-mobile',
      title: 'Toggle Side by Side',
    }, {
      name: 'fullscreen',
      action: EasyMDE.toggleFullScreen,
      icon: '<i class="material-icons">open_in_full</i>',
      className: 'no-disable no-mobile',
      title: 'Toggle Fullscreen',
    }, {
      name: 'answer-resources-link',
      action: null,
      icon: '<i class="material-icons">lightbulb</i>',
      className: 'answer-resources-link float-right d-none',
      title: 'Show answer resources',
    },
  ];

  var cachedMentions = null;

  // initialize EasyMDE editors
  $('.easy-mde').each(function() {
    var easyMde = new EasyMDE({
      autoDownloadFontAwesome: false,
      element: this,
      forceSync: true, // so that the remaining chars value gets updated
      inputStyle: 'contenteditable', // needed for nativeSpellchecker to work
      insertTexts: {
        link: ["[", "]()"], // insert []() for links, not [](http://)
      },
      previewRender: customPreview,
      spellChecker: false, // disable in favor of nativeSpellchecker
      status: false,
      toolbar: EASY_MDE_TOOLBAR,
    });

    var cm = easyMde.codemirror;
    cm.on('beforeChange', checkMaxLength);
    cm.on('change', function() {
      // fire the change event which in turn updates the chars remaining info
      $(cm.getTextArea()).change();
    });
    cm.on('change', unsavedChangesHandler);
    if ($(this).data('statementId')) {
      // only register the @-listener when @-mentions are useful
      cm.on('keyup', showHint);
    }

    // allow drag-and-drop file uploads, see
    // https://github.com/sparksuite/simplemde-markdown-editor/issues/328
    inlineAttachment.editors.codemirror4.attach(cm, {
      allowedTypes: UPLOAD_MIME_TYPES,
      onFileUploadError: inlineAttachmentError,
      onFileUploadResponse: inlineAttachmentSuccess,
      uploadUrl: URL_PREFIX + 'ajax/upload-attachment',
    });
  });

  function checkMaxLength(cm, change) {
    var max = $(cm.getTextArea()).prop('maxlength');
    if (max > 0) {
      var len = cm.getValue().length;

      if (change.origin == '+input') {
        len++;
      } else if (change.origin == 'paste') {
        // This omits the case where we paste over a selection and we should
        // subtract the cost of the said selection. This is hard to track,
        // though, and seems like a corner case.
        len += change.text.join('\n').length;
      }

      if (len > max) {
        change.cancel();
      }
    }
  }

  function inlineAttachmentError(xhr) {
    var jsonResponse;

    try {
      jsonResponse = JSON.parse(xhr.responseText);
      error = jsonResponse.error;
    } catch (e) {
      error = 'An error occurred while uploading the file. Possibly the file was too large.';
    }

    var text = this.editor.getValue().replace(this.lastValue, error);

    this.editor.setValue(text);
    return false;
  }

  function inlineAttachmentSuccess(xhr) {
    var result = JSON.parse(xhr.responseText);

    if (result) {
      // ditch the built-in urlText and compute the output value ourselves
      var text = this.editor.getValue().replace(this.lastValue, result.html);
      this.editor.setValue(text);

      // Also move the cursor to the end of the inserted block. Otherwise it
      // would sit at the end of the text "![Uploading file...]()", whereas
      // our HTML is longer.
      var cm = this.editor.codeMirror;
      var delta = result.html.length - this.lastValue.length;
      // skip delta characters ahead
      cm.doc.setCursor(cm.findPosH(cm.doc.getCursor(), delta, 'char'));
    }
    return false;
  }

  function showHint(cm, event) {
    if (event.key == '@') {
      cm.showHint({
        alignWithWord: true,
        completeSingle: false,
        hint: getMentions,
      });
    }
  }

  function getMentionsFromCache(cm) {
    if (cachedMentions == null) {
      var statementId = $(cm.getTextArea()).data('statementId');
      $.ajax(URL_PREFIX + 'ajax/get-mentions', {
        async: false,
        data: { statementId: statementId },
      }).done(function(results) {
        cachedMentions = results;
      });
    }
    // leave cachedMentions null on failures so we keep trying to fetch them
    return cachedMentions ?? [];
  }

  function getMentions(cm) {
    return new Promise(function(accept) {
      setTimeout(function() {
        var c = cm.getCursor();

        // get the text from after the previous @ to the cursor
        var line = cm.getLine(c.line).substring(0, c.ch);
        var last = 1 + line.lastIndexOf('@'); // if no previous @, start at the beginning
        var word = line.substr(last);

        var names = getMentionsFromCache(cm);
        var results = [];
        for (var i = 0; i < names.length; i++) {
          if (names[i].startsWith(word)) {
            results.push(names[i]);
          }
        }
        return accept({
          list: results,
          from: { line: c.line, ch: last }, // replace text after the @
          to: c,                            // up to the cursor
        });
      }, 200);
    });
  }

  // Adds URL_PREFIX to relative URLs. See also addUrlPrefix() in lib/Markdown.php.
  function customPreview(text) {
    text = text.replace(
      /(href|src)=\"([^\"]+)\"/g,

      function(match, p1, p2) {
        if (isRelativeUrl(p2)) {
          p2 = URL_PREFIX + p2;
        }
        return p1 + '="' + p2 + '"';
      }

    );

    return this.parent.markdown(text);
  }

  // See also isRelativeUrl() in lib/Str.php.
  function isRelativeUrl(url) {
    return !url.startsWith('#') &&
      !url.startsWith('http://') &&
      !url.startsWith('https://');
  }

});

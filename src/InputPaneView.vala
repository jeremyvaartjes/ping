class InputPaneView {
    Gtk.Box inputBox;
    Gtk.Box generalBox;
    Gtk.Box dataBox;
    Gtk.Box inputHeaderBox;
    Gtk.Entry urlEntry;
    Gtk.TreeView inputHeaderView;
    Gtk.TreeView urlencodeView;
    Gtk.TreeView multipartView;
    public Gtk.SourceView dataEntry;
    Gtk.ComboBox requestTypePicker;
    Gtk.ComboBox contentTypePicker;
    Gtk.CellRendererText inputHeaderListCell;
    Gtk.CellRendererText inputHeaderValueListCell;
    Gtk.CellRendererText urlencodeCell;
    Gtk.CellRendererText urlencodeValueCell;
    Gtk.CellRendererText multipartCell;
    Gtk.CellRendererText multipartValueCell;
    Gtk.CellRendererPixbuf multipartTypeCell;
    Gtk.Button newInputHeaderButton;
    Gtk.Button deleteInputHeaderButton;
    Gtk.ActionBar inputHeaderActions;
    Gtk.Button newUrlencodeButton;
    Gtk.Button deleteUrlencodeButton;
    Gtk.ActionBar urlencodeActions;
    Gtk.Button newMultipartButton;
    Gtk.Button deleteMultipartButton;
    Gtk.Button newMultipartFileButton;
    Gtk.ActionBar multipartActions;
    Gtk.Label urlLabel;
    Gtk.Label methodLabel;
    Gtk.Label contentLabel;
    Gtk.ScrolledWindow dataScrolled;
    Gtk.ScrolledWindow inputHeaderScrolled;
    Gtk.ScrolledWindow urlencodeScrolled;
    Gtk.ScrolledWindow multipartScrolled;
    Gtk.ListStore input_header_list_store;
    Gtk.ListStore urlencode_list_store;
    Gtk.ListStore multipart_list_store;
    Gtk.SourceBuffer dataBuffer;
    Gtk.ListStore requestTypes;
    Gtk.ListStore contentTypes;

    PingApp *app;
    PingTest *currentTest;

    public InputPaneView(PingApp *appObj, int indentWidth, bool useTabs){
        app = appObj;
        inputBox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        generalBox = new Gtk.Box (Gtk.Orientation.VERTICAL, 10);
        dataBox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        inputHeaderBox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        dataBuffer = new Gtk.SourceBuffer (null);
        dataEntry = new Gtk.SourceView.with_buffer (dataBuffer);
        urlEntry = new Gtk.Entry ();
        requestTypes = new Gtk.ListStore (1, typeof (string));
        requestTypePicker = new Gtk.ComboBox.with_model (requestTypes);
        contentTypes = new Gtk.ListStore (1, typeof (string));
        contentTypePicker = new Gtk.ComboBox.with_model (contentTypes);
        input_header_list_store = new Gtk.ListStore (2, typeof (string), typeof (string));
        inputHeaderView = new Gtk.TreeView.with_model (input_header_list_store);
        inputHeaderListCell = new Gtk.CellRendererText ();
        inputHeaderValueListCell = new Gtk.CellRendererText ();
        urlencode_list_store = new Gtk.ListStore (2, typeof (string), typeof (string));
        urlencodeView = new Gtk.TreeView.with_model (urlencode_list_store);
        urlencodeCell = new Gtk.CellRendererText ();
        urlencodeValueCell = new Gtk.CellRendererText ();
        multipart_list_store = new Gtk.ListStore (3, typeof (string), typeof (string), typeof (string));
        multipartView = new Gtk.TreeView.with_model (multipart_list_store);
        multipartCell = new Gtk.CellRendererText ();
        multipartValueCell = new Gtk.CellRendererText ();
        multipartTypeCell = new Gtk.CellRendererPixbuf ();
        newInputHeaderButton = new Gtk.Button.from_icon_name("list-add-symbolic", Gtk.IconSize.BUTTON);
        deleteInputHeaderButton = new Gtk.Button.from_icon_name("list-remove-symbolic", Gtk.IconSize.BUTTON);
        inputHeaderActions = new Gtk.ActionBar();
        newUrlencodeButton = new Gtk.Button.from_icon_name("list-add-symbolic", Gtk.IconSize.BUTTON);
        deleteUrlencodeButton = new Gtk.Button.from_icon_name("list-remove-symbolic", Gtk.IconSize.BUTTON);
        urlencodeActions = new Gtk.ActionBar();
        newMultipartButton = new Gtk.Button.from_icon_name("list-add-symbolic", Gtk.IconSize.BUTTON);
        newMultipartFileButton = new Gtk.Button.from_icon_name("document-new-symbolic", Gtk.IconSize.BUTTON);
        deleteMultipartButton = new Gtk.Button.from_icon_name("list-remove-symbolic", Gtk.IconSize.BUTTON);
        multipartActions = new Gtk.ActionBar();
        urlLabel = new Gtk.Label(_("URL"));
        methodLabel = new Gtk.Label(_("Method"));
        contentLabel = new Gtk.Label(_("Content Type"));
        dataScrolled = new Gtk.ScrolledWindow (null, null);
        inputHeaderScrolled = new Gtk.ScrolledWindow (null, null);
        urlencodeScrolled = new Gtk.ScrolledWindow (null, null);
        multipartScrolled = new Gtk.ScrolledWindow (null, null);

        generalBox.margin = 10;
        dataEntry.expand = true;
        dataEntry.show_line_numbers = true;
        dataEntry.wrap_mode = Gtk.WrapMode.WORD_CHAR;
        dataEntry.monospace = true;
        dataEntry.tab_width = app->settings.indent_width;
        dataEntry.indent_width = app->settings.indent_width;
        dataEntry.insert_spaces_instead_of_tabs = !app->settings.indent_use_tabs;

        Gtk.TreeIter iterReq;
        Gtk.TreeIter iterCont;

        requestTypes.append (out iterReq);
        requestTypes.set (iterReq, 0, "GET");
        requestTypes.append (out iterReq);
        requestTypes.set (iterReq, 0, "POST");
        requestTypes.append (out iterReq);
        requestTypes.set (iterReq, 0, "PUT");
        requestTypes.append (out iterReq);
        requestTypes.set (iterReq, 0, "HEAD");
        requestTypes.append (out iterReq);
        requestTypes.set (iterReq, 0, "DELETE");
        requestTypes.append (out iterReq);
        requestTypes.set (iterReq, 0, "PATCH");
        requestTypes.append (out iterReq);
        requestTypes.set (iterReq, 0, "OPTIONS");
        Gtk.CellRendererText requestTypeRenderer = new Gtk.CellRendererText ();
        requestTypePicker.pack_start (requestTypeRenderer, true);
        requestTypePicker.add_attribute (requestTypeRenderer, "text", 0);
        requestTypePicker.active = 0;
        contentTypes.append (out iterCont);
        contentTypes.set (iterCont, 0, "JSON");
        contentTypes.append (out iterCont);
        contentTypes.set (iterCont, 0, "XML");
        contentTypes.append (out iterCont);
        contentTypes.set (iterCont, 0, "Form URL Encoded");
        contentTypes.append (out iterCont);
        contentTypes.set (iterCont, 0, "Multipart Form");
        Gtk.CellRendererText contentTypeRenderer = new Gtk.CellRendererText ();
        contentTypePicker.pack_start (contentTypeRenderer, true);
        contentTypePicker.add_attribute (contentTypeRenderer, "text", 0);
        contentTypePicker.active = 0;
        inputHeaderView.expand = true;
        inputHeaderListCell.editable = true;
        inputHeaderValueListCell.editable = true;
        inputHeaderView.insert_column_with_attributes (-1, _("Header"), inputHeaderListCell, "text", 0);
        inputHeaderView.insert_column_with_attributes (-1, _("Value"), inputHeaderValueListCell, "text", 1);
        urlencodeView.expand = true;
        urlencodeCell.editable = true;
        urlencodeValueCell.editable = true;
        urlencodeView.insert_column_with_attributes (-1, _("Variable"), urlencodeCell, "text", 0);
        urlencodeView.insert_column_with_attributes (-1, _("Value"), urlencodeValueCell, "text", 1);
        multipartView.expand = true;
        multipartCell.editable = true;
        multipartValueCell.editable = true;
        multipartView.insert_column_with_attributes (-1, _("Type"), multipartTypeCell, "icon-name", 0);
        multipartView.insert_column_with_attributes (-1, _("Variable"), multipartCell, "text", 1);
        multipartView.insert_column_with_attributes (-1, _("Value"), multipartValueCell, "text", 2);
        inputHeaderActions.get_style_context ().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);
        urlencodeActions.get_style_context ().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);
        multipartActions.get_style_context ().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);
        urlLabel.xalign = 0;
        methodLabel.xalign = 0;
        contentLabel.xalign = 0;
        inputHeaderScrolled.add(inputHeaderView);
        urlencodeScrolled.add(urlencodeView);
        multipartScrolled.add(multipartView);
        dataScrolled.add(dataEntry);
        Gtk.SourceStyleSchemeManager sourceSchemeMan = Gtk.SourceStyleSchemeManager.get_default();
        Gtk.SourceStyleScheme sourceTheme = sourceSchemeMan.get_scheme("solarized-light");
        dataBuffer.style_scheme = sourceTheme;

        dataBuffer.changed.connect(() => {
            if(currentTest != null){
                currentTest->data = dataBuffer.text;
            }
        });

        urlEntry.changed.connect(() => {
            if(currentTest != null){
                if(currentTest->url != urlEntry.text){
                    currentTest->url = urlEntry.text;
                }
            }
        });

        urlEntry.activate.connect(() => {
            app->action_run_test();
        });

        requestTypePicker.changed.connect(() => {
            if(currentTest != null){
                if(requestTypePicker.active == 0){
                    currentTest->requestType = "GET";
                }else if(requestTypePicker.active == 1){
                    currentTest->requestType = "POST";
                }else if(requestTypePicker.active == 2){
                    currentTest->requestType = "PUT";
                }else if(requestTypePicker.active == 3){
                    currentTest->requestType = "HEAD";
                }else if(requestTypePicker.active == 4){
                    currentTest->requestType = "DELETE";
                }else if(requestTypePicker.active == 5){
                    currentTest->requestType = "PATCH";
                }else{
                    currentTest->requestType = "OPTIONS";
                }

                updatePane();
            }
        });

        contentTypePicker.changed.connect(() => {
            if(currentTest != null){
                if(contentTypePicker.active == 0){
                    currentTest->contentType = "application/json";
                }else if(contentTypePicker.active == 1){
                    currentTest->contentType = "application/xml";
                }else if(contentTypePicker.active == 2){
                    currentTest->contentType = "application/x-www-form-urlencoded";
                }else{
                    currentTest->contentType = "multipart/form-data";
                }

                updatePane();
            }
        });

        newInputHeaderButton.clicked.connect(() => {
            if(currentTest != null){
                Gee.TreeMap<string,string> tempHeaderList = currentTest->requestHeaders;
                int counter = 1;
                while(tempHeaderList.has_key(_("New Header") + " " + counter.to_string())){
                    counter += 1;
                }

                tempHeaderList[_("New Header") + " " + counter.to_string()] = _("Value");
                currentTest->requestHeaders = tempHeaderList;

                updateRequestHeaderList();
            }
        });

        deleteInputHeaderButton.clicked.connect(() => {
            if(currentTest != null){
                Gtk.TreeModel model;
                Gtk.TreeIter iter;
                string headerName;
                if(inputHeaderView.get_selection().get_selected (out model, out iter)){
                    model.get (iter, 0, out headerName);
                    if(currentTest->requestHeaders.has_key(headerName)){
                        Gee.TreeMap<string,string> tempHeaderList = currentTest->requestHeaders;
                        tempHeaderList.unset(headerName);
                        currentTest->requestHeaders = tempHeaderList;
                        updateRequestHeaderList();
                    }
                }
            }
        });

        inputHeaderListCell.edited.connect((path, new_text) => {
            if(currentTest != null){
                Gtk.TreeModel model;
                Gtk.TreeIter iter;
                string headerName;
                if(inputHeaderView.get_selection().get_selected (out model, out iter)){
                    model.get (iter, 0, out headerName);
                    if(!currentTest->requestHeaders.has_key(new_text)){
                        Gee.TreeMap<string,string> tempHeaderList = currentTest->requestHeaders;
                        tempHeaderList[new_text] = tempHeaderList[headerName];
                        tempHeaderList.unset(headerName);
                        currentTest->requestHeaders = tempHeaderList;
                        updateRequestHeaderList();
                    }
                }
            }
        });

        inputHeaderValueListCell.edited.connect((path, new_text) => {
            if(currentTest != null){
                Gtk.TreeModel model;
                Gtk.TreeIter iter;
                string headerName;
                if(inputHeaderView.get_selection().get_selected (out model, out iter)){
                    model.get (iter, 0, out headerName);
                    Gee.TreeMap<string,string> tempHeaderList = currentTest->requestHeaders;
                    tempHeaderList[headerName] = new_text;
                    currentTest->requestHeaders = tempHeaderList;
                    updateRequestHeaderList();
                }
            }
        });

        urlencodeCell.edited.connect((path, new_text) => {
            if(currentTest != null){
                Gtk.TreeModel model;
                Gtk.TreeIter iter;
                string variableName;
                if(urlencodeView.get_selection().get_selected (out model, out iter)){
                    model.get (iter, 0, out variableName);
                    var tempDataList = new HashTable<string, string>(str_hash, str_equal);
                    Soup.Form.decode(currentTest->data).foreach ((key, value) => {
                        tempDataList.set (key, value);
                    });
                    if(!tempDataList.contains(new_text)){
                        tempDataList[new_text] = tempDataList[variableName];
                        tempDataList.remove(variableName);
                        currentTest->data = Soup.Form.encode_hash(tempDataList);
                        updateUrlencodeList();
                    }
                }
            }
        });

        urlencodeValueCell.edited.connect((path, new_text) => {
            if(currentTest != null){
                Gtk.TreeModel model;
                Gtk.TreeIter iter;
                string variableName;
                if(urlencodeView.get_selection().get_selected (out model, out iter)){
                    model.get (iter, 0, out variableName);
                    var tempDataList = new HashTable<string, string>(str_hash, str_equal);
                    Soup.Form.decode(currentTest->data).foreach ((key, value) => {
                        tempDataList.set (key, value);
                    });
                    tempDataList[variableName] = new_text;
                    currentTest->data = Soup.Form.encode_hash(tempDataList);
                    updateUrlencodeList();
                }
            }
        });

        newUrlencodeButton.clicked.connect(() => {
            if(currentTest != null){
                var tempDataList = new HashTable<string, string>(str_hash, str_equal);
                Soup.Form.decode(currentTest->data).foreach ((key, value) => {
                    tempDataList.set (key, value);
                });
                int counter = 1;
                while(tempDataList.contains(_("NewVar") + counter.to_string())){
                    counter += 1;
                }

                tempDataList[_("NewVar") + counter.to_string()] = _("Value");
                currentTest->data = Soup.Form.encode_hash(tempDataList);

                updateUrlencodeList();
            }
        });

        deleteUrlencodeButton.clicked.connect(() => {
            if(currentTest != null){
                Gtk.TreeModel model;
                Gtk.TreeIter iter;
                string variableName;
                if(urlencodeView.get_selection().get_selected (out model, out iter)){
                    model.get (iter, 0, out variableName);
                    var tempDataList = new HashTable<string, string>(str_hash, str_equal);
          Soup.Form.decode(currentTest->data).foreach ((key, value) => {
              tempDataList.set (key, value);
          });
                    if(tempDataList.contains(variableName)){
                        tempDataList.remove(variableName);
                        currentTest->data = Soup.Form.encode_hash(tempDataList);
                        updateUrlencodeList();
                    }
                }
            }
        });

        newMultipartButton.clicked.connect(() => {
            if(currentTest != null){
                var tempDataList = new HashTable<string, string>(str_hash, str_equal);
                Soup.Form.decode(currentTest->data).foreach ((key, value) => {
                    tempDataList.set (key, value);
                });
                int counter = 1;
                while(tempDataList.contains(_("NewVar") + counter.to_string()) || currentTest->multipartFiles.has_key(_("NewVar") + counter.to_string())){
                    counter += 1;
                }

                tempDataList[_("NewVar") + counter.to_string()] = _("Value");
                currentTest->data = Soup.Form.encode_hash(tempDataList);

                updateMultipartList();
            }
        });

        newMultipartFileButton.clicked.connect(() => {
            if(currentTest != null){
                Gee.TreeMap<string,string> tempFileList = currentTest->multipartFiles;
                var tempDataList = new HashTable<string, string>(str_hash, str_equal);
                Soup.Form.decode(currentTest->data).foreach ((key, value) => {
                    tempDataList.set (key, value);
                });
                int counter = 1;
                while(currentTest->multipartFiles.has_key(_("NewVar") + counter.to_string()) || tempDataList.contains(_("NewVar") + counter.to_string())){
                    counter += 1;
                }

                tempFileList[_("NewVar") + counter.to_string()] = _("No File");
                currentTest->multipartFiles = tempFileList;

                updateMultipartList();
            }
        });

        deleteMultipartButton.clicked.connect(() => {
            if(currentTest != null){
                Gtk.TreeModel model;
                Gtk.TreeIter iter;
                string variableName;
                if(multipartView.get_selection().get_selected (out model, out iter)){
                    model.get (iter, 1, out variableName);
                    var tempDataList = new HashTable<string, string>(str_hash, str_equal);
                    Soup.Form.decode(currentTest->data).foreach ((key, value) => {
                        tempDataList.set (key, value);
                    });
                    if(tempDataList.contains(variableName)){
                        tempDataList.remove(variableName);
                        currentTest->data = Soup.Form.encode_hash(tempDataList);
                        updateMultipartList();
                    }
                    if(currentTest->multipartFiles.has_key(variableName)){
                        Gee.TreeMap<string,string> tempMultipartFiles = currentTest->multipartFiles;
                        tempMultipartFiles.unset(variableName);
                        currentTest->multipartFiles = tempMultipartFiles;
                        updateMultipartList();
                    }
                }
            }
        });

        multipartCell.edited.connect((path, new_text) => {
            if(currentTest != null){
                Gtk.TreeModel model;
                Gtk.TreeIter iter;
                string variableName;
                if(multipartView.get_selection().get_selected (out model, out iter)){
                    model.get (iter, 1, out variableName);
                    var tempDataList = new HashTable<string, string>(str_hash, str_equal);
                    Soup.Form.decode(currentTest->data).foreach ((key, value) => {
                        tempDataList.set (key, value);
                    });
                    if(!tempDataList.contains(new_text) && !currentTest->multipartFiles.has_key(new_text)){
                        if(tempDataList.contains(variableName)){
                            tempDataList[new_text] = tempDataList[variableName];
                            tempDataList.remove(variableName);
                            currentTest->data = Soup.Form.encode_hash(tempDataList);
                        }else if(currentTest->multipartFiles.has_key(variableName)){
                            Gee.TreeMap<string,string> tempMultipartFiles = currentTest->multipartFiles;
                            tempMultipartFiles[new_text] = tempMultipartFiles[variableName];
                            tempMultipartFiles.unset(variableName);
                            currentTest->multipartFiles = tempMultipartFiles;
                        }

                        updateMultipartList();
                    }
                }
            }
        });

        multipartValueCell.edited.connect((path, new_text) => {
            if(currentTest != null){
                Gtk.TreeModel model;
                Gtk.TreeIter iter;
                string variableName;
                if(multipartView.get_selection().get_selected (out model, out iter)){
                    model.get (iter, 1, out variableName);
                    var tempDataList = new HashTable<string, string>(str_hash, str_equal);
                    Soup.Form.decode(currentTest->data).foreach ((key, value) => {
                        tempDataList.set (key, value);
                    });
                    if(tempDataList.contains(variableName)){
                        tempDataList[variableName] = new_text;
                        currentTest->data = Soup.Form.encode_hash(tempDataList);
                    }
                    updateMultipartList();
                }
            }
        });

        multipartValueCell.editing_started.connect((cell) => {
            if(currentTest != null){
                Gtk.TreeModel model;
                Gtk.TreeIter iter;
                string variableName;
                if(multipartView.get_selection().get_selected (out model, out iter)){
                    model.get (iter, 1, out variableName);
                    if(currentTest->multipartFiles.has_key(variableName)){
                        Gtk.FileChooserDialog chooser = new Gtk.FileChooserDialog (_("Select file to be uploaded"), app->main_window, Gtk.FileChooserAction.OPEN, _("_Cancel"), Gtk.ResponseType.CANCEL, _("_Open"), Gtk.ResponseType.ACCEPT);
                        if (chooser.run () == Gtk.ResponseType.ACCEPT) {
                            string fname = chooser.get_filename ();
                            Gee.TreeMap<string,string> tempMultipartFiles = currentTest->multipartFiles;
                            tempMultipartFiles[variableName] = fname;
                            currentTest->multipartFiles = tempMultipartFiles;
                        }

                        chooser.close ();
                        updateMultipartList();
                        cell.editing_done();
                    }
                }
            }
        });

        inputHeaderActions.pack_end(newInputHeaderButton);
        inputHeaderActions.pack_end(deleteInputHeaderButton);
        urlencodeActions.pack_end(newUrlencodeButton);
        urlencodeActions.pack_end(deleteUrlencodeButton);
        multipartActions.pack_end(newMultipartButton);
        multipartActions.pack_end(newMultipartFileButton);
        multipartActions.pack_end(deleteMultipartButton);
        inputBox.pack_start(generalBox, true, true, 0);
        inputBox.pack_start(dataBox, true, true, 0);
        inputBox.pack_start(inputHeaderBox, true, true, 0);
        generalBox.pack_start(urlLabel, false, false, 0);
        generalBox.pack_start(urlEntry, false, false, 0);
        generalBox.pack_start(methodLabel, false, false, 0);
        generalBox.pack_start(requestTypePicker, false, false, 0);
        generalBox.pack_start(contentLabel, false, false, 0);
        generalBox.pack_start(contentTypePicker, false, false, 0);
        dataBox.pack_start(dataScrolled, true, true, 0);
        dataBox.pack_start(urlencodeScrolled, true, true, 0);
        dataBox.pack_start(urlencodeActions, false, false, 0);
        dataBox.pack_start(multipartScrolled, true, true, 0);
        dataBox.pack_start(multipartActions, false, false, 0);
        inputHeaderBox.pack_start(inputHeaderScrolled, true, true, 0);
        inputHeaderBox.pack_start(inputHeaderActions, false, false, 0);
    }

    public void updateRequestHeaderList(){
        if(currentTest != null){
            Gtk.TreeIter iter;
            input_header_list_store.clear();
            foreach (var entry in currentTest->requestHeaders.entries) {
                input_header_list_store.append (out iter);
                input_header_list_store.set (iter, 0, entry.key, 1, entry.value);
            }
            inputHeaderView.set_model(input_header_list_store);
        }
    }

    public void updateUrlencodeList(){
        if(currentTest != null){
            Gtk.TreeIter iter;
            urlencode_list_store.clear();
            Gee.TreeMap<string,string> temp = new Gee.TreeMap<string,string>();
            Soup.Form.decode(currentTest->data).foreach ((key, val) => {
                temp[key] = val;
            });
            foreach (var entry in temp.entries) {
                urlencode_list_store.append (out iter);
                urlencode_list_store.set (iter, 0, entry.key, 1, entry.value);
            }
            urlencodeView.set_model(urlencode_list_store);
        }
    }

    public void updateMultipartList(){
        if(currentTest != null){
            Gtk.TreeIter iter;
            multipart_list_store.clear();
            Gee.TreeMap<string,string> tempText = new Gee.TreeMap<string,string>();
            Soup.Form.decode(currentTest->data).foreach ((key, val) => {
                tempText[key] = val;
            });
            foreach (var entry in tempText.entries) {
                multipart_list_store.append (out iter);
                multipart_list_store.set (iter, 0, "insert-text", 1, entry.key, 2, entry.value);
            }
            foreach (var entry in currentTest->multipartFiles.entries) {
                multipart_list_store.append (out iter);
                multipart_list_store.set (iter, 0, "text-x-preview", 1, entry.key, 2, entry.value);
            }
            multipartView.set_model(multipart_list_store);
        }
    }

    public void updatePane(){
        if(currentTest != null){
            urlEntry.text = currentTest->url;

            if(currentTest->requestType == "GET"){
                requestTypePicker.active = 0;
                app->viewButton.set_item_visible(1, false);
                if(app->viewButton.selected == 1){
                    app->viewButton.selected = 0;
                }
                contentLabel.visible = false;
                contentTypePicker.visible = false;
            }else if(currentTest->requestType == "POST"){
                requestTypePicker.active = 1;
                app->viewButton.set_item_visible(1, true);
                contentLabel.visible = true;
                contentTypePicker.visible = true;
            }else if(currentTest->requestType == "PUT"){
                requestTypePicker.active = 2;
                app->viewButton.set_item_visible(1, true);
                contentLabel.visible = true;
                contentTypePicker.visible = true;
            }else if(currentTest->requestType == "HEAD"){
                requestTypePicker.active = 3;
                app->viewButton.set_item_visible(1, false);
                if(app->viewButton.selected == 1){
                    app->viewButton.selected = 0;
                }
                contentLabel.visible = false;
                contentTypePicker.visible = false;
            }else if(currentTest->requestType == "DELETE"){
                requestTypePicker.active = 4;
                app->viewButton.set_item_visible(1, false);
                if(app->viewButton.selected == 1){
                    app->viewButton.selected = 0;
                }
                contentLabel.visible = false;
                contentTypePicker.visible = false;
            }else if(currentTest->requestType == "PATCH"){
                requestTypePicker.active = 5;
                app->viewButton.set_item_visible(1, true);
                contentLabel.visible = true;
                contentTypePicker.visible = true;
            }else if(currentTest->requestType == "OPTIONS"){
                requestTypePicker.active = 6;
                app->viewButton.set_item_visible(1, false);
                if(app->viewButton.selected == 1){
                    app->viewButton.selected = 0;
                }
                contentLabel.visible = false;
                contentTypePicker.visible = false;
            }

            var langManager = Gtk.SourceLanguageManager.get_default();
            if(currentTest->contentType == "application/json"){
                contentTypePicker.active = 0;
                dataBuffer.language = langManager.get_language("json");
                dataBuffer.text = currentTest->data;
                dataScrolled.visible = true;
                urlencodeScrolled.visible = false;
                urlencodeActions.visible = false;
                multipartScrolled.visible = false;
                multipartActions.visible = false;
            }else if(currentTest->contentType == "application/xml"){
                contentTypePicker.active = 1;
                dataBuffer.language = langManager.get_language("xml");
                dataBuffer.text = currentTest->data;
                dataScrolled.visible = true;
                urlencodeScrolled.visible = false;
                urlencodeActions.visible = false;
                multipartScrolled.visible = false;
                multipartActions.visible = false;
            }else if(currentTest->contentType == "application/x-www-form-urlencoded"){
                contentTypePicker.active = 2;
                dataBuffer.language = null;
                updateUrlencodeList();
                dataScrolled.visible = false;
                urlencodeScrolled.visible = true;
                urlencodeActions.visible = true;
                multipartScrolled.visible = false;
                multipartActions.visible = false;
            }else{
                contentTypePicker.active = 3;
                dataBuffer.language = null;
                updateMultipartList();
                dataScrolled.visible = false;
                urlencodeScrolled.visible = false;
                urlencodeActions.visible = false;
                multipartScrolled.visible = true;
                multipartActions.visible = true;
            }

            if(app->viewButton.selected == 0){
                generalBox.visible = true;
                dataBox.visible = false;
                inputHeaderBox.visible = false;
            }else if(app->viewButton.selected == 1){
                generalBox.visible = false;
                dataBox.visible = true;
                inputHeaderBox.visible = false;
            }else if(app->viewButton.selected == 2){
                generalBox.visible = false;
                dataBox.visible = false;
                inputHeaderBox.visible = true;
            }

            updateRequestHeaderList();
        }else{
            generalBox.visible = false;
            dataBox.visible = false;
            inputHeaderBox.visible = false;
        }
    }

    public Gtk.Widget getRootWidget(){
        return inputBox;
    }

    public void updateCurrentTest(PingTest *newTest){
        currentTest = newTest;
    }
}

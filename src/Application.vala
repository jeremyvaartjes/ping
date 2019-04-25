/*
 *                   __ 
 *   _____ _        |  |
 *  |  _  |_|___ ___|  |
 *  |   __| |   | . |__|
 *  |__|  |_|_|_|_  |__|
 *              |___|   
 *         Version 0.6
 *  
 *  Jeremy Vaartjes <jeremy@vaartj.es>
 *  
 *  ====================
 *  
 *  Copyright (C) 2018 Jeremy Vaartjes
 *  
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *  
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *  
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *  
 *  ====================
 *  
 */

public class PingApp : Gtk.Application {

    InputPaneView inputView;
    OutputPaneView outputView;

    // Widgets

    public Gtk.ApplicationWindow main_window;
    Gtk.Box mainBox;
    //Gtk.Box inputBox;
    //Gtk.Box generalBox;
    //Gtk.Box dataBox;
    //Gtk.Box inputHeaderBox;
    Gtk.Paned mainPane;
    Gtk.Paned apiPane;
    Gtk.HeaderBar header;
    Gtk.Button runTestButton;
    public Granite.Widgets.ModeButton viewButton;
    Granite.Widgets.ModeButton outputViewButton;
    //Gtk.Entry urlEntry;
    Gtk.TreeView testListView;
    //Gtk.TreeView inputHeaderView;
    //Gtk.TreeView urlencodeView;
    //Gtk.TreeView multipartView;
    //Gtk.SourceView dataEntry;
    //Gtk.ComboBox requestTypePicker;
    //Gtk.ComboBox contentTypePicker;
    Gtk.CellRendererText testListCell;
    //Gtk.CellRendererText inputHeaderListCell;
    //Gtk.CellRendererText inputHeaderValueListCell;
    //Gtk.CellRendererText urlencodeCell;
    //Gtk.CellRendererText urlencodeValueCell;
    //Gtk.CellRendererText multipartCell;
    //Gtk.CellRendererText multipartValueCell;
    //Gtk.CellRendererPixbuf multipartTypeCell;
    Gtk.Button newTestButton;
    Gtk.Button deleteTestButton;
    Gtk.ActionBar testListActions;
    //Gtk.Button newInputHeaderButton;
    //Gtk.Button deleteInputHeaderButton;
    //Gtk.ActionBar inputHeaderActions;
    //Gtk.Button newUrlencodeButton;
    //Gtk.Button deleteUrlencodeButton;
    //Gtk.ActionBar urlencodeActions;
    //Gtk.Button newMultipartButton;
    //Gtk.Button deleteMultipartButton;
    //Gtk.Button newMultipartFileButton;
    //Gtk.ActionBar multipartActions;
    Gtk.Grid gridLeftPane;
    //Gtk.Label urlLabel;
    //Gtk.Label methodLabel;
    //Gtk.Label contentLabel;
    //Gtk.ScrolledWindow dataScrolled;
    //Gtk.ScrolledWindow inputHeaderScrolled;
    //Gtk.ScrolledWindow urlencodeScrolled;
    //Gtk.ScrolledWindow multipartScrolled;
    Granite.Widgets.Welcome welcome;
    Gtk.InfoBar errorBar;
    Gtk.Label errorText;
    Gtk.MenuButton settingsBtn;
    Gtk.Popover settingsPopover;
    Gtk.Grid layoutSettings;
    Gtk.Label indentTabLabel;
    Gtk.Label indentSizeLabel;
    Gtk.Switch indentTabSwitch;
    Gtk.SpinButton indentSizeEntry;

    // Data Storage

    Gee.TreeMap<int, PingTest> testObjs;
    PingTest* currentTest;
    Gtk.ListStore test_list_store;
    //Gtk.ListStore input_header_list_store;
    //Gtk.ListStore urlencode_list_store;
    //Gtk.ListStore multipart_list_store;
    Gtk.TreeIter iter;
    //Gtk.SourceBuffer dataBuffer;
    //Gtk.SourceLanguageManager langManager;
    //Gtk.ListStore requestTypes;
    //Gtk.TreeIter iterReq;
    //Gtk.ListStore contentTypes;
    //Gtk.TreeIter iterCont;

    public SimpleActionGroup actions { get; construct; }
    public const string ACTION_PREFIX = "win.";
    public const string ACTION_RUN_TEST = "action_run_test";
    public static Gee.MultiMap<string, string> action_accelerators = new Gee.HashMultiMap<string, string> ();
    private const ActionEntry[] action_entries = {
        { ACTION_RUN_TEST, action_run_test }
    };

    public Settings settings;

    public PingApp () {
        Object (
            application_id: "com.github.jeremyvaartjes.ping",
            flags: ApplicationFlags.FLAGS_NONE,
            actions: new SimpleActionGroup ()
        );

        testObjs = new Gee.TreeMap<int, PingTest>();
        Gee.ArrayList<int> existingTests = PingTest.getListOfTests();
        foreach (var entry in existingTests) {
            try{
                PingTest test = new PingTest.load(entry);
                testObjs[test.id] = test;
            }catch(IOError e){
                stdout.printf("Error: %s\n", e.message);
            }
        }

        currentTest = null;

        //langManager = Gtk.SourceLanguageManager.get_default();

        settings = new Settings ();
    }

    public void selectFirstListItem(){
        var selection = testListView.get_selection();
        selection.select_path(new Gtk.TreePath.from_string ("0"));
    }

    public void selectListItem(int item){
        Gtk.TreeIter iter;
        test_list_store.get_iter (out iter, new Gtk.TreePath.from_string ("0"));
        bool done = false;
        while(!done){
            Value val;
            test_list_store.get_value(iter, 0, out val);
            if(val.get_int() == item){
                var selection = testListView.get_selection();
                selection.select_iter(iter);
                done = true;
            } else {
                if(!test_list_store.iter_next(ref iter)){
                    done = true;
                }
            }
        }
    }

    public void updateTestList(){
        test_list_store.clear();
        foreach (var entry in testObjs.entries) {
            test_list_store.append (out iter);
            test_list_store.set (iter, 0, entry.key, 1, entry.value.name);
        }
        testListView.set_model(test_list_store);
        Gtk.TreeModel model;
        Gtk.TreeIter iter;
        var selection = testListView.get_selection();
        if(!selection.get_selected(out model, out iter)){
            selectFirstListItem();
        }
    }

    /*public void updateRequestHeaderList(){
        Gtk.TreeModel model;
        Gtk.TreeIter iter;
        int id;
        if(testListView.get_selection().get_selected (out model, out iter)){
            model.get (iter, 0, out id);
            input_header_list_store.clear();
            foreach (var entry in testObjs[id].requestHeaders.entries) {
                input_header_list_store.append (out iter);
                input_header_list_store.set (iter, 0, entry.key, 1, entry.value);
            }
            inputHeaderView.set_model(input_header_list_store);
        }
    }

    public void updateUrlencodeList(){
        Gtk.TreeModel model;
        Gtk.TreeIter iter;
        int id;
        if(testListView.get_selection().get_selected (out model, out iter)){
            model.get (iter, 0, out id);
            urlencode_list_store.clear();
            Gee.TreeMap<string,string> temp = new Gee.TreeMap<string,string>();
            Soup.Form.decode(testObjs[id].data).foreach ((key, val) => {
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
        Gtk.TreeModel model;
        Gtk.TreeIter iter;
        int id;
        if(testListView.get_selection().get_selected (out model, out iter)){
            model.get (iter, 0, out id);
            multipart_list_store.clear();
            Gee.TreeMap<string,string> tempText = new Gee.TreeMap<string,string>();
            Soup.Form.decode(testObjs[id].data).foreach ((key, val) => {
                tempText[key] = val;
            });
            foreach (var entry in tempText.entries) {
                multipart_list_store.append (out iter);
                multipart_list_store.set (iter, 0, "insert-text", 1, entry.key, 2, entry.value);
            }
            foreach (var entry in testObjs[id].multipartFiles.entries) {
                multipart_list_store.append (out iter);
                multipart_list_store.set (iter, 0, "text-x-preview", 1, entry.key, 2, entry.value);
            }
            multipartView.set_model(multipart_list_store);
        }
    }*/

    private void createElements(){
        main_window = new Gtk.ApplicationWindow (this);
        mainBox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        /*inputBox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        generalBox = new Gtk.Box (Gtk.Orientation.VERTICAL, 10);
        dataBox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        inputHeaderBox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);*/
        mainPane = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        apiPane = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        header = new Gtk.HeaderBar();
        runTestButton = new Gtk.Button.from_icon_name("media-playback-start", LARGE_TOOLBAR);
        viewButton = new Granite.Widgets.ModeButton();
        outputViewButton = new Granite.Widgets.ModeButton();
        /*dataBuffer = new Gtk.SourceBuffer (null);
        dataEntry = new Gtk.SourceView.with_buffer (dataBuffer);
        urlEntry = new Gtk.Entry ();
        requestTypes = new Gtk.ListStore (1, typeof (string));
        requestTypePicker = new Gtk.ComboBox.with_model (requestTypes);
        contentTypes = new Gtk.ListStore (1, typeof (string));
        contentTypePicker = new Gtk.ComboBox.with_model (contentTypes);*/
        test_list_store = new Gtk.ListStore (2, typeof (int), typeof (string));
        testListView = new Gtk.TreeView.with_model (test_list_store);
        testListCell = new Gtk.CellRendererText ();
        /*input_header_list_store = new Gtk.ListStore (2, typeof (string), typeof (string));
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
        multipartTypeCell = new Gtk.CellRendererPixbuf ();*/
        newTestButton = new Gtk.Button.from_icon_name("list-add-symbolic", Gtk.IconSize.BUTTON);
        deleteTestButton = new Gtk.Button.from_icon_name("list-remove-symbolic", Gtk.IconSize.BUTTON);
        testListActions = new Gtk.ActionBar();
        /*newInputHeaderButton = new Gtk.Button.from_icon_name("list-add-symbolic", Gtk.IconSize.BUTTON);
        deleteInputHeaderButton = new Gtk.Button.from_icon_name("list-remove-symbolic", Gtk.IconSize.BUTTON);
        inputHeaderActions = new Gtk.ActionBar();
        newUrlencodeButton = new Gtk.Button.from_icon_name("list-add-symbolic", Gtk.IconSize.BUTTON);
        deleteUrlencodeButton = new Gtk.Button.from_icon_name("list-remove-symbolic", Gtk.IconSize.BUTTON);
        urlencodeActions = new Gtk.ActionBar();
        newMultipartButton = new Gtk.Button.from_icon_name("list-add-symbolic", Gtk.IconSize.BUTTON);
        newMultipartFileButton = new Gtk.Button.from_icon_name("document-new-symbolic", Gtk.IconSize.BUTTON);
        deleteMultipartButton = new Gtk.Button.from_icon_name("list-remove-symbolic", Gtk.IconSize.BUTTON);
        multipartActions = new Gtk.ActionBar();*/
        gridLeftPane = new Gtk.Grid ();
        /*urlLabel = new Gtk.Label(_("URL"));
        methodLabel = new Gtk.Label(_("Method"));
        contentLabel = new Gtk.Label(_("Content Type"));
        dataScrolled = new Gtk.ScrolledWindow (null, null);
        inputHeaderScrolled = new Gtk.ScrolledWindow (null, null);
        urlencodeScrolled = new Gtk.ScrolledWindow (null, null);
        multipartScrolled = new Gtk.ScrolledWindow (null, null);*/
        welcome = new Granite.Widgets.Welcome ("Ping!", _("Start testing your API."));
        errorBar = new Gtk.InfoBar ();
        errorText = new Gtk.Label("");
        settingsBtn = new Gtk.MenuButton();
        settingsPopover = new Gtk.Popover(settingsBtn);
        layoutSettings = new Gtk.Grid ();
        indentTabLabel = new Gtk.Label(_("Use tabs for indentation"));
        indentSizeLabel = new Gtk.Label(_("Indentation/tab size"));
        indentTabSwitch = new Gtk.Switch();
        indentSizeEntry = new Gtk.SpinButton.with_range(1, 20, 1);
    }

    private void configureElements(){
        main_window.default_height = 550;
        main_window.default_width = 1000;
        main_window.title = "Ping!";
        action_accelerators.set (ACTION_RUN_TEST, "<Control>r");
        actions.add_action_entries (action_entries, this);
        main_window.insert_action_group ("win", actions);
        foreach (var action in action_accelerators.get_keys ()) {
            this.set_accels_for_action (ACTION_PREFIX + action, action_accelerators[action].to_array ());
        }
        //generalBox.margin = 10;
        header.show_close_button = true;
        header.title = "Ping!";
        main_window.set_titlebar(header);
        viewButton.append_text(_("General"));
        viewButton.append_text(_("Request Body Data"));
        viewButton.append_text(_("Request Headers"));
        viewButton.set_active(0);
        outputViewButton.append_text(_("Response Body"));
        outputViewButton.append_text(_("Response Headers"));
        outputViewButton.set_active(0);
        /*dataEntry.expand = true;
        dataEntry.show_line_numbers = true;
        dataEntry.wrap_mode = Gtk.WrapMode.WORD_CHAR;
        dataEntry.monospace = true;
        dataEntry.tab_width = settings.indent_width;
        dataEntry.indent_width = settings.indent_width;
        dataEntry.insert_spaces_instead_of_tabs = !settings.indent_use_tabs;
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
        contentTypePicker.active = 0;*/
        testListView.headers_visible = false;
        testListView.expand = true;
        testListCell.editable = true;
        testListView.insert_column_with_attributes (-1, "Test", testListCell, "text", 1);
        /*inputHeaderView.expand = true;
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
        multipartView.insert_column_with_attributes (-1, _("Value"), multipartValueCell, "text", 2);*/
        testListActions.get_style_context ().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);
        /*inputHeaderActions.get_style_context ().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);
        urlencodeActions.get_style_context ().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);
        multipartActions.get_style_context ().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);
        urlLabel.xalign = 0;
        methodLabel.xalign = 0;
        contentLabel.xalign = 0;
        inputHeaderScrolled.add(inputHeaderView);
        urlencodeScrolled.add(urlencodeView);
        multipartScrolled.add(multipartView);
        dataScrolled.add(dataEntry);*/
        welcome.append ("document-new", _("Create a Test"), _("Create a HTTP request to send to and API."));
        errorBar.message_type = Gtk.MessageType.ERROR;
        errorBar.revealed = false;
        errorBar.show_close_button = true;
        runTestButton.action_name = ACTION_PREFIX + ACTION_RUN_TEST;
        runTestButton.tooltip_markup = Granite.markup_accel_tooltip (this.get_accels_for_action (runTestButton.action_name), _("Run The Test"));
        /*Gtk.SourceStyleSchemeManager sourceSchemeMan = Gtk.SourceStyleSchemeManager.get_default();
        Gtk.SourceStyleScheme sourceTheme = sourceSchemeMan.get_scheme("solarized-light");
        dataBuffer.style_scheme = sourceTheme;*/
        layoutSettings.row_spacing = 10;
        layoutSettings.column_spacing = 10;
        layoutSettings.margin = 10;
        settingsPopover.add(layoutSettings);
        settingsBtn.image = new Gtk.Image.from_icon_name ("open-menu", Gtk.IconSize.LARGE_TOOLBAR);
        settingsBtn.popover = settingsPopover;
        indentTabSwitch.halign = Gtk.Align.START;
        indentTabSwitch.state = settings.indent_use_tabs;
        indentSizeEntry.value = settings.indent_width;
    }

    private void setupSignals(){
        viewButton.mode_changed.connect(() => {
            inputView.updatePane();
        });

        outputViewButton.mode_changed.connect(() => {
            outputView.updateView(currentTest, outputViewButton);
        });

        /*dataBuffer.changed.connect(() => {
            Gtk.TreeModel model;
            Gtk.TreeIter iter;
            int id;
            if(testListView.get_selection().get_selected (out model, out iter)){
                model.get (iter, 0, out id);
                testObjs[id].data = dataBuffer.text;
            }
        });*/

        testListCell.edited.connect((path, new_text) => {
            Gtk.TreeModel model;
            Gtk.TreeIter iter;
            int id;
            if(testListView.get_selection().get_selected (out model, out iter)){
                model.get (iter, 0, out id);
                if(testObjs[id].name != new_text){
                    testObjs[id].name = new_text;
                    updateTestList();
                    selectListItem(id);
                }
            }
        });

        testListView.get_selection().changed.connect(() => {
            Gtk.TreeModel model;
            Gtk.TreeIter iter;
            int id;
            if(testListView.get_selection().get_selected (out model, out iter)){
                model.get (iter, 0, out id);
                currentTest = testObjs[id];
            }else{
                currentTest = null;
            }
            inputView.updateCurrentTest(currentTest);
            inputView.updatePane();
            outputView.updateView(currentTest, outputViewButton);
        });

        newTestButton.clicked.connect(() => {
            this.newTest();
        });

        deleteTestButton.clicked.connect(() => {
            Gtk.TreeModel model;
            Gtk.TreeIter iter;
            int id;
            if(testListView.get_selection().get_selected (out model, out iter)){
                model.get (iter, 0, out id);
                selectFirstListItem();
                testObjs[id].remove();
                testObjs.unset(id);
                updateTestList();
                if(testObjs.size == 0){
                    welcome.visible = true;
                    mainPane.visible = false;
                }
            }
        });

        /*urlEntry.changed.connect(() => {
            Gtk.TreeModel model;
            Gtk.TreeIter iter;
            int id;
            if(testListView.get_selection().get_selected (out model, out iter)){
                model.get (iter, 0, out id);
                if(testObjs[id].url != urlEntry.text){
                    testObjs[id].url = urlEntry.text;
                }
            }
        });

        urlEntry.activate.connect(() => {
            action_run_test();
        });

        requestTypePicker.changed.connect(() => {
            Gtk.TreeModel model;
            Gtk.TreeIter iter;
            int id;
            if(testListView.get_selection().get_selected (out model, out iter)){
                model.get (iter, 0, out id);
                if(requestTypePicker.active == 0){
                    testObjs[id].requestType = "GET";
                }else if(requestTypePicker.active == 1){
                    testObjs[id].requestType = "POST";
                }else if(requestTypePicker.active == 2){
                    testObjs[id].requestType = "PUT";
                }else if(requestTypePicker.active == 3){
                    testObjs[id].requestType = "HEAD";
                }else if(requestTypePicker.active == 4){
                    testObjs[id].requestType = "DELETE";
                }else if(requestTypePicker.active == 5){
                    testObjs[id].requestType = "PATCH";
                }else{
                    testObjs[id].requestType = "OPTIONS";
                }

                updateInputPane();
            }
        });

        contentTypePicker.changed.connect(() => {
            Gtk.TreeModel model;
            Gtk.TreeIter iter;
            int id;
            if(testListView.get_selection().get_selected (out model, out iter)){
                model.get (iter, 0, out id);
                if(contentTypePicker.active == 0){
                    testObjs[id].contentType = "application/json";
                }else if(contentTypePicker.active == 1){
                    testObjs[id].contentType = "application/xml";
                }else if(contentTypePicker.active == 2){
                    testObjs[id].contentType = "application/x-www-form-urlencoded";
                }else{
                    testObjs[id].contentType = "multipart/form-data";
                }

                updateInputPane();
            }
        });*/

        welcome.activated.connect ((index) => {
            switch (index) {
                case 0:
                    this.newTest();
                    break;
            }
        });

        errorBar.response.connect(() => {
            errorBar.revealed = false;
        });

        /*newInputHeaderButton.clicked.connect(() => {
            Gtk.TreeModel model;
            Gtk.TreeIter iter;
            int id;
            if(testListView.get_selection().get_selected (out model, out iter)){
                model.get (iter, 0, out id);

                Gee.TreeMap<string,string> tempHeaderList = testObjs[id].requestHeaders;
                int counter = 1;
                while(tempHeaderList.has_key(_("New Header") + " " + counter.to_string())){
                    counter += 1;
                }

                tempHeaderList[_("New Header") + " " + counter.to_string()] = _("Value");
                testObjs[id].requestHeaders = tempHeaderList;

                updateRequestHeaderList();
            }
        });

        deleteInputHeaderButton.clicked.connect(() => {
            Gtk.TreeModel model;
            Gtk.TreeIter iter;
            int id;
            if(testListView.get_selection().get_selected (out model, out iter)){
                model.get (iter, 0, out id);
                string headerName;
                if(inputHeaderView.get_selection().get_selected (out model, out iter)){
                    model.get (iter, 0, out headerName);
                    if(testObjs[id].requestHeaders.has_key(headerName)){
                        Gee.TreeMap<string,string> tempHeaderList = testObjs[id].requestHeaders;
                        tempHeaderList.unset(headerName);
                        testObjs[id].requestHeaders = tempHeaderList;
                        updateRequestHeaderList();
                    }
                }
            }
        });

        inputHeaderListCell.edited.connect((path, new_text) => {
            Gtk.TreeModel model;
            Gtk.TreeIter iter;
            int id;
            if(testListView.get_selection().get_selected (out model, out iter)){
                model.get (iter, 0, out id);
                string headerName;
                if(inputHeaderView.get_selection().get_selected (out model, out iter)){
                    model.get (iter, 0, out headerName);
                    if(!testObjs[id].requestHeaders.has_key(new_text)){
                        Gee.TreeMap<string,string> tempHeaderList = testObjs[id].requestHeaders;
                        tempHeaderList[new_text] = tempHeaderList[headerName];
                        tempHeaderList.unset(headerName);
                        testObjs[id].requestHeaders = tempHeaderList;
                        updateRequestHeaderList();
                    }
                }
            }
        });

        inputHeaderValueListCell.edited.connect((path, new_text) => {
            Gtk.TreeModel model;
            Gtk.TreeIter iter;
            int id;
            if(testListView.get_selection().get_selected (out model, out iter)){
                model.get (iter, 0, out id);
                string headerName;
                if(inputHeaderView.get_selection().get_selected (out model, out iter)){
                    model.get (iter, 0, out headerName);
                    Gee.TreeMap<string,string> tempHeaderList = testObjs[id].requestHeaders;
                    tempHeaderList[headerName] = new_text;
                    testObjs[id].requestHeaders = tempHeaderList;
                    updateRequestHeaderList();
                }
            }
        });

        urlencodeCell.edited.connect((path, new_text) => {
            Gtk.TreeModel model;
            Gtk.TreeIter iter;
            int id;
            if(testListView.get_selection().get_selected (out model, out iter)){
                model.get (iter, 0, out id);
                string variableName;
                if(urlencodeView.get_selection().get_selected (out model, out iter)){
                    model.get (iter, 0, out variableName);
                    HashTable<string,string> tempDataList = Soup.Form.decode(testObjs[id].data);
                    if(!tempDataList.contains(new_text)){
                        tempDataList[new_text] = tempDataList[variableName];
                        tempDataList.remove(variableName);
                        testObjs[id].data = Soup.Form.encode_hash(tempDataList);
                        updateUrlencodeList();
                    }
                }
            }
        });

        urlencodeValueCell.edited.connect((path, new_text) => {
            Gtk.TreeModel model;
            Gtk.TreeIter iter;
            int id;
            if(testListView.get_selection().get_selected (out model, out iter)){
                model.get (iter, 0, out id);
                string variableName;
                if(urlencodeView.get_selection().get_selected (out model, out iter)){
                    model.get (iter, 0, out variableName);
                    HashTable<string,string> tempDataList = Soup.Form.decode(testObjs[id].data);
                    tempDataList[variableName] = new_text;
                    testObjs[id].data = Soup.Form.encode_hash(tempDataList);
                    updateUrlencodeList();
                }
            }
        });

        newUrlencodeButton.clicked.connect(() => {
            Gtk.TreeModel model;
            Gtk.TreeIter iter;
            int id;
            if(testListView.get_selection().get_selected (out model, out iter)){
                model.get (iter, 0, out id);

                HashTable<string,string> tempDataList = Soup.Form.decode(testObjs[id].data);
                int counter = 1;
                while(tempDataList.contains(_("NewVar") + counter.to_string())){
                    counter += 1;
                }

                tempDataList[_("NewVar") + counter.to_string()] = _("Value");
                testObjs[id].data = Soup.Form.encode_hash(tempDataList);

                updateUrlencodeList();
            }
        });

        deleteUrlencodeButton.clicked.connect(() => {
            Gtk.TreeModel model;
            Gtk.TreeIter iter;
            int id;
            if(testListView.get_selection().get_selected (out model, out iter)){
                model.get (iter, 0, out id);
                string variableName;
                if(urlencodeView.get_selection().get_selected (out model, out iter)){
                    model.get (iter, 0, out variableName);
                    HashTable<string,string> tempDataList = Soup.Form.decode(testObjs[id].data);
                    if(tempDataList.contains(variableName)){
                        tempDataList.remove(variableName);
                        testObjs[id].data = Soup.Form.encode_hash(tempDataList);
                        updateUrlencodeList();
                    }
                }
            }
        });

        newMultipartButton.clicked.connect(() => {
            Gtk.TreeModel model;
            Gtk.TreeIter iter;
            int id;
            if(testListView.get_selection().get_selected (out model, out iter)){
                model.get (iter, 0, out id);

                HashTable<string,string> tempDataList = Soup.Form.decode(testObjs[id].data);
                int counter = 1;
                while(tempDataList.contains(_("NewVar") + counter.to_string()) || testObjs[id].multipartFiles.has_key(_("NewVar") + counter.to_string())){
                    counter += 1;
                }

                tempDataList[_("NewVar") + counter.to_string()] = _("Value");
                testObjs[id].data = Soup.Form.encode_hash(tempDataList);

                updateMultipartList();
            }
        });

        newMultipartFileButton.clicked.connect(() => {
            Gtk.TreeModel model;
            Gtk.TreeIter iter;
            int id;
            if(testListView.get_selection().get_selected (out model, out iter)){
                model.get (iter, 0, out id);

                Gee.TreeMap<string,string> tempFileList = testObjs[id].multipartFiles;
                HashTable<string,string> tempDataList = Soup.Form.decode(testObjs[id].data);
                int counter = 1;
                while(testObjs[id].multipartFiles.has_key(_("NewVar") + counter.to_string()) || tempDataList.contains(_("NewVar") + counter.to_string())){
                    counter += 1;
                }

                tempFileList[_("NewVar") + counter.to_string()] = _("No File");
                testObjs[id].multipartFiles = tempFileList;

                updateMultipartList();
            }
        });

        deleteMultipartButton.clicked.connect(() => {
            Gtk.TreeModel model;
            Gtk.TreeIter iter;
            int id;
            if(testListView.get_selection().get_selected (out model, out iter)){
                model.get (iter, 0, out id);
                string variableName;
                if(multipartView.get_selection().get_selected (out model, out iter)){
                    model.get (iter, 1, out variableName);
                    HashTable<string,string> tempDataList = Soup.Form.decode(testObjs[id].data);
                    if(tempDataList.contains(variableName)){
                        tempDataList.remove(variableName);
                        testObjs[id].data = Soup.Form.encode_hash(tempDataList);
                        updateMultipartList();
                    }
                    if(testObjs[id].multipartFiles.has_key(variableName)){
                        Gee.TreeMap<string,string> tempMultipartFiles = testObjs[id].multipartFiles;
                        tempMultipartFiles.unset(variableName);
                        testObjs[id].multipartFiles = tempMultipartFiles;
                        updateMultipartList();
                    }
                }
            }
        });

        multipartCell.edited.connect((path, new_text) => {
            Gtk.TreeModel model;
            Gtk.TreeIter iter;
            int id;
            if(testListView.get_selection().get_selected (out model, out iter)){
                model.get (iter, 0, out id);
                string variableName;
                if(multipartView.get_selection().get_selected (out model, out iter)){
                    model.get (iter, 1, out variableName);
                    HashTable<string,string> tempDataList = Soup.Form.decode(testObjs[id].data);
                    if(!tempDataList.contains(new_text) && !testObjs[id].multipartFiles.has_key(new_text)){
                        if(tempDataList.contains(variableName)){
                            tempDataList[new_text] = tempDataList[variableName];
                            tempDataList.remove(variableName);
                            testObjs[id].data = Soup.Form.encode_hash(tempDataList);
                        }else if(testObjs[id].multipartFiles.has_key(variableName)){
                            Gee.TreeMap<string,string> tempMultipartFiles = testObjs[id].multipartFiles;
                            tempMultipartFiles[new_text] = tempMultipartFiles[variableName];
                            tempMultipartFiles.unset(variableName);
                            testObjs[id].multipartFiles = tempMultipartFiles;
                        }
                        
                        updateMultipartList();
                    }
                }
            }
        });

        multipartValueCell.edited.connect((path, new_text) => {
            Gtk.TreeModel model;
            Gtk.TreeIter iter;
            int id;
            if(testListView.get_selection().get_selected (out model, out iter)){
                model.get (iter, 0, out id);
                string variableName;
                if(multipartView.get_selection().get_selected (out model, out iter)){
                    model.get (iter, 1, out variableName);
                    HashTable<string,string> tempDataList = Soup.Form.decode(testObjs[id].data);
                    if(tempDataList.contains(variableName)){
                        tempDataList[variableName] = new_text;
                        testObjs[id].data = Soup.Form.encode_hash(tempDataList);
                    }
                    updateMultipartList();
                }
            }
        });

        multipartValueCell.editing_started.connect((cell) => {
            Gtk.TreeModel model;
            Gtk.TreeIter iter;
            int id;
            if(testListView.get_selection().get_selected (out model, out iter)){
                model.get (iter, 0, out id);
                string variableName;
                if(multipartView.get_selection().get_selected (out model, out iter)){
                    model.get (iter, 1, out variableName);
                    if(testObjs[id].multipartFiles.has_key(variableName)){
                        Gtk.FileChooserDialog chooser = new Gtk.FileChooserDialog (_("Select file to be uploaded"), main_window, Gtk.FileChooserAction.OPEN, _("_Cancel"), Gtk.ResponseType.CANCEL, _("_Open"), Gtk.ResponseType.ACCEPT);
                        if (chooser.run () == Gtk.ResponseType.ACCEPT) {
                            string fname = chooser.get_filename ();
                            Gee.TreeMap<string,string> tempMultipartFiles = testObjs[id].multipartFiles;
                            tempMultipartFiles[variableName] = fname;
                            testObjs[id].multipartFiles = tempMultipartFiles;
                        }

                        chooser.close ();
                        updateMultipartList();
                        cell.editing_done();
                    }
                }
            }
        });*/

        settings.schema.bind ("indent-use-tabs", indentTabSwitch, "state", SettingsBindFlags.DEFAULT);
        settings.schema.changed["indent-use-tabs"].connect (() => {
            outputView.useTabs = !settings.indent_use_tabs;
            inputView.dataEntry.insert_spaces_instead_of_tabs = !settings.indent_use_tabs;
        });

        indentSizeEntry.value_changed.connect(() => {
            settings.indent_width = (int)indentSizeEntry.value;
            outputView.indentWidth = settings.indent_width;
            inputView.dataEntry.tab_width = settings.indent_width;
            inputView.dataEntry.indent_width = settings.indent_width;
        });
    }

    public void action_run_test(){
        errorBar.revealed = false;
        Gtk.TreeModel model;
        Gtk.TreeIter iter;
        int id;
        if(testListView.get_selection().get_selected (out model, out iter)){
            model.get (iter, 0, out id);
            testObjs[id].inProgress = true;
            outputView.updateView(currentTest, outputViewButton);

            var session = new Soup.Session ();
            Soup.Message message;
            if(testObjs[id].requestType == "GET"){
                message = new Soup.Message ("GET", testObjs[id].url);
            }else if(testObjs[id].requestType == "POST"){
                if(testObjs[id].contentType == "multipart/form-data"){
                    // do multipart
                    message = new Soup.Message ("POST", testObjs[id].url);
                    Soup.Multipart multipartObj = new Soup.Multipart("multipart/form-data");
                    Soup.Form.decode(testObjs[id].data).foreach ((key, val) => {
                        multipartObj.append_form_string(key, val);
                    });
                    foreach (var entry in testObjs[id].multipartFiles.entries) {
                        if(entry.value != _("No File")){
                            File file = File.new_for_path (entry.value);
                            try {
                                uint8[] contents;
                                file.load_contents (null, out contents, null);
                                FileInfo info = file.query_info ("*", 0);
                                Soup.Buffer buf = new Soup.Buffer.take (contents);
                                multipartObj.append_form_file(entry.key, file.get_basename(), info.get_content_type(), buf);
                            } catch (Error e) {
                                print ("Error: %s\n", e.message);
                                errorText.label = e.message;
                                errorBar.revealed = true;
                            }
                        }
                    }
                    multipartObj.to_message(message.request_headers, message.request_body);
                }else{
                    message = new Soup.Message ("POST", testObjs[id].url);
                    message.set_request(testObjs[id].contentType, Soup.MemoryUse.COPY, testObjs[id].data.data);
                }
            }else if(testObjs[id].requestType == "PUT"){
                message = new Soup.Message ("PUT", testObjs[id].url);
                message.set_request(testObjs[id].contentType, Soup.MemoryUse.COPY, testObjs[id].data.data);
            }else if(testObjs[id].requestType == "HEAD"){
                message = new Soup.Message ("HEAD", testObjs[id].url);
            }else if(testObjs[id].requestType == "DELETE"){
                message = new Soup.Message ("DELETE", testObjs[id].url);
            }else if(testObjs[id].requestType == "PATCH"){
                message = new Soup.Message ("PATCH", testObjs[id].url);
                message.set_request(testObjs[id].contentType, Soup.MemoryUse.COPY, testObjs[id].data.data);
            }else if(testObjs[id].requestType == "OPTIONS"){
                message = new Soup.Message ("OPTIONS", testObjs[id].url);
            }else{
                message = null;
            }

            if(message == null){
                errorText.label = _("Invalid URL");
                errorBar.revealed = true;
                testObjs[id].inProgress = false;
                outputView.updateView(currentTest, outputViewButton);
            }else{
                foreach (var entry in testObjs[id].requestHeaders.entries) {
                    message.request_headers.append(entry.key, entry.value);
                }

                var start = get_monotonic_time ();
                session.queue_message (message, (sess, mess) => {
                    var end = get_monotonic_time ();
                    testObjs[id].loadTime = Math.round((end - start) / 1000.0)/1000.0;
                    testObjs[id].testStatus = mess.status_code;
                    testObjs[id].output = ((string) mess.response_body.data).make_valid();
                    testObjs[id].inProgress = false;
                    Gee.TreeMap<string,string> responseHeaders = new Gee.TreeMap<string,string>();
                    mess.response_headers.foreach ((name, val) => {
                        responseHeaders[name] = val;
                    });
                    testObjs[id].responseHeaders = responseHeaders;
                    testObjs[id].responseType = mess.response_headers.get_content_type(null);
                    outputView.updateView(currentTest, outputViewButton);
                });
            }
        }
    }

    private void layoutWindow(){
        main_window.add(mainBox);
        mainBox.pack_start(errorBar, false, false, 0);
        Gtk.Container content = errorBar.get_content_area ();
		content.add (errorText);
        mainBox.pack_start(welcome, true, true, 0);
        mainBox.pack_start(mainPane, true, true, 0);
        mainPane.pack2(apiPane, true, false);
        header.pack_start(runTestButton);
        header.pack_start(viewButton);
        header.pack_end(settingsBtn);
        header.pack_end(outputViewButton);
        testListActions.pack_end(newTestButton);
        testListActions.pack_end(deleteTestButton);
        /*inputHeaderActions.pack_end(newInputHeaderButton);
        inputHeaderActions.pack_end(deleteInputHeaderButton);
        urlencodeActions.pack_end(newUrlencodeButton);
        urlencodeActions.pack_end(deleteUrlencodeButton);
        multipartActions.pack_end(newMultipartButton);
        multipartActions.pack_end(newMultipartFileButton);
        multipartActions.pack_end(deleteMultipartButton);*/
        gridLeftPane.attach (testListView, 0, 0, 1, 1);
        gridLeftPane.attach (testListActions, 0, 1, 1, 1);
        mainPane.pack1(gridLeftPane, false, false);
        /*inputBox.pack_start(generalBox, true, true, 0);
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
        inputHeaderBox.pack_start(inputHeaderActions, false, false, 0);*/
        //apiPane.pack1(inputBox, true, false);
        apiPane.pack1(inputView.getRootWidget(), true, false);
        apiPane.pack2(outputView.getRootWidget(), true, false);

        gridLeftPane.set_size_request(180, -1);
        apiPane.set_position((main_window.default_width - 180) / 2);
        layoutSettings.attach (indentTabLabel, 0, 0, 1, 1);
        layoutSettings.attach (indentTabSwitch, 1, 0, 1, 1);
        layoutSettings.attach (indentSizeLabel, 0, 1, 1, 1);
        layoutSettings.attach (indentSizeEntry, 1, 1, 1, 1);
        layoutSettings.show_all();
    }

    /*private void updateInputPane(){
        Gtk.TreeModel model;
        Gtk.TreeIter iter;
        int id;
        if(testListView.get_selection().get_selected (out model, out iter)){
            model.get (iter, 0, out id);
            urlEntry.text = testObjs[id].url;

            if(testObjs[id].requestType == "GET"){
                requestTypePicker.active = 0;
                viewButton.set_item_visible(1, false);
                if(viewButton.selected == 1){
                    viewButton.selected = 0;
                }
                contentLabel.visible = false;
                contentTypePicker.visible = false;
            }else if(testObjs[id].requestType == "POST"){
                requestTypePicker.active = 1;
                viewButton.set_item_visible(1, true);
                contentLabel.visible = true;
                contentTypePicker.visible = true;
            }else if(testObjs[id].requestType == "PUT"){
                requestTypePicker.active = 2;
                viewButton.set_item_visible(1, true);
                contentLabel.visible = true;
                contentTypePicker.visible = true;
            }else if(testObjs[id].requestType == "HEAD"){
                requestTypePicker.active = 3;
                viewButton.set_item_visible(1, false);
                if(viewButton.selected == 1){
                    viewButton.selected = 0;
                }
                contentLabel.visible = false;
                contentTypePicker.visible = false;
            }else if(testObjs[id].requestType == "DELETE"){
                requestTypePicker.active = 4;
                viewButton.set_item_visible(1, false);
                if(viewButton.selected == 1){
                    viewButton.selected = 0;
                }
                contentLabel.visible = false;
                contentTypePicker.visible = false;
            }else if(testObjs[id].requestType == "PATCH"){
                requestTypePicker.active = 5;
                viewButton.set_item_visible(1, true);
                contentLabel.visible = true;
                contentTypePicker.visible = true;
            }else if(testObjs[id].requestType == "OPTIONS"){
                requestTypePicker.active = 6;
                viewButton.set_item_visible(1, false);
                if(viewButton.selected == 1){
                    viewButton.selected = 0;
                }
                contentLabel.visible = false;
                contentTypePicker.visible = false;
            }
            
            if(testObjs[id].contentType == "application/json"){
                contentTypePicker.active = 0;
                dataBuffer.language = langManager.get_language("json");
                dataBuffer.text = testObjs[id].data;
                dataScrolled.visible = true;
                urlencodeScrolled.visible = false;
                urlencodeActions.visible = false;
                multipartScrolled.visible = false;
                multipartActions.visible = false;
            }else if(testObjs[id].contentType == "application/xml"){
                contentTypePicker.active = 1;
                dataBuffer.language = langManager.get_language("xml");
                dataBuffer.text = testObjs[id].data;
                dataScrolled.visible = true;
                urlencodeScrolled.visible = false;
                urlencodeActions.visible = false;
                multipartScrolled.visible = false;
                multipartActions.visible = false;
            }else if(testObjs[id].contentType == "application/x-www-form-urlencoded"){
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

            if(viewButton.selected == 0){
                generalBox.visible = true;
                dataBox.visible = false;
                inputHeaderBox.visible = false;
            }else if(viewButton.selected == 1){
                generalBox.visible = false;
                dataBox.visible = true;
                inputHeaderBox.visible = false;
            }else if(viewButton.selected == 2){
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
    }*/

    private void initialViewState(){
        if(testObjs.size > 0){
            welcome.visible = false;
            mainPane.visible = true;
        }else{
            welcome.visible = true;
            mainPane.visible = false;
        }

        inputView.updatePane();
        outputView.updateView(currentTest, outputViewButton);
    }

    protected override void activate () {
        //testListView = new TestListView();
        inputView = new InputPaneView(this, settings.indent_width, settings.indent_use_tabs);
        outputView = new OutputPaneView(settings.indent_width, settings.indent_use_tabs);
        createElements();

        configureElements();
        layoutWindow();
        setupSignals();

        updateTestList();

        main_window.show_all ();

        initialViewState();
    }

    protected void newTest () {
        try {
            PingTest test = new PingTest();
            testObjs[test.id] = test;
            updateTestList();
            selectListItem(test.id);
            welcome.visible = false;
            mainPane.visible = true;
        } catch (Error e) {
            errorText.label = e.message;
            errorBar.revealed = true;
        }
    }

    public static int main (string[] args) {
        var app = new PingApp ();
        return app.run (args);
    }
}

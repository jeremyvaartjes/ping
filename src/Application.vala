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
    Gtk.Paned mainPane;
    Gtk.Paned apiPane;
    Gtk.HeaderBar header;
    Gtk.Button runTestButton;
    public Granite.Widgets.ModeButton viewButton;
    Granite.Widgets.ModeButton outputViewButton;
    Gtk.TreeView testListView;
    Gtk.CellRendererText testListCell;
    Gtk.Button newTestButton;
    Gtk.Button deleteTestButton;
    Gtk.ActionBar testListActions;
    Gtk.Grid gridLeftPane;
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
    Gtk.TreeIter iter;

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

    private void createElements(){
        main_window = new Gtk.ApplicationWindow (this);
        mainBox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        mainPane = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        apiPane = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        header = new Gtk.HeaderBar();
        runTestButton = new Gtk.Button.from_icon_name("media-playback-start", LARGE_TOOLBAR);
        viewButton = new Granite.Widgets.ModeButton();
        outputViewButton = new Granite.Widgets.ModeButton();
        test_list_store = new Gtk.ListStore (2, typeof (int), typeof (string));
        testListView = new Gtk.TreeView.with_model (test_list_store);
        testListCell = new Gtk.CellRendererText ();
        newTestButton = new Gtk.Button.from_icon_name("list-add-symbolic", Gtk.IconSize.BUTTON);
        deleteTestButton = new Gtk.Button.from_icon_name("list-remove-symbolic", Gtk.IconSize.BUTTON);
        testListActions = new Gtk.ActionBar();
        gridLeftPane = new Gtk.Grid ();
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
        testListView.headers_visible = false;
        testListView.expand = true;
        testListCell.editable = true;
        testListView.insert_column_with_attributes (-1, "Test", testListCell, "text", 1);
        testListActions.get_style_context ().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);
        welcome.append ("document-new", _("Create a Test"), _("Create a HTTP request to send to and API."));
        errorBar.message_type = Gtk.MessageType.ERROR;
        errorBar.revealed = false;
        errorBar.show_close_button = true;
        runTestButton.action_name = ACTION_PREFIX + ACTION_RUN_TEST;
        runTestButton.tooltip_markup = Granite.markup_accel_tooltip (this.get_accels_for_action (runTestButton.action_name), _("Run The Test"));
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
        gridLeftPane.attach (testListView, 0, 0, 1, 1);
        gridLeftPane.attach (testListActions, 0, 1, 1, 1);
        mainPane.pack1(gridLeftPane, false, false);
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

/*
* Copyright (c) 2018 Jeremy Vaartjes <jeremy@vaartj.es>
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.

* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.

* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

public class PingApp : Gtk.Application {

    // Widgets

    Gtk.ApplicationWindow main_window;
    Gtk.Box mainBox;
    Gtk.Box inputBox;
    Gtk.Box generalBox;
    Gtk.Box dataBox;
    Gtk.Box outputBox;
    Gtk.Paned mainPane;
    Gtk.Paned apiPane;
    Gtk.HeaderBar header;
    Gtk.Button runTestButton;
    Granite.Widgets.ModeButton viewButton;
    Gtk.Entry urlEntry;
    Gtk.SourceView outputView;
    Gtk.TreeView testListView;
    Gtk.SourceView dataEntry;
    Gtk.ComboBox requestTypePicker;
    Gtk.ComboBox contentTypePicker;
    Gtk.CellRendererText testListCell;
    Gtk.Button newTestButton;
    Gtk.Button deleteTestButton;
    Gtk.ActionBar testListActions;
    Gtk.Grid gridLeftPane;
    Gtk.Label urlLabel;
    Gtk.Label methodLabel;
    Gtk.Label contentLabel;
    Gtk.Label outputLabel;
    Gtk.ScrolledWindow outputScrolled;
    Granite.Widgets.Welcome welcome;
    Gtk.Spinner outputSpinner;
    Gtk.InfoBar errorBar;
    Gtk.Label errorText;
    Gtk.Statusbar outputStatusBar;

    // Data Storage

    Gee.TreeMap<int, PingTest> testObjs;
    Gtk.ListStore test_list_store;
    Gtk.TreeIter iter;
    Gtk.SourceBuffer outputBuffer;
    Gtk.SourceBuffer dataBuffer;
    Gtk.SourceLanguageManager langManager;
    Gtk.ListStore requestTypes;
    Gtk.TreeIter iterReq;
    Gtk.ListStore contentTypes;
    Gtk.TreeIter iterCont;

    public PingApp () {
        Object (
            application_id: "com.github.jeremyvaartjes.ping",
            flags: ApplicationFlags.FLAGS_NONE
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

        langManager = Gtk.SourceLanguageManager.get_default();
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
        inputBox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        generalBox = new Gtk.Box (Gtk.Orientation.VERTICAL, 10);
        dataBox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        outputBox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        mainPane = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        apiPane = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        header = new Gtk.HeaderBar();
        runTestButton = new Gtk.Button.from_icon_name("media-playback-start", LARGE_TOOLBAR);
        viewButton = new Granite.Widgets.ModeButton();
        outputBuffer = new Gtk.SourceBuffer (null);
        outputView = new Gtk.SourceView.with_buffer (outputBuffer);
        dataBuffer = new Gtk.SourceBuffer (null);
        dataEntry = new Gtk.SourceView.with_buffer (dataBuffer);
        urlEntry = new Gtk.Entry ();
        requestTypes = new Gtk.ListStore (1, typeof (string));
        requestTypePicker = new Gtk.ComboBox.with_model (requestTypes);
        contentTypes = new Gtk.ListStore (1, typeof (string));
        contentTypePicker = new Gtk.ComboBox.with_model (contentTypes);
        test_list_store = new Gtk.ListStore (2, typeof (int), typeof (string));
        testListView = new Gtk.TreeView.with_model (test_list_store);
        testListCell = new Gtk.CellRendererText ();
        newTestButton = new Gtk.Button.from_icon_name("list-add", Gtk.IconSize.BUTTON);
        deleteTestButton = new Gtk.Button.from_icon_name("list-remove", Gtk.IconSize.BUTTON);
        testListActions = new Gtk.ActionBar();
        gridLeftPane = new Gtk.Grid ();
        urlLabel = new Gtk.Label(_("URL"));
        methodLabel = new Gtk.Label(_("Method"));
        contentLabel = new Gtk.Label(_("Content Type"));
        outputScrolled = new Gtk.ScrolledWindow (null, null);
        welcome = new Granite.Widgets.Welcome ("Ping!", _("Start testing your API."));
        outputLabel = new Gtk.Label(_("Test has not been run"));
        outputSpinner = new Gtk.Spinner ();
        errorBar = new Gtk.InfoBar ();
        errorText = new Gtk.Label("");
        outputStatusBar = new Gtk.Statusbar ();
    }

    private void configureElements(){
        main_window.default_height = 550;
        main_window.default_width = 1000;
        main_window.title = "Ping!";
        generalBox.margin = 10;
        header.show_close_button = true;
        header.title = "Ping!";
        main_window.set_titlebar(header);
        viewButton.append_text(_("General"));
        viewButton.append_text(_("Request Body Data"));
        viewButton.set_active(0);
        outputView.wrap_mode = Gtk.WrapMode.WORD;
        outputView.show_line_numbers = true;
        outputView.editable = false;
        dataEntry.expand = true;
        dataEntry.show_line_numbers = true;
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
        //contentTypes.append (out iterCont);
        //contentTypes.set (iterCont, 0, "Form URL Encoded");
        //contentTypes.append (out iterCont);
        //contentTypes.set (iterCont, 0, "Multipart Form");
        Gtk.CellRendererText contentTypeRenderer = new Gtk.CellRendererText ();
        contentTypePicker.pack_start (contentTypeRenderer, true);
        contentTypePicker.add_attribute (contentTypeRenderer, "text", 0);
        contentTypePicker.active = 0;
        testListView.headers_visible = false;
        testListView.expand = true;
        testListCell.editable = true;
        testListView.insert_column_with_attributes (-1, "Test", testListCell, "text", 1);
        testListActions.get_style_context ().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);
        urlLabel.xalign = 0;
        methodLabel.xalign = 0;
        contentLabel.xalign = 0;
        outputScrolled.add(outputView);
        welcome.append ("document-new", _("Create a Test"), _("Create a HTTP request to send to and API."));
        outputSpinner.active = true;
        errorBar.message_type = Gtk.MessageType.ERROR;
        errorBar.revealed = false;
        errorBar.show_close_button = true;
        outputStatusBar.get_style_context ().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);
        outputStatusBar.margin = 0;
    }

    private void setupSignals(){
        viewButton.mode_changed.connect(() => {
            if(viewButton.selected == 0){
                generalBox.visible = true;
                dataBox.visible = false;
            }else if(viewButton.selected == 1){
                generalBox.visible = false;
                dataBox.visible = true;
            }
        });

        dataBuffer.changed.connect(() => {
            Gtk.TreeModel model;
            Gtk.TreeIter iter;
            int id;
            if(testListView.get_selection().get_selected (out model, out iter)){
                model.get (iter, 0, out id);
                testObjs[id].data = dataBuffer.text;
            }
        });

        runTestButton.clicked.connect(() => {
            errorBar.revealed = false;
            Gtk.TreeModel model;
            Gtk.TreeIter iter;
            int id;
            if(testListView.get_selection().get_selected (out model, out iter)){
                model.get (iter, 0, out id);
                testObjs[id].inProgress = true;
                updateOutputPane();

                var session = new Soup.Session ();
                Soup.Message message;
                if(testObjs[id].requestType == "GET"){
                    message = new Soup.Message ("GET", testObjs[id].url);
                }else if(testObjs[id].requestType == "POST"){
                    message = new Soup.Message ("POST", testObjs[id].url);
                    message.set_request(testObjs[id].contentType, Soup.MemoryUse.COPY, dataBuffer.text.data);
                }else if(testObjs[id].requestType == "PUT"){
                    message = new Soup.Message ("PUT", testObjs[id].url);
                    message.set_request(testObjs[id].contentType, Soup.MemoryUse.COPY, dataBuffer.text.data);
                }else if(testObjs[id].requestType == "HEAD"){
                    message = new Soup.Message ("HEAD", testObjs[id].url);
                }else if(testObjs[id].requestType == "DELETE"){
                    message = new Soup.Message ("DELETE", testObjs[id].url);
                }else if(testObjs[id].requestType == "PATCH"){
                    message = new Soup.Message ("PATCH", testObjs[id].url);
                    message.set_request(testObjs[id].contentType, Soup.MemoryUse.COPY, dataBuffer.text.data);
                }else if(testObjs[id].requestType == "OPTIONS"){
                    message = new Soup.Message ("OPTIONS", testObjs[id].url);
                }else{
                    message = null;
                }

                if(message == null){
                    errorText.label = _("Invalid URL");
                    errorBar.revealed = true;
                    testObjs[id].inProgress = false;
                    updateOutputPane();
                }else{
                    var start = get_monotonic_time ();
                    session.queue_message (message, (sess, mess) => {
                        var end = get_monotonic_time ();
                        testObjs[id].loadTime = (end - start) / 1000000.0;
                        testObjs[id].testStatus = mess.status_code;
                        testObjs[id].output = ((string) mess.response_body.data).make_valid();
                        testObjs[id].inProgress = false;
                        /*mess.response_headers.foreach ((name, val) => {
                            print ("%s = %s\n", name, val);
                        });*/
                        updateOutputPane();
                    });
                }
            }
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
            if (testListView.get_selection().get_selected (out model, out iter)) {
                model.get (iter, 0, out id);
                urlEntry.text = testObjs[id].url;

                if(testObjs[id].requestType == "GET"){
                    requestTypePicker.active = 0;
                    viewButton.visible = false;
                }else if(testObjs[id].requestType == "POST"){
                    requestTypePicker.active = 1;
                    viewButton.visible = true;
                }else if(testObjs[id].requestType == "PUT"){
                    requestTypePicker.active = 2;
                    viewButton.visible = true;
                }else if(testObjs[id].requestType == "HEAD"){
                    requestTypePicker.active = 3;
                    viewButton.visible = false;
                }else if(testObjs[id].requestType == "DELETE"){
                    requestTypePicker.active = 4;
                    viewButton.visible = false;
                }else if(testObjs[id].requestType == "PATCH"){
                    requestTypePicker.active = 5;
                    viewButton.visible = true;
                }else if(testObjs[id].requestType == "OPTIONS"){
                    requestTypePicker.active = 6;
                    viewButton.visible = false;
                }
                dataBuffer.text = testObjs[id].data;
                if(testObjs[id].contentType == "application/json"){
                    contentTypePicker.active = 0;
                    dataBuffer.language = langManager.get_language("json");
                }else if(testObjs[id].contentType == "application/xml"){
                    contentTypePicker.active = 1;
                    dataBuffer.language = langManager.get_language("xml");
                }else if(testObjs[id].contentType == "application/x-www-form-urlencoded"){
                    contentTypePicker.active = 2;
                    dataBuffer.language = null;
                }else{
                    contentTypePicker.active = 3;
                    dataBuffer.language = null;
                }

                updateOutputPane();
            }
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
                testObjs[id].remove();
                testObjs.unset(id);
                updateTestList();
                if(testObjs.size == 0){
                    welcome.visible = true;
                    mainPane.visible = false;
                }
            }
        });

        urlEntry.changed.connect(() => {
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

        requestTypePicker.changed.connect(() => {
            Gtk.TreeModel model;
            Gtk.TreeIter iter;
            int id;
            if(testListView.get_selection().get_selected (out model, out iter)){
                model.get (iter, 0, out id);
                if(requestTypePicker.active == 0){
                    testObjs[id].requestType = "GET";
                    contentLabel.visible = false;
                    contentTypePicker.visible = false;
                    viewButton.visible = false;
                }else if(requestTypePicker.active == 1){
                    testObjs[id].requestType = "POST";
                    contentLabel.visible = true;
                    contentTypePicker.visible = true;
                    viewButton.visible = true;
                }else if(requestTypePicker.active == 2){
                    testObjs[id].requestType = "PUT";
                    contentLabel.visible = true;
                    contentTypePicker.visible = true;
                    viewButton.visible = true;
                }else if(requestTypePicker.active == 3){
                    testObjs[id].requestType = "HEAD";
                    contentLabel.visible = false;
                    contentTypePicker.visible = false;
                    viewButton.visible = false;
                }else if(requestTypePicker.active == 4){
                    testObjs[id].requestType = "DELETE";
                    contentLabel.visible = false;
                    contentTypePicker.visible = false;
                    viewButton.visible = false;
                }else if(requestTypePicker.active == 5){
                    testObjs[id].requestType = "PATCH";
                    contentLabel.visible = true;
                    contentTypePicker.visible = true;
                    viewButton.visible = true;
                }else{
                    testObjs[id].requestType = "OPTIONS";
                    contentLabel.visible = false;
                    contentTypePicker.visible = false;
                    viewButton.visible = false;
                }
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
                    dataBuffer.language = langManager.get_language("json");
                }else if(contentTypePicker.active == 1){
                    testObjs[id].contentType = "application/xml";
                    dataBuffer.language = langManager.get_language("xml");
                }else if(contentTypePicker.active == 2){
                    testObjs[id].contentType = "application/x-www-form-urlencoded";
                    dataBuffer.language = null;
                }else{
                    testObjs[id].contentType = "multipart/form-data";
                    dataBuffer.language = null;
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
        testListActions.pack_end(newTestButton);
        testListActions.pack_end(deleteTestButton);
        gridLeftPane.attach (testListView, 0, 0, 1, 1);
        gridLeftPane.attach (testListActions, 0, 1, 1, 1);
        mainPane.pack1(gridLeftPane, false, false);
        inputBox.pack_start(generalBox, true, true, 0);
        inputBox.pack_start(dataBox, true, true, 0);
        generalBox.pack_start(urlLabel, false, false, 0);
        generalBox.pack_start(urlEntry, false, false, 0);
        generalBox.pack_start(methodLabel, false, false, 0);
        generalBox.pack_start(requestTypePicker, false, false, 0);
        generalBox.pack_start(contentLabel, false, false, 0);
        generalBox.pack_start(contentTypePicker, false, false, 0);
        dataBox.pack_start(dataEntry, true, true, 0);
        outputBox.pack_start(outputLabel, true, true, 0);
        outputBox.pack_start(outputSpinner, true, false, 0);
        outputBox.pack_start(outputScrolled, true, true, 0);
        outputBox.pack_start(outputStatusBar, false, false, 0);
        apiPane.pack1(inputBox, true, false);
        apiPane.pack2(outputBox, true, false);

        gridLeftPane.set_size_request(180, -1);
        apiPane.set_position((main_window.default_width - 180) / 2);
    }

    private void updateOutputPane(){
        Gtk.TreeModel model;
        Gtk.TreeIter iter;
        int id;
        if(testListView.get_selection().get_selected (out model, out iter)){
            model.get (iter, 0, out id);
            if(testObjs[id].inProgress){
                outputScrolled.visible = false;
                outputSpinner.visible = true;
                outputLabel.visible = false;
                outputStatusBar.visible = false;
            }else{
                if(testObjs[id].testStatus == 0){
                    outputScrolled.visible = false;
                    outputSpinner.visible = false;
                    outputLabel.visible = true;
                    outputStatusBar.visible = false;
                }else{
                    outputBuffer.text = testObjs[id].output;
                    outputScrolled.visible = true;
                    outputSpinner.visible = false;
                    outputLabel.visible = false;
                    outputStatusBar.visible = true;
                    outputStatusBar.remove_all(1);
                    outputStatusBar.push(1, _("HTTP Status") + " " + testObjs[id].testStatus.to_string() + " | " + _("Time") + " " + testObjs[id].loadTime.to_string() + "s");
                }
            }
        }else{
            outputScrolled.visible = false;
            outputSpinner.visible = false;
            outputLabel.visible = false;
            outputStatusBar.visible = false;
        }
    }

    private void initialViewState(){
        if(testObjs.size > 0){
            welcome.visible = false;
            mainPane.visible = true;
        }else{
            welcome.visible = true;
            mainPane.visible = false;
        }
        generalBox.visible = true;
        dataBox.visible = false;

        if(requestTypePicker.active == 0){
            contentLabel.visible = false;
            contentTypePicker.visible = false;
            viewButton.visible = false;
        }else if(requestTypePicker.active == 1){
            contentLabel.visible = true;
            contentTypePicker.visible = true;
            viewButton.visible = true;
        }else if(requestTypePicker.active == 2){
            contentLabel.visible = true;
            contentTypePicker.visible = true;
            viewButton.visible = true;
        }else if(requestTypePicker.active == 3){
            contentLabel.visible = false;
            contentTypePicker.visible = false;
            viewButton.visible = false;
        }else if(requestTypePicker.active == 4){
            contentLabel.visible = false;
            contentTypePicker.visible = false;
            viewButton.visible = false;
        }else if(requestTypePicker.active == 5){
            contentLabel.visible = true;
            contentTypePicker.visible = true;
            viewButton.visible = true;
        }else{
            contentLabel.visible = false;
            contentTypePicker.visible = false;
            viewButton.visible = false;
        }

        updateOutputPane();
    }

    protected override void activate () {
        createElements();

        configureElements();
        layoutWindow();
        setupSignals();

        updateTestList();

        main_window.show_all ();

        initialViewState();
    }

    protected void newTest () {
        PingTest test = new PingTest();
        testObjs[test.id] = test;
        updateTestList();
        selectListItem(test.id);
        welcome.visible = false;
        mainPane.visible = true;
    }

    public static int main (string[] args) {
        var app = new PingApp ();
        return app.run (args);
    }
}

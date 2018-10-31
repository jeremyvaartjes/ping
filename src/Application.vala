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

    Gee.TreeMap<int, PingTest> testObjs;
    Gtk.ListStore test_list_store;
    Gtk.TreeView testListView;
    Gtk.TreeIter iter;
    Gtk.Entry urlEntry;
    Gtk.SourceView outputView;
    Gtk.SourceBuffer outputBuffer;
    Gtk.SourceBuffer dataBuffer;
    Gtk.SourceLanguageManager langManager;

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

    protected override void activate () {
        var main_window = new Gtk.ApplicationWindow (this);
        main_window.default_height = 550;
        main_window.default_width = 1000;
        main_window.title = "Ping!";

        Gtk.Box inputBox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        Gtk.Box generalBox = new Gtk.Box (Gtk.Orientation.VERTICAL, 10);
        generalBox.margin = 10;
        Gtk.Box dataBox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

        var mainPane = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        var apiPane = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        main_window.add(mainPane);
        mainPane.pack2(apiPane, true, false);

        var header = new Gtk.HeaderBar();
        header.show_close_button = true;
        header.title = "Ping!";
        main_window.set_titlebar(header);

        //var newTestButton = new Gtk.Button.from_icon_name("document-new", LARGE_TOOLBAR);
        //header.pack_start(newTestButton);
        var runTestButton = new Gtk.Button.from_icon_name("media-playback-start", LARGE_TOOLBAR);
        header.pack_start(runTestButton);
        var viewButton = new Granite.Widgets.ModeButton();
        viewButton.append_text("General");
        viewButton.append_text("Post Data");
        header.pack_start(viewButton);
        viewButton.mode_changed.connect(() => {
            if(viewButton.selected == 0){
                generalBox.visible = true;
                dataBox.visible = false;
            }else if(viewButton.selected == 1){
                generalBox.visible = false;
                dataBox.visible = true;
            }
        });
        viewButton.set_active(0);

        outputBuffer = new Gtk.SourceBuffer (null);
        outputView = new Gtk.SourceView.with_buffer (outputBuffer);
        outputView.wrap_mode = Gtk.WrapMode.WORD;
        outputView.show_line_numbers = true;
        outputView.editable = false;

        dataBuffer = new Gtk.SourceBuffer (null);
        var dataEntry = new Gtk.SourceView.with_buffer (dataBuffer);
        dataEntry.expand = true;
        dataEntry.show_line_numbers = true;

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
            Gtk.TreeModel model;
            Gtk.TreeIter iter;
            int id;
            if(testListView.get_selection().get_selected (out model, out iter)){
                model.get (iter, 0, out id);
                var session = new Soup.Session ();
                Soup.Message message;
                if(testObjs[id].requestType == "POST"){
                    message = new Soup.Message ("POST", testObjs[id].url);
                    message.set_request(testObjs[id].contentType, Soup.MemoryUse.COPY, dataBuffer.text.data);
                }else{
                    message = new Soup.Message ("GET", testObjs[id].url);
                }

                session.send_message (message);
                testObjs[id].output = ((string) message.response_body.data).make_valid();
                outputBuffer.text = testObjs[id].output;
            }
        });


        urlEntry = new Gtk.Entry ();

        Gtk.ListStore requestTypes = new Gtk.ListStore (1, typeof (string));
		Gtk.TreeIter iterReq;
		requestTypes.append (out iterReq);
		requestTypes.set (iterReq, 0, "GET");
		requestTypes.append (out iterReq);
		requestTypes.set (iterReq, 0, "POST");
        Gtk.ComboBox requestTypePicker = new Gtk.ComboBox.with_model (requestTypes);
        Gtk.CellRendererText requestTypeRenderer = new Gtk.CellRendererText ();
		requestTypePicker.pack_start (requestTypeRenderer, true);
		requestTypePicker.add_attribute (requestTypeRenderer, "text", 0);
		requestTypePicker.active = 0;

		Gtk.ListStore contentTypes = new Gtk.ListStore (1, typeof (string));
		Gtk.TreeIter iterCont;
		contentTypes.append (out iterCont);
		contentTypes.set (iterCont, 0, "JSON");
		contentTypes.append (out iterCont);
		contentTypes.set (iterCont, 0, "XML");
		contentTypes.append (out iterCont);
		contentTypes.set (iterCont, 0, "Form URL Encoded");
		contentTypes.append (out iterCont);
		contentTypes.set (iterCont, 0, "Multipart Form");
        Gtk.ComboBox contentTypePicker = new Gtk.ComboBox.with_model (contentTypes);
        Gtk.CellRendererText contentTypeRenderer = new Gtk.CellRendererText ();
		contentTypePicker.pack_start (contentTypeRenderer, true);
		contentTypePicker.add_attribute (contentTypeRenderer, "text", 0);
		contentTypePicker.active = 0;

        test_list_store = new Gtk.ListStore (2, typeof (int), typeof (string));
        testListView = new Gtk.TreeView.with_model (test_list_store);
        testListView.headers_visible = false;
        testListView.expand = true;
        var cell = new Gtk.CellRendererText ();
        cell.editable = true;
        cell.edited.connect((path, new_text) => {
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
        testListView.insert_column_with_attributes (-1, "Test", cell, "text", 1);
        testListView.get_selection().changed.connect(() => {
            Gtk.TreeModel model;
            Gtk.TreeIter iter;
            int id;
            if (testListView.get_selection().get_selected (out model, out iter)) {
                model.get (iter, 0, out id);
                urlEntry.text = testObjs[id].url;
                outputBuffer.text = testObjs[id].output;
                if(testObjs[id].requestType == "GET"){
                    requestTypePicker.active = 0;
                }else if(testObjs[id].requestType == "POST"){
                    requestTypePicker.active = 1;
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
            }
        });

        updateTestList();

        var newTestButton = new Gtk.Button.from_icon_name("list-add", Gtk.IconSize.BUTTON);
        var deleteTestButton = new Gtk.Button.from_icon_name("list-remove", Gtk.IconSize.BUTTON);
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
            }
        });

        var testListActions = new Gtk.ActionBar();
        testListActions.get_style_context ().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);
        testListActions.pack_end(newTestButton);
        testListActions.pack_end(deleteTestButton);

        var gridLeftPane = new Gtk.Grid ();
        gridLeftPane.attach (testListView, 0, 0, 1, 1);
        gridLeftPane.attach (testListActions, 0, 1, 1, 1);

        mainPane.pack1(gridLeftPane, false, false);

        /*testNameEntry.changed.connect(() => {
            Gtk.TreeModel model;
            Gtk.TreeIter iter;
            int id;
            if(testListView.get_selection().get_selected (out model, out iter)){
                model.get (iter, 0, out id);
                if(testObjs[id].name != testNameEntry.text){
                    testObjs[id].name = testNameEntry.text;
                    updateTestList();
                    selectListItem(id);
                }
            }
        });*/
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

        var urlLabel = new Gtk.Label("URL");
        urlLabel.xalign = 0;
        var methodLabel = new Gtk.Label("Method");
        methodLabel.xalign = 0;
        var contentLabel = new Gtk.Label("Content Type");
        contentLabel.xalign = 0;

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
                }else{
                    testObjs[id].requestType = "POST";
                    contentLabel.visible = true;
                    contentTypePicker.visible = true;
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

        Gtk.ScrolledWindow outputScrolled = new Gtk.ScrolledWindow (null, null);
        outputScrolled.add(outputView);

        inputBox.pack_start(generalBox, true, true, 0);
        inputBox.pack_start(dataBox, true, true, 0);
        generalBox.pack_start(urlLabel, false, false, 0);
        generalBox.pack_start(urlEntry, false, false, 0);
        generalBox.pack_start(methodLabel, false, false, 0);
        generalBox.pack_start(requestTypePicker, false, false, 0);
        generalBox.pack_start(contentLabel, false, false, 0);
        generalBox.pack_start(contentTypePicker, false, false, 0);
        dataBox.pack_start(dataEntry, true, true, 0);
        apiPane.pack1(inputBox, true, false);
        apiPane.pack2(outputScrolled, true, false);
        
        gridLeftPane.set_size_request(180, -1);
        apiPane.set_position((main_window.default_width - 180) / 2);

        main_window.show_all ();

        generalBox.visible = true;
        dataBox.visible = false;
        if(requestTypePicker.active == 0){
            contentLabel.visible = false;
            contentTypePicker.visible = false;
        }else{
            contentLabel.visible = true;
            contentTypePicker.visible = true;
        }
    }

    protected void newTest () {
        PingTest test = new PingTest();
        testObjs[test.id] = test;
        updateTestList();
        selectListItem(test.id);
    }

    public static int main (string[] args) {
        var app = new PingApp ();
        return app.run (args);
    }
}

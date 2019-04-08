class OutputPaneView {
    Gtk.ScrolledWindow headerScroller;
    Gtk.ScrolledWindow rawScroller;
    Gtk.Statusbar statusBar;
    Gtk.Spinner statusSpinner;
    Gtk.Label statusLabel;
    Gtk.TreeView headerView;
    Gtk.SourceView rawView;
    Gtk.SourceBuffer rawViewBuffer;
    Gtk.Box outputBox;
    Gtk.ListStore headerListStore;
    
    private bool _useTabs;
    private int _indentWidth;
    public bool useTabs {
        get {
            return _useTabs;
        }
        set {
            _useTabs = value;
            rawView.insert_spaces_instead_of_tabs = !_useTabs;
        }
    }
    public int indentWidth {
        get {
            return _indentWidth;
        }
        set {
            _indentWidth = value;
            rawView.tab_width = _indentWidth;
            rawView.indent_width = _indentWidth;
        }
    }

    public OutputPaneView(int indentWidth, bool useTabs){
        _useTabs = useTabs;
        _indentWidth = indentWidth;

        rawViewBuffer = new Gtk.SourceBuffer (null);
        rawView = new Gtk.SourceView.with_buffer (rawViewBuffer);
        rawView.wrap_mode = Gtk.WrapMode.WORD_CHAR;
        rawView.show_line_numbers = true;
        rawView.editable = false;
        rawView.monospace = true;
        rawView.tab_width = _indentWidth;
        rawView.indent_width = _indentWidth;
        rawView.insert_spaces_instead_of_tabs = _useTabs;

        Gtk.SourceStyleSchemeManager sourceSchemeMan = Gtk.SourceStyleSchemeManager.get_default();
        Gtk.SourceStyleScheme sourceTheme = sourceSchemeMan.get_scheme("solarized-light");
        rawViewBuffer.style_scheme = sourceTheme;

        headerListStore = new Gtk.ListStore (2, typeof (string), typeof (string));
        headerView = new Gtk.TreeView.with_model (headerListStore);
        var headerListCell = new Gtk.CellRendererText ();
        headerView.expand = true;
        headerView.insert_column_with_attributes (-1, _("Header"), headerListCell, "text", 0);
        headerView.insert_column_with_attributes (-1, _("Value"), headerListCell, "text", 1);
        
        rawScroller = new Gtk.ScrolledWindow (null, null);
        headerScroller = new Gtk.ScrolledWindow (null, null);
        rawScroller.add(rawView);
        headerScroller.add(headerView);

        statusLabel = new Gtk.Label(_("Test has not been run"));

        statusSpinner = new Gtk.Spinner ();
        statusSpinner.active = true;

        statusBar = new Gtk.Statusbar ();
        statusBar.get_style_context ().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);
        statusBar.margin = 0;

        outputBox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        outputBox.pack_start(statusLabel, true, true, 0);
        outputBox.pack_start(statusSpinner, true, false, 0);
        outputBox.pack_start(rawScroller, true, true, 0);
        outputBox.pack_start(headerScroller, true, true, 0);
        outputBox.pack_start(statusBar, false, false, 0);
    }

    public void updateView(PingTest* currentTest, Granite.Widgets.ModeButton viewSwitcherBtn){
        if(currentTest != null){
            if(currentTest->inProgress){
                headerScroller.visible = false;
                rawScroller.visible = false;
                statusSpinner.visible = true;
                statusLabel.visible = false;
                statusBar.visible = false;
                viewSwitcherBtn.visible = false;
            }else{
                if(currentTest->testStatus == 0){
                    headerScroller.visible = false;
                    rawScroller.visible = false;
                    statusSpinner.visible = false;
                    statusLabel.visible = true;
                    statusBar.visible = false;
                    viewSwitcherBtn.visible = false;
                }else{
                    Gtk.TreeIter iter;
                    headerListStore.clear();
                    foreach (var entry in currentTest->responseHeaders.entries) {
                        headerListStore.append (out iter);
                        headerListStore.set (iter, 0, entry.key, 1, entry.value);
                    }
                    headerView.set_model(headerListStore);

                    rawViewBuffer.text = currentTest->output;
                    if(currentTest->responseType == "application/json"){
                        Json.Node json;
                        Json.Generator generator = new Json.Generator ();
                        generator.pretty = true;
                        if(_useTabs){
                            generator.indent_char = '\t';
                            generator.indent = 1;
                        }else{
                            generator.indent_char = ' ';
                            generator.indent = _indentWidth;
                        }
                        
                        try {
                            json = Json.from_string(rawViewBuffer.text);
                            generator.root = json;
                            rawViewBuffer.text = generator.to_data(null);
                        } catch (Error e) {
                            stdout.printf ("Unable to parse the string: %s\n", e.message);
                        }
                    }
                    if(viewSwitcherBtn.selected == 0){
                        rawScroller.visible = true;
                        headerScroller.visible = false;
                    }else{
                        rawScroller.visible = false;
                        headerScroller.visible = true;
                    }
                    statusSpinner.visible = false;
                    statusLabel.visible = false;
                    statusBar.visible = true;
                    viewSwitcherBtn.visible = true;
                    statusBar.remove_all(1);
                    statusBar.push(1, _("HTTP Status") + " " + currentTest->testStatus.to_string() + " | " + _("Time") + " " + "%.3f".printf(currentTest->loadTime) + "s");
                }
            }
        }else{
            headerScroller.visible = false;
            rawScroller.visible = false;
            statusSpinner.visible = false;
            statusLabel.visible = false;
            statusBar.visible = false;
            viewSwitcherBtn.visible = false;
        }
    }

    public Gtk.Widget getRootWidget(){
        return outputBox;
    }
}
/*
 *                   __ 
 *   _____ _        |  |
 *  |  _  |_|___ ___|  |
 *  |   __| |   | . |__|
 *  |__|  |_|_|_|_  |__|
 *              |___|   
 *         Version 0.3.0
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

public class PingTest {

    private string _name;
    private int _id;
    private string _url;
    private string _output;
    private string _requestType;
    private string _data;
    private string _contentType;
    private uint _testStatus;
    private bool _inProgress;
    private double _loadTime;
    private Gee.TreeMap<string,string> _responseHeaders;
    private Gee.TreeMap<string,string> _requestHeaders;

    public string name {
        get { return _name; }
        set {
            var file = File.new_for_path(Environment.get_user_data_dir() + "/com.github.jeremyvaartjes.ping/tests/" + _id.to_string());
            if (file.query_exists ()){
                _name = value;
                this.outputToFile();
            }
        }
    }

    public string url {
        get { return _url; }
        set {
            var file = File.new_for_path(Environment.get_user_data_dir() + "/com.github.jeremyvaartjes.ping/tests/" + _id.to_string());
            if (file.query_exists ()){
                _url = value;
                this.outputToFile();
            }
        }
    }

    public string requestType {
        get { return _requestType; }
        set {
            var file = File.new_for_path(Environment.get_user_data_dir() + "/com.github.jeremyvaartjes.ping/tests/" + _id.to_string());
            if (file.query_exists ()){
                _requestType = value;
                this.outputToFile();
            }
        }
    }

    public string data {
        get { return _data; }
        set {
            var file = File.new_for_path(Environment.get_user_data_dir() + "/com.github.jeremyvaartjes.ping/tests/" + _id.to_string());
            if (file.query_exists ()){
                _data = value;
                this.outputToFile();
            }
        }
    }

    public string contentType {
        get { return _contentType; }
        set {
            var file = File.new_for_path(Environment.get_user_data_dir() + "/com.github.jeremyvaartjes.ping/tests/" + _id.to_string());
            if (file.query_exists ()){
                _contentType = value;
                this.outputToFile();
            }
        }
    }

    public int id { get { return _id; } }
    public string output { get { return _output; } set { _output = value; } }
    public uint testStatus { get { return _testStatus; } set { _testStatus = value; } }
    public bool inProgress { get { return _inProgress; } set { _inProgress = value; } }
    public double loadTime { get { return _loadTime; } set { _loadTime = value; } }
    public Gee.TreeMap<string,string> responseHeaders { get { return _responseHeaders; } set { _responseHeaders = value; } }
    public Gee.TreeMap<string,string> requestHeaders {
        get { return _requestHeaders; }
        set {
            var file = File.new_for_path(Environment.get_user_data_dir() + "/com.github.jeremyvaartjes.ping/tests/" + _id.to_string());
            if (file.query_exists ()){
                _requestHeaders = value;
                this.outputToFile();
            }
        }
    }

    public PingTest () throws Error{
        var counter = 1;
        var done = false;
        while(!done){
            var file = File.new_for_path(Environment.get_user_data_dir() + "/com.github.jeremyvaartjes.ping/tests/" + counter.to_string());
            if (!file.query_exists ()){
                var dir = File.new_for_path(Environment.get_user_data_dir() + "/com.github.jeremyvaartjes.ping/tests");
                if (!dir.query_exists ()){
                    dir.make_directory_with_parents ();
                }

                file.create(FileCreateFlags.NONE);

                _id = counter;
                _name = _("New API Test");
                _url = "";
                _output = "";
                _testStatus = 0;
                _requestType = "GET";
                _data = "";
                _contentType = "application/json";
                _inProgress = false;
                _loadTime = 0;
                _responseHeaders = new Gee.TreeMap<string,string>();
                _requestHeaders = new Gee.TreeMap<string,string>();
                this.outputToFile();
                done = true;
            } else {
                counter++;
            }
        }
    }

    public PingTest.load(int id) throws IOError {
        var file = File.new_for_path(Environment.get_user_data_dir() + "/com.github.jeremyvaartjes.ping/tests/" + id.to_string());
        if (!file.query_exists ()){
            throw new IOError.NOT_FOUND(_("Cannot load file: ") + id.to_string());
        } else {
            _id = id;
            Json.Parser parser = new Json.Parser ();
            parser.load_from_file (Environment.get_user_data_dir() + "/com.github.jeremyvaartjes.ping/tests/" + id.to_string());
            Json.Node node = parser.get_root ();
            Json.Object obj = node.get_object ();
            _name = obj.get_string_member ("name");
            _url = obj.get_string_member ("url");
            _requestType = obj.get_string_member ("requestType");
            _data = obj.get_string_member ("data");
            _contentType = obj.get_string_member ("contentType");
            _output = "";
            _testStatus = 0;
            _inProgress = false;
            _loadTime = 0;
            _responseHeaders = new Gee.TreeMap<string,string>();
            _requestHeaders = new Gee.TreeMap<string,string>();
            Json.Object headerObj = obj.get_object_member("headers");
            foreach (string name in headerObj.get_members ()) {
                _requestHeaders[name] = headerObj.get_string_member (name);
            }
        }
    }

    public bool remove() {
        var dir = File.new_for_path(Environment.get_user_data_dir() + "/com.github.jeremyvaartjes.ping/tests");
        if (!dir.query_exists ()){
            return false;
        }else{
            var file = File.new_for_path(Environment.get_user_data_dir() + "/com.github.jeremyvaartjes.ping/tests/" + _id.to_string());
            if (!file.query_exists ()){
                return false;
            }else{
                try{
                    file.delete();
                } catch (Error e) {
                    print ("Error: %s\n", e.message);
                    return false;
                }
            }
        }
        return true;
    }

    public static Gee.ArrayList<int> getListOfTests(){
        var list = new Gee.ArrayList<int>();
        try {
            string directory = Environment.get_user_data_dir() + "/com.github.jeremyvaartjes.ping/tests";
            Dir dir = Dir.open (directory, 0);
            string? name = null;

            while ((name = dir.read_name ()) != null) {
                string path = Path.build_filename (directory, name);

                if (FileUtils.test (path, FileTest.IS_REGULAR)) {
                    list.add(int.parse(name));
                }
            }
        } catch (FileError err) {
            stderr.printf (err.message);
        }

        return list;
    }

    private void outputToFile() throws Error{
        Json.Builder builder = new Json.Builder ();

        builder.begin_object ();
        builder.set_member_name ("name");
        builder.add_string_value (_name);
        builder.set_member_name ("url");
        builder.add_string_value (_url);
        builder.set_member_name ("requestType");
        builder.add_string_value (_requestType);
        builder.set_member_name ("data");
        builder.add_string_value (_data);
        builder.set_member_name ("contentType");
        builder.add_string_value (_contentType);
        builder.set_member_name ("headers");
        builder.begin_object ();
        foreach (var entry in _requestHeaders.entries) {
            builder.set_member_name (entry.key);
            builder.add_string_value (entry.value);
        }
        builder.end_object ();
        builder.end_object ();

        Json.Generator generator = new Json.Generator ();
        Json.Node root = builder.get_root ();
        generator.set_root (root);
        generator.to_file(Environment.get_user_data_dir() + "/com.github.jeremyvaartjes.ping/tests/" + _id.to_string());
    }
}

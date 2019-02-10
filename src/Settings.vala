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

public class Settings : Granite.Services.Settings {

    public int indent_width { get; set; }
    public bool indent_use_tabs { get; set; }

    public Settings ()  {
        base ("com.github.jeremyvaartjes.ping.settings");
    }
}
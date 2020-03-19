/*
* Copyright 2015-2020 elementary, Inc. (https://elementary.io)
*           2019-2020 Ryo Nakano
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

public class InputMethod.Widgets.EngineButton : Wingpanel.Widgets.Container {
    public string code { get; construct; }
    public string full_name { get; construct; }
    public uint32 id { get; construct; }
    public EngineButton? engine_button { get; construct; }
    public Gtk.RadioButton radio_button { get; private set; }

    public EngineButton (string code, string full_name, uint32 id, EngineButton? engine_button) {
        Object (
            code: code,
            full_name: full_name,
            id: id,
            engine_button: engine_button
        );
    }

    construct {
        radio_button = new Gtk.RadioButton.with_label_from_widget ((engine_button != null) ? engine_button.radio_button : null, full_name);
        radio_button.active = (id == 0);
        radio_button.margin_start = 6;
        get_content_widget ().add (radio_button);

        this.clicked.connect (() => {
            try {
                Process.spawn_command_line_sync ("ibus engine %s".printf (code));
                radio_button.active = !radio_button.active;
            } catch (SpawnError err) {
                warning (err.message);
            }
        });
    }
}

/*
* Copyright 2015-2019 elementary, Inc. (https://elementary.io)
*           2019 Ryo Nakano
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

public class InputMethod.Widgets.LayoutButton : Wingpanel.Widgets.Container {
    public uint32 id;
    public string code;
    public string? variant;
    public Gtk.RadioButton radio_button { private set; public get; }

    public LayoutButton (string caption, string code, string? variant, uint32 id, GLib.Settings settings, LayoutButton? layout_button) {
        radio_button = new Gtk.RadioButton.with_label_from_widget ((layout_button != null) ? layout_button.radio_button : null, caption);
        radio_button.active = (id == 0);
        radio_button.margin_start = 6;
        get_content_widget ().add (radio_button);

        this.id = id;
        this.code = code;
        this.variant = variant;

        this.clicked.connect (() => {
            // TODO: Support switching engines
            //  settings.set_strv ("preload-engines", id);
        });

        settings.changed["preload-engines"].connect (() => {
            if (id == 0) {
                radio_button.active = true;
            }
        });
    }
}

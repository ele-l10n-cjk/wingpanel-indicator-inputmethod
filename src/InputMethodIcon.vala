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

public class InputMethod.Widgets.InputMethodIcon : Gtk.Label {
    construct {
        margin = 2;
        set_size_request (20, 20);
        halign = Gtk.Align.CENTER;
        valign = Gtk.Align.CENTER;

        var provider = new Gtk.CssProvider ();
        provider.load_from_resource ("/io/elementary/desktop/wingpanel/inputmethod/InputMethodIcon.css");

        var style_context = get_style_context ();
        style_context.add_class ("inputmethod-icon");
        style_context.add_provider (provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
    }
}

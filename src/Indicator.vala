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

public class InputMethod.Indicator : Wingpanel.Indicator {
    private Gtk.Grid main_grid;
    private InputMethod.Widgets.InputMethodIcon display_icon;
    private InputMethod.Widgets.LayoutManager layouts;

    public Indicator () {
        Object (code_name: "input-method-indicator",
                display_name: _("Input Method"),
                description:_("The input method indicator"));
    }

    public override Gtk.Widget get_display_widget () {
        if (display_icon == null) {
            display_icon = new InputMethod.Widgets.InputMethodIcon ();
            display_icon.button_press_event.connect ((e) => {
                if (e.button == Gdk.BUTTON_MIDDLE) {
                    layouts.next ();
                    return Gdk.EVENT_STOP;
                }
                return Gdk.EVENT_PROPAGATE;
            });

            layouts = new InputMethod.Widgets.LayoutManager ();
            layouts.updated.connect (() => {
                display_icon.label = layouts.get_current (true);
                var new_visibility = layouts.has_layouts ();
                if (new_visibility != visible) {
                    visible = new_visibility;
                }
            });

            layouts.updated ();

            var ibus_panel_settings = new Settings ("org.freedesktop.ibus.panel");
            ibus_panel_settings.bind ("show-icon-on-systray", this, "visible", SettingsBindFlags.DEFAULT);
        }

        return display_icon;
    }

    public override Gtk.Widget? get_widget () {
        if (main_grid == null) {
            main_grid = new Gtk.Grid ();
            main_grid.set_orientation (Gtk.Orientation.VERTICAL);

            var separator = new Wingpanel.Widgets.Separator ();

            var settings_button = new Gtk.ModelButton ();
            settings_button.text = _("Input Method Settings…");
            settings_button.clicked.connect (show_settings);

            main_grid.add (layouts);
            main_grid.add (separator);
            main_grid.add (settings_button);
            main_grid.show_all ();
        }

        return main_grid;
    }

    public override void opened () {}

    public override void closed () {}

    private void show_settings () {
        close ();

        try {
            AppInfo.launch_default_for_uri ("settings://input/keyboard/layout", null);
        } catch (Error e) {
            warning ("%s\n", e.message);
        }
    }
}

public Wingpanel.Indicator? get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) {
    // We don't need input methods in Greeter
    if (server_type != Wingpanel.IndicatorManager.ServerType.SESSION) {
        return null;
    }

    debug ("Activating InputMethod Indicator");
    var indicator = new InputMethod.Indicator ();
    return indicator;
}
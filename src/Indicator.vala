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

public class InputMethod.Indicator : Wingpanel.Indicator {
    private Gtk.Grid main_grid;
    private InputMethod.Widgets.InputMethodIcon display_icon;
    private InputMethod.Widgets.EngineManager engines;

    public Indicator () {
        Object (code_name: "input-method-indicator",
                display_name: _("Input Method"),
                description:_("The input method indicator"));
    }

    public override Gtk.Widget get_display_widget () {
        if (display_icon == null) {
            display_icon = new InputMethod.Widgets.InputMethodIcon ();
            // FIXME: The change order is reversed once you switch input methods with ctrl + space
            //  display_icon.button_press_event.connect ((e) => {
            //      if (e.button == Gdk.BUTTON_MIDDLE) {
            //          if (e.state == Gdk.ModifierType.SHIFT_MASK) {
            //              engines.previous ();
            //          } else {
            //              engines.next ();
            //          }

            //          return Gdk.EVENT_STOP;
            //      }
            //      return Gdk.EVENT_PROPAGATE;
            //  });

            engines = new InputMethod.Widgets.EngineManager ();
            engines.updated.connect (() => {
                Widgets.EngineButton? current_button = engines.get_current_engine_button ();
                if (current_button != null) {
                    display_icon.label = current_button.code[0:2];
                    current_button.radio_button.active = true;
                }

                var new_visibility = engines.has_engines ();
                if (new_visibility != visible) {
                    visible = new_visibility;
                }
            });

            engines.updated ();

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

            main_grid.add (engines);
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

    IBus.init ();

    debug ("Activating InputMethod Indicator");
    var indicator = new InputMethod.Indicator ();
    return indicator;
}

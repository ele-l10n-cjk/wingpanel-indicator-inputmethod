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
    private Gtk.Stack stack;

    private InputMethod.Widgets.InputMethodIcon display_icon;
    private InputMethod.Widgets.EngineManager engines;

    private Granite.Widgets.AlertView alert_view;

    public Indicator () {
        Object (
            code_name: "input-method-indicator",
            visible: true
        );
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
                update_display_icon ();
            });

            engines.update_engines_list ();
        }

        return display_icon;
    }

    public override Gtk.Widget? get_widget () {
        if (main_grid == null) {
            main_grid = new Gtk.Grid ();
            main_grid.set_orientation (Gtk.Orientation.VERTICAL);

            alert_view = new Granite.Widgets.AlertView (
                _("IBus Daemon is Not Running"),
                _("Click \"Input Method Settings…\" to show available input method engines."),
                ""
            ) {
                halign = Gtk.Align.CENTER,
                valign = Gtk.Align.CENTER
            };
            alert_view.get_style_context ().remove_class (Gtk.STYLE_CLASS_VIEW);

            stack = new Gtk.Stack () {
                homogeneous = false
            };
            stack.add (engines);
            stack.add (alert_view);
            stack.show_all ();

            var separator = new Wingpanel.Widgets.Separator ();

            var settings_button = new Gtk.ModelButton () {
                text = _("Input Method Settings…")
            };
            settings_button.clicked.connect (show_settings);

            main_grid.add (stack);
            main_grid.add (separator);
            main_grid.add (settings_button);
            main_grid.show_all ();
        }

        return main_grid;
    }

    public override void opened () {
        // Update the visible view depending on whether IBus Daemon is running
        var bus = new IBus.Bus ();
        if (bus.is_connected ()) {
            engines.update_engines_list ();
            update_display_icon ();
        } else {
            stack.visible_child = alert_view;
            ///TRANSLATORS: A string shown as the indicator icon when IBus Daemon is not running,
            ///or no active input method engines
            display_icon.label = _("N/A");
            alert_view.title = _("IBus Daemon is Not Running");
            alert_view.description = _("Click \"Input Method Settings…\" to show available input method engines.");
        }
    }

    public override void closed () {}

    private void show_settings () {
        close ();

        try {
            AppInfo.launch_default_for_uri ("settings://input/keyboard/inputmethod", null);
        } catch (Error e) {
            warning ("%s\n", e.message);
        }
    }

    private void update_display_icon () {
        Widgets.EngineButton? current_button = engines.get_current_engine_button ();
        if (current_button != null) {
            stack.visible_child = engines;
            display_icon.label = current_button.code[0:2];
            current_button.radio_button.active = true;
        } else {
            stack.visible_child = alert_view;
            ///TRANSLATORS: A string shown as the indicator icon when IBus Daemon is not running,
            ///or no active input method engines
            display_icon.label = _("N/A");
            alert_view.title = _("No Input Method Engines Added");
            alert_view.description = _("Click \"Input Method Settings…\" to add one.");
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

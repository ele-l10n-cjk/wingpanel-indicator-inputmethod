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

public class InputMethod.Widgets.EngineManager : Gtk.ScrolledWindow {
    public signal void updated ();

    private GLib.Settings settings;
    private Gtk.Grid main_grid;

    public EngineManager () {
    }

    construct {
        hscrollbar_policy = Gtk.PolicyType.NEVER;

        main_grid = new Gtk.Grid () {
            orientation = Gtk.Orientation.VERTICAL
        };

        add (main_grid);

        settings = new GLib.Settings ("org.freedesktop.ibus.general");
        settings.changed["preload-engines"].connect (() => {
            update_engines_list ();
        });

        settings.changed["engines-order"].connect_after (() => {
            updated ();
        });

        show_all ();
    }

    public override void get_preferred_height (out int minimum_height, out int natural_height) {
        List<weak Gtk.Widget?> children = main_grid.get_children ();
        if (children == null) {
            minimum_height = 0;
            natural_height = 0;
            return;
        }

        var display = Gdk.Display.get_default ();
        var monitor = display.get_primary_monitor ();
        Gdk.Rectangle geom = monitor.get_geometry ();

        main_grid.get_preferred_height (out minimum_height, out natural_height);
        minimum_height = int.min (minimum_height, (int)(geom.height * 2 / 3));
    }

    public void update_engines_list () {
        clear ();
        populate_engines ();
        updated ();
    }

    private void populate_engines () {
        string[] source_list = settings.get_strv ("preload-engines");
#if IBUS_1_5_19
        List<IBus.EngineDesc?> engines = new IBus.Bus ().list_engines ();
#else
        List<unowned IBus.EngineDesc?> engines = new IBus.Bus ().list_engines ();
#endif

        EngineButton engine_button = null;
        int i = 0;
        foreach (var engine in engines) {
            foreach (var source in source_list) {
                if (engine.name == source) {
                    string full_name = "%s - %s".printf (IBus.get_language_name (engine.language),
                                                            gettext_engine_longname (engine));

                    engine_button = new EngineButton (source, full_name, i, engine_button);
                    main_grid.add (engine_button);
                    i++;
                }
            }
        }

        main_grid.show_all ();
    }

    public EngineButton? get_current_engine_button () {
        string source = settings.get_strv ("engines-order")[0];
        EngineButton? engine_button = null;

        main_grid.get_children ().foreach ((child) => {
            if (child is EngineButton) {
                var button = (EngineButton) child;
                if (button.code == source) {
                    engine_button = button;
                }
            }
        });

        return engine_button;
    }

    // FIXME: The change order is reversed once you switch input methods with ctrl + space
    //  public void next () {
    //      string[] current_order = settings.get_strv ("engines-order");
    //      string current_active_engine = current_order[0];
    //      string new_active_engine = current_order[1];

    //      string[] new_order = {};
    //      new_order += new_active_engine;
    //      for (int i = 2; i < current_order.length; i++) {
    //          new_order += current_order[i];
    //      }

    //      new_order += current_active_engine;

    //      settings.set_strv ("engines-order", new_order);
    //      updated ();
    //  }

    //  public void previous () {
    //      string[] current_order = settings.get_strv ("engines-order");
    //      string new_active_engine = current_order[current_order.length - 1];

    //      string[] new_order = {};
    //      new_order += new_active_engine;
    //      for (int i = 0; i < current_order.length - 1; i++) {
    //          new_order += current_order[i];
    //      }

    //      settings.set_strv ("engines-order", new_order);
    //      updated ();
    //  }

    public void clear () {
        main_grid.get_children ().foreach ((child) => {
            child.destroy ();
        });
    }

    // From https://github.com/ibus/ibus/blob/master/ui/gtk2/i18n.py#L47-L54
    public string gettext_engine_longname (IBus.EngineDesc engine) {
        string name = engine.name;
        if (name.has_prefix ("xkb:")) {
            return dgettext ("xkeyboard-config", engine.longname);
        }

        string textdomain = engine.textdomain;
        if (textdomain == "") {
            return engine.longname;
        }

        return dgettext (textdomain, engine.longname);
    }
}

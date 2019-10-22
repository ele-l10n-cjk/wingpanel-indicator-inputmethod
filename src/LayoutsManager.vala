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

public class InputMethod.Widgets.LayoutManager : Gtk.ScrolledWindow {
    public signal void updated ();

    private GLib.Settings settings;
    private Gtk.Grid main_grid;

    private string[] _active_engines;
    // Stores currently activated engines
    public string[] active_engines {
        get {
            _active_engines = settings.get_strv ("preload-engines");
            return _active_engines;
        }
        set {
            settings.set_strv ("preload-engines", value);
            settings.set_strv ("engines-order", value);
        }
    }

    public LayoutManager () {
        populate_layouts ();
    }

    construct {
        main_grid = new Gtk.Grid ();
        main_grid.orientation = Gtk.Orientation.VERTICAL;

        hscrollbar_policy = Gtk.PolicyType.NEVER;
        add (main_grid);

        settings = new GLib.Settings ("org.freedesktop.ibus.general");
        settings.changed["preload-engines"].connect (() => {
            clear ();
            populate_layouts ();
            updated ();
        });

        settings.changed["engines-order"].connect_after (() => {
            updated ();
        });

        show_all ();
    }

    public override void get_preferred_height (out int minimum_height, out int natural_height) {
        List<weak Gtk.Widget> children = main_grid.get_children ();
        weak Gtk.Widget? first_child = children.first ().data;
        if (first_child == null) {
            minimum_height = 0;
            natural_height = 0;
        } else {
            main_grid.get_preferred_height (out minimum_height, out natural_height);
            minimum_height = int.min (minimum_height, (int)(Gdk.Screen.height () * 2 / 3));
        }
    }

    private void populate_layouts () {
        string[] source_list = settings.get_strv ("preload-engines");
        LayoutButton layout_button = null;
        int i = 0;
        foreach (var source in source_list) {
            string? name;
            string language;
            string? variant = null;
            language = source;
            name = source;

            layout_button = new LayoutButton (name, language, variant, i, settings, layout_button);
            main_grid.add (layout_button);
            i++;
        }

        main_grid.show_all ();
    }

    private LayoutButton? get_current_layout_button () {
        LayoutButton? layout_button = null;

        main_grid.get_children ().foreach ((child) => {
            if (child is LayoutButton) {
                var button = (LayoutButton) child;
                if (button.radio_button.active) {
                    layout_button = button;
                }
            }
        });

        return layout_button;
    }

    public string get_current (bool shorten = false) {
        string current = "us";
        var button = get_current_layout_button ();
        if (button != null) {
            current = button.code;
        }

        if (shorten) {
            return current[0:2];
        } else {
            return current;
        }
    }

    public void next () {
        //  var current = settings.get_value ("current");
        //  var next = current.get_uint32 () + 1;
        //  if (next >= main_grid.get_children ().length ()) {
        //      next = 0;
        //  }

        //  settings.set_value ("current", next);
    }

    public void clear () {
        main_grid.get_children ().foreach ((child) => {
            child.destroy ();
        });
    }

    public bool has_layouts () {
        return main_grid.get_children ().length () > 1;
    }
}

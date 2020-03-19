project(
    'inputmethod',
    'vala', 'c',
    version: '1.0.0'
)

i18n = import('i18n')
gnome = import('gnome')
gettext_name = meson.project_name() + '-indicator'

prefix = get_option('prefix')
libdir = join_paths(prefix, get_option('libdir'))

add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format(gettext_name), language:'c')

gresource = gnome.compile_resources(
    'gresource',
    join_paths('data', 'inputmethod.gresource.xml'),
    source_dir: 'data'
)

ibus_dep = dependency('ibus-1.0')
if(ibus_dep.version().version_compare('>=1.5.19'))
    add_project_arguments(['--define', 'IBUS_1_5_19'], language: 'vala')
endif

wingpanel_dep = dependency('wingpanel-2.0')
wingpanel_indicatorsdir = wingpanel_dep.get_pkgconfig_variable('indicatorsdir', define_variable: ['libdir', libdir])

shared_module(
    meson.project_name(),
    gresource,
    'src/EngineButton.vala',
    'src/EngineManager.vala',
    'src/Indicator.vala',
    'src/InputMethodIcon.vala',
    dependencies: [
        dependency('glib-2.0'),
        dependency('gobject-2.0'),
        dependency('granite'),
        dependency('gtk+-3.0'),
        ibus_dep,
        wingpanel_dep
    ],
    install: true,
    install_dir : wingpanel_indicatorsdir
)

i18n.merge_file(
    input: 'data/inputmethod.appdata.xml.in',
    output: 'io.elementary.wingpanel.inputmethod.appdata.xml',
    po_dir: join_paths(meson.source_root (), 'po', 'extra'),
    install_dir: join_paths(get_option('datadir'), 'metainfo'),
    install: true
)

subdir('po')

# project name and programming language
project('com.github.jeremyvaartjes.ping', 'vala', 'c')

i18n = import('i18n')
add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

# Create a new executable, list the files we want to compile, list the dependencies we need, and install
executable(
    meson.project_name(),
    'src/Application.vala',
    'src/PingTest.vala',
    dependencies: [
        dependency('gtk+-3.0'),
        dependency('gtksourceview-3.0'),
        dependency('gio-2.0'),
        dependency('gee-0.8'),
        dependency('granite'),
        dependency('json-glib-1.0'),
        dependency('libsoup-2.4')
    ],
    install: true
)

subdir('data')
subdir('po')


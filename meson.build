    # project name and programming language
    project('com.github.jeremyvaartjes.ping', 'vala', 'c')

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
    
    icon_sizes = ['48', '64', '128']

    foreach i : icon_sizes
        install_data(
            join_paths('data', 'icons', i, meson.project_name() + '.svg'),
            install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i, 'apps')
        )
        install_data(
            join_paths('data', 'icons', i, meson.project_name() + '.svg'),
            install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i + '@2', 'apps')
        )
    endforeach

    #Install our .desktop file so the Applications Menu will see it
    install_data(
        join_paths('data', meson.project_name() + '.desktop'),
        install_dir: join_paths(get_option('datadir'), 'applications')
    )

    #Install our .appdata.xml file so AppCenter will see it
    install_data(
        join_paths('data', meson.project_name() + '.appdata.xml'),
        install_dir: join_paths(get_option('datadir'), 'metainfo')
    )
    
    

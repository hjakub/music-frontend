cmake_minimum_required(VERSION 3.16)

project(music_frontend VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appmusic_frontend
    main.cpp
)

qt_add_resources(appmusic_frontend "Icons"
    PREFIX "/"
    FILES
        icons/close.svg
        icons/eye.svg
        icons/infinite.svg
        icons/pause.svg
        icons/pencil.svg
        icons/play.svg
        icons/refresh.svg
        icons/search.svg
        icons/trash.svg
)

qt_add_qml_module(appmusic_frontend
    URI music_frontend
    VERSION 1.0
    QML_FILES
        Main.qml
        SOURCES SongUploader.h
        SOURCES SongUploader.cpp
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appmusic_frontend PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appmusic_frontend
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appmusic_frontend
    PRIVATE Qt6::Quick
)

include(GNUInstallDirs)
install(TARGETS appmusic_frontend
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "SongUploader.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("music_frontend", "Main");

    SongUploader uploader;
    engine.rootContext()->setContextProperty("songUploader", &uploader);

    engine.loadFromModule("music_frontend", "Main");

    return app.exec();
}

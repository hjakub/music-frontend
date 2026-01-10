#ifndef SONGUPLOADER_H
#define SONGUPLOADER_H

#pragma once
#include <QObject>
#include <QString>

class SongUploader : public QObject {
    Q_OBJECT
public:
    explicit SongUploader(QObject *parent = nullptr);

    Q_INVOKABLE void uploadSong(const QString &filePath,
                                const QString &title,
                                const QString &album,
                                const QString &genre,
                                const QString &year,
                                const QString &artistId);
};


#endif // SONGUPLOADER_H

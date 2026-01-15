#include "SongUploader.h"
#include <QHttpMultiPart>
#include <QHttpPart>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QFile>
#include <QUrl>
#include <QDebug>

SongUploader::SongUploader(QObject *parent) : QObject(parent) {}

void SongUploader::uploadSong(const QString &filePath,
                              const QString &title,
                              const QString &album,
                              const QString &genre,
                              const QString &year,
                              const QString &artistId)
{
    QUrl url(filePath);
    QString localPath = url.toLocalFile();

    QFile *file = new QFile(localPath);
    if (!file->open(QIODevice::ReadOnly)) {
        qWarning() << "failed to open file:" << localPath;
        return;
    }

    // create multipart form
    QHttpMultiPart *multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);

    // file part
    QHttpPart filePart;
    filePart.setHeader(QNetworkRequest::ContentDispositionHeader,
                       QVariant("form-data; name=\"file\"; filename=\"" + file->fileName() + "\""));
    filePart.setBodyDevice(file);
    file->setParent(multiPart);
    multiPart->append(filePart);

    // helper to append text fields
    auto addField = [&](const QString &name, const QString &value) {
        QHttpPart part;
        part.setHeader(QNetworkRequest::ContentDispositionHeader,
                       QVariant("form-data; name=\"" + name + "\""));
        part.setBody(value.toUtf8());
        multiPart->append(part);
    };

    addField("title", title);
    addField("album", album);
    addField("genre", genre);
    addField("year", year);
    addField("artistId", artistId);

    // post request to backend
    QNetworkRequest request(QUrl("http://music-backend-42k7.onrender.com/api/songs/upload"));
    QNetworkAccessManager *manager = new QNetworkAccessManager(this);
    QNetworkReply *reply = manager->post(request, multiPart);
    multiPart->setParent(reply);

    QObject::connect(reply, &QNetworkReply::finished, [reply]() {
        if (reply->error() == QNetworkReply::NoError) {
            qDebug() << "song uploaded successfully!";
        } else {
            qWarning() << "upload failed:" << reply->errorString();
            QByteArray err = reply->readAll();
            qWarning() << "server says:" << err;
        }
        reply->deleteLater();
    });
}

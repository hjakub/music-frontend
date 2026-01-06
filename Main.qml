import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia

Window {
    width: 640
    height: 480
    visible: true
    title: "Music Player"
    property string currentPlayingUrl: ""
    property bool isLoopEnabled: false

    ListModel { id: songModel }

    Timer {
        id: updateButtonTimer
        interval: 500
        running: true
        repeat: true
        onTriggered: {
            listView.forceLayout()
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#f9f9f9"

        ColumnLayout {
            anchors.fill: parent
            spacing: 10

            Label {
                text: "My Songs"
                font.bold: true
                font.pointSize: 16
                Layout.alignment: Qt.AlignHCenter
            }

            ListView {
                id: listView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: songModel

                delegate: Rectangle {
                    width: parent.width
                    height: 60
                    color: player.source === fileUrl
                           ? "#d0ebff"
                           : index % 2 === 0 ? "#f0f0f0" : "#ffffff"
                    border.width: 1
                    border.color: "#ccc"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 10

                        ColumnLayout {
                            Layout.fillWidth: true
                            Text { text: title; font.bold: true; elide: Text.ElideRight }
                            Text { text: album; color: "#666"; font.pixelSize: 12; elide: Text.ElideRight }
                        }

                        // play + pause button
                        Button {
                            id: playPauseButton
                            text: (currentPlayingUrl === fileUrl &&
                                   player.playbackState === MediaPlayer.PlayingState)
                                   ? "Pause" : "Play"
                            visible: fileUrl && fileUrl !== ""

                            onClicked: {
                                if (currentPlayingUrl !== fileUrl) {
                                    currentPlayingUrl = fileUrl
                                    player.source = fileUrl
                                    player.play()
                                } else {
                                    if (player.playbackState === MediaPlayer.PlayingState)
                                        player.pause()
                                    else
                                        player.play()
                                }
                            }
                        }

                        // loop checkbox
                        CheckBox {
                            id: loopCheckBox
                            text: "Loop"
                            checked: isLoopEnabled && (currentPlayingUrl === fileUrl)
                            onClicked: {
                                isLoopEnabled = checked
                            }
                        }
                    }
                }
            }

            // seek bar
            RowLayout {
                Layout.fillWidth: true
                anchors.margins: 10
                spacing: 10

                Slider {
                    id: seekSlider
                    Layout.fillWidth: true
                    from: 0
                    to: player.duration || 1
                    value: player.position
                    onMoved: {
                        player.position = value
                    }
                }

                Label {
                    id: positionLabel
                    text: formatTime(player.position)
                    Layout.alignment: Qt.AlignRight
                }
            }

            MediaPlayer {
                id: player
                audioOutput: AudioOutput { id: output }
                onSourceChanged: console.log("now playing:", source)
                onPlaybackStateChanged: console.log("playback state changed to:", playbackState)
                onPositionChanged: seekSlider.value = position
                onDurationChanged: seekSlider.to = duration
                onMediaStatusChanged: {
                    if (mediaStatus === MediaPlayer.EndOfMedia && isLoopEnabled) {
                        player.position = 0
                        player.play()
                    }
                }
            }
        }
    }

    function formatTime(ms) {
        var seconds = Math.floor(ms / 1000)
        var minutes = Math.floor(seconds / 60)
        seconds = seconds % 60
        return minutes + ":" + (seconds < 10 ? "0" + seconds : seconds)
    }

    // autoload songs
    function loadSongs() {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "http://localhost:5000/api/songs");
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    var songs = JSON.parse(xhr.responseText);
                    songModel.clear();
                    for (var i = 0; i < songs.length; i++) {
                        songModel.append({
                            title: songs[i].title,
                            artistId: songs[i].artistId,
                            album: songs[i].album,
                            genre: songs[i].genre,
                            year: songs[i].year,
                            fileUrl: songs[i].fileUrl
                        });
                    }
                } else {
                    console.log("error loading songs:", xhr.status, xhr.statusText);
                }
            }
        };
        xhr.send();
    }

    Component.onCompleted: loadSongs()
}

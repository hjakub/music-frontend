import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import QtMultimedia

Window {
    width: 900
    height: 550
    visible: true
    title: "Music Player"
    minimumWidth: 600
    minimumHeight: 500
    property string currentPlayingUrl: ""
    property bool isLoopEnabled: false

    ListModel { id: songModel }

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: homePage
    }

    Component {
        id: homePage
        Rectangle {
            width: parent ? parent.width : 900
            height: parent ? parent.height : 550
            color: "#f9f9f9"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                Label {
                    text: "Music Library"
                    font.bold: true
                    font.pointSize: 16
                    Layout.alignment: Qt.AlignHCenter
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Button {
                        text: "+ Add new track"
                        Layout.fillWidth: true
                        onClicked: {
                            titleField.text = ""
                            albumField.text = ""
                            genreField.text = ""
                            yearField.text = ""
                            addDialog.selectedFilePath = ""
                            addDialog.selectedArtistId = ""
                            addDialog.isAddingArtist = false
                            addDialog.open()
                        }
                    }

                    Button {
                        text: "Refresh"
                        Layout.preferredWidth: 100
                        onClicked: loadSongs()
                    }

                    CheckBox {
                        id: globalLoop
                        text: "Loop"
                        checked: isLoopEnabled
                        onClicked: isLoopEnabled = checked
                        Layout.preferredWidth: 140
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    TextField {
                        id: searchField
                        placeholderText: "Search.."
                        Layout.fillWidth: true
                        onAccepted: searchSongs()
                    }

                    Button {
                        text: "Search"
                        onClicked: searchSongs()
                    }

                    Button {
                        text: "Clear"
                        onClicked: {
                            searchField.text = ""
                            loadSongs()
                        }
                    }
                }

                ListView {
                    id: listView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: songModel
                    delegate: Rectangle {
                        width: listView.width
                        height: 160
                        color: player.source === fileUrl
                               ? "#d0ebff"
                               : index % 2 === 0 ? "#f0f0f0" : "#ffffff"
                        border.width: 1
                        border.color: "#ccc"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 6

                            Text {
                                text: title
                                font.bold: true
                                font.pointSize: 14
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }

                            Text {
                                text: "Album: " + (album || "Unknown")
                                color: "#444"
                                font.pixelSize: 12
                                Layout.fillWidth: true
                            }

                            Text {
                                text: "Artist: " + (artistName || "Unknown")
                                color: "#444"
                                font.pixelSize: 12
                                Layout.fillWidth: true
                            }

                            Text {
                                text: "Year: " + (year || "Unknown")
                                color: "#444"
                                font.pixelSize: 12
                                Layout.fillWidth: true
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignLeft
                                spacing: 10

                                property int buttonWidth: 100

                                Button {
                                    text: (currentPlayingUrl === fileUrl &&
                                           player.playbackState === MediaPlayer.PlayingState)
                                           ? "Pause" : "Play"
                                    visible: fileUrl && fileUrl !== ""
                                    Layout.preferredWidth: parent.buttonWidth
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

                                Button {
                                    text: "Edit"
                                    Layout.preferredWidth: parent.buttonWidth
                                    onClicked: {
                                        if (_id && title && album && genre && year) {
                                            editDialog.songId = _id;
                                            editDialog.editTitleField.text = title;
                                            editDialog.editAlbumField.text = album;
                                            editDialog.editGenreField.text = genre;
                                            editDialog.editYearField.text = year;
                                            editDialog.open();
                                        }
                                    }
                                }

                                Button {
                                    text: "Delete"
                                    Layout.preferredWidth: parent.buttonWidth
                                    onClicked: {
                                        confirmDeleteDialog.songId = _id
                                        confirmDeleteDialog.open()
                                    }
                                }

                                Button {
                                    text: "Details"
                                    Layout.preferredWidth: parent.buttonWidth
                                    onClicked: {
                                        stackView.push(detailsPage, {
                                            songTitle: title,
                                            songAlbum: album,
                                            songArtist: artistName,
                                            songGenre: genre,
                                            songYear: year
                                        })
                                    }
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    Slider {
                        id: seekSlider
                        Layout.fillWidth: true
                        from: 0
                        to: player.duration || 1
                        value: player.position
                        onMoved: player.position = value
                    }
                    Label {
                        text: formatTime(player.position)
                        Layout.alignment: Qt.AlignRight
                    }
                }
            }

            MediaPlayer {
                id: player
                audioOutput: AudioOutput { id: output }
                onPositionChanged: seekSlider.value = position
                onDurationChanged: seekSlider.to = duration
                onMediaStatusChanged: {
                    if (mediaStatus === MediaPlayer.EndOfMedia && isLoopEnabled) {
                        player.position = 0
                        player.play()
                    }
                }
            }

            function formatTime(ms) {
                var seconds = Math.floor(ms / 1000)
                var minutes = Math.floor(seconds / 60)
                seconds = seconds % 60
                return minutes + ":" + (seconds < 10 ? "0" + seconds : seconds)
            }

            Component.onCompleted: loadSongs()

            // autoload songs
            function loadSongs() {
                var xhr = new XMLHttpRequest()
                xhr.open("GET", "http://localhost:5000/api/songs")
                xhr.onreadystatechange = function() {
                    if (xhr.readyState === XMLHttpRequest.DONE) {
                        if (xhr.status === 200) {
                            var songs = JSON.parse(xhr.responseText)
                            songModel.clear()
                            for (var i = 0; i < songs.length; i++) {
                                songModel.append({
                                    _id: songs[i]._id,
                                    title: songs[i].title,
                                    album: songs[i].album,
                                    genre: songs[i].genre,
                                    year: songs[i].year,
                                    artistId: songs[i].artistId,
                                    artistName: songs[i].artistName || "",
                                    fileUrl: songs[i].fileUrl
                                })
                            }
                        } else {
                            console.log("error loading songs:", xhr.status, xhr.statusText)
                        }
                    }
                }
                xhr.send()
            }

            function searchSongs() {
                var query = searchField.text.trim()
                if (query === "") {
                    loadSongs()
                    return
                }

                var xhr = new XMLHttpRequest()
                xhr.open("GET", "http://localhost:5000/api/songs/search/" + encodeURIComponent(query))
                xhr.onreadystatechange = function() {
                    if (xhr.readyState === XMLHttpRequest.DONE) {
                        if (xhr.status === 200) {
                            var songs = JSON.parse(xhr.responseText)
                            songModel.clear()
                            for (var i = 0; i < songs.length; i++) {
                                songModel.append({
                                    _id: songs[i]._id,
                                    title: songs[i].title,
                                    album: songs[i].album,
                                    genre: songs[i].genre,
                                    year: songs[i].year,
                                    artistId: songs[i].artistId,
                                    artistName: songs[i].artistName || "",
                                    fileUrl: songs[i].fileUrl
                                })
                            }
                        }
                    }
                }
                xhr.send()
            }
        }
    }

    Component {
        id: detailsPage
        Rectangle {
            anchors.fill: parent
            color: "#f9f9f9"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 10

                Label {
                    text: "Song Details"
                    font.bold: true
                    font.pointSize: 18
                    Layout.alignment: Qt.AlignHCenter
                }

                Text { text: "Title: " + songTitle; font.pixelSize: 14 }
                Text { text: "Album: " + songAlbum; font.pixelSize: 14 }
                Text { text: "Artist: " + songArtist; font.pixelSize: 14 }
                Text { text: "Genre: " + songGenre; font.pixelSize: 14 }
                Text { text: "Year: " + songYear; font.pixelSize: 14 }

                Item { Layout.fillHeight: true }

                Button {
                    text: "Back to Music Library"
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: stackView.pop()
                }
            }

            property string songTitle: ""
            property string songAlbum: ""
            property string songArtist: ""
            property string songGenre: ""
            property string songYear: ""
        }
    }

    // dialog - add new track
    Dialog {
        id: addDialog
        title: "Add new track"
        modal: true
        width: 550
        height: 550
        standardButtons: Dialog.Ok | Dialog.Cancel

        property string selectedFilePath: ""
        property string selectedArtistId: ""
        property bool isAddingArtist: false
        ListModel { id: artistModel }

        ScrollView {
            anchors.fill: parent
            ColumnLayout {
                anchors.margins: 16
                spacing: 10
                width: parent.width - 20

                TextField { id: titleField; placeholderText: "Song title"; Layout.fillWidth: true }
                TextField { id: albumField; placeholderText: "Album"; Layout.fillWidth: true }
                TextField { id: genreField; placeholderText: "Genre"; Layout.fillWidth: true }
                TextField { id: yearField; placeholderText: "Year"; Layout.fillWidth: true }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    Label { text: "Artist:" }
                    ComboBox {
                        id: artistDropdown
                        Layout.fillWidth: true
                        textRole: "name"
                        model: artistModel
                        onActivated: {
                            addDialog.selectedArtistId = artistModel.get(currentIndex).id
                            addDialog.isAddingArtist = (addDialog.selectedArtistId === "new")
                        }
                    }
                }

                ColumnLayout {
                    visible: addDialog.isAddingArtist
                    spacing: 8
                    TextField { id: newArtistName; placeholderText: "Artist name"; Layout.fillWidth: true }
                    TextField { id: newArtistCountry; placeholderText: "Country"; Layout.fillWidth: true }
                    TextField { id: newArtistGenre; placeholderText: "Artist genre"; Layout.fillWidth: true }
                }

                Button {
                    text: addDialog.selectedFilePath === "" ? "Choose audio file" : "File selected"
                    Layout.fillWidth: true
                    onClicked: fileDialog.open()
                }
            }
        }

        FileDialog {
            id: fileDialog
            title: "Select audio file"
            nameFilters: ["Audio files (*.mp3 *.wav *.flac)"]
            onAccepted: addDialog.selectedFilePath = fileDialog.selectedFile
        }

        onOpened: loadArtists()

        onAccepted: {
            if (addDialog.isAddingArtist) {
                var xhr = new XMLHttpRequest()
                xhr.open("POST", "http://localhost:5000/api/artists")
                xhr.setRequestHeader("Content-Type", "application/json")
                xhr.onreadystatechange = function() {
                    if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 201) {
                        var artist = JSON.parse(xhr.responseText)
                        songUploader.uploadSong(
                            addDialog.selectedFilePath,
                            titleField.text,
                            albumField.text,
                            genreField.text,
                            yearField.text,
                            artist._id
                        )
                    }
                }
                xhr.send(JSON.stringify({
                    name: newArtistName.text,
                    country: newArtistCountry.text,
                    genre: newArtistGenre.text
                }))
            } else {
                songUploader.uploadSong(
                    addDialog.selectedFilePath,
                    titleField.text,
                    albumField.text,
                    genreField.text,
                    yearField.text,
                    addDialog.selectedArtistId
                )
            }
        }
    }

    // dialog - edit track
    Dialog {
        id: editDialog
        title: "Edit track"
        modal: true
        width: 550
        height: 500
        standardButtons: Dialog.Ok | Dialog.Cancel
        property string songId: ""
        property alias editTitleField: internalEditTitleField
        property alias editAlbumField: internalEditAlbumField
        property alias editGenreField: internalEditGenreField
        property alias editYearField: internalEditYearField

        ScrollView {
            anchors.fill: parent
            ColumnLayout {
                anchors.margins: 16
                spacing: 10
                width: parent.width - 20

                TextField { id: internalEditTitleField; placeholderText: "Song title"; Layout.fillWidth: true }
                TextField { id: internalEditAlbumField; placeholderText: "Album"; Layout.fillWidth: true }
                TextField { id: internalEditGenreField; placeholderText: "Genre"; Layout.fillWidth: true }
                TextField { id: internalEditYearField; placeholderText: "Year"; Layout.fillWidth: true }
            }
        }

        onAccepted: {
            var xhr = new XMLHttpRequest();
            xhr.open("PUT", "http://localhost:5000/api/songs/" + songId);
            xhr.setRequestHeader("Content-Type", "application/json");
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                    if (stackView.currentItem && stackView.currentItem.loadSongs)
                        stackView.currentItem.loadSongs()
                }
            };
            xhr.send(JSON.stringify({
                title: editTitleField.text,
                album: editAlbumField.text,
                genre: editGenreField.text,
                year: editYearField.text
            }));
        }
    }

    // dialog - delete track
    MessageDialog {
        id: confirmDeleteDialog
        title: "Delete track"
        text: "Are you sure you want to delete this track?"
        buttons: MessageDialog.Yes | MessageDialog.No
        property string songId: ""

        onAccepted: {
            var xhr = new XMLHttpRequest()
            xhr.open("DELETE", "http://localhost:5000/api/songs/" + songId)
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                    if (stackView.currentItem && stackView.currentItem.loadSongs)
                        stackView.currentItem.loadSongs()
                }
            }
            xhr.send()
        }
    }

    function loadArtists() {
        var xhr = new XMLHttpRequest()
        xhr.open("GET", "http://localhost:5000/api/artists")
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                var artists = JSON.parse(xhr.responseText)
                artistModel.clear()
                for (var i = 0; i < artists.length; i++)
                    artistModel.append({ id: artists[i]._id, name: artists[i].name })
                artistModel.append({ id: "new", name: "+ Add new artist" })
            }
        }
        xhr.send()
    }

    function uploadSong(artistId) {
        var xhr = new XMLHttpRequest()
        xhr.open("POST", "http://localhost:5000/api/songs")
        xhr.setRequestHeader("Content-Type", "application/json")
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 201) {
                if (stackView.currentItem && stackView.currentItem.loadSongs)
                    stackView.currentItem.loadSongs()
            }
        }
        xhr.send(JSON.stringify({
            title: titleField.text,
            album: albumField.text,
            genre: genreField.text,
            year: yearField.text,
            artistId: artistId,
            fileUrl: ""
        }))
    }

    function addNewArtistAndSong() {
        var xhr = new XMLHttpRequest()
        xhr.open("POST", "http://localhost:5000/api/artists")
        xhr.setRequestHeader("Content-Type", "application/json")
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 201) {
                var artist = JSON.parse(xhr.responseText)
                uploadSong(artist._id)
            }
        }
        xhr.send(JSON.stringify({
            name: newArtistName.text,
            country: newArtistCountry.text,
            genre: newArtistGenre.text
        }))
    }
}

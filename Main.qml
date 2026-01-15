import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import QtMultimedia
import QtQuick.Controls.Material

ApplicationWindow {
    width: 900
    height: 550
    visible: true
    title: "Music Player"
    Material.theme: Material.Dark
    Material.accent: Material.Blue
    minimumWidth: 600
    minimumHeight: 550
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
            color: Material.background

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                Label {
                    text: "Music Library"
                    font.bold: true
                    font.pointSize: 18
                    color: Material.foreground
                    Layout.alignment: Qt.AlignHCenter
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Button {
                        text: "+ Add new track"
                        icon.source: "qrc:/icons/plus.svg"
                        Layout.fillWidth: true
                        implicitHeight: 44
                        background: Rectangle {
                            radius: 4
                            color: "#333"
                        }
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
                        id: refreshButton
                        icon.source: "qrc:/icons/refresh.svg"
                        text: "Refresh"
                        implicitHeight: 44
                        Layout.preferredWidth: 140
                        background: Rectangle {
                            radius: 4
                            color: "#333"
                        }
                        onClicked: loadSongs()
                    }

                    Button {
                        id: loopButton
                        icon.source: "qrc:/icons/infinite.svg"
                        text: "Loop"
                        implicitHeight: 44
                        Layout.preferredWidth: refreshButton.Layout.preferredWidth
                        background: Rectangle {
                            radius: 4
                            color: isLoopEnabled ? Material.color(Material.Blue) : "#333"
                        }
                        onClicked: {
                            isLoopEnabled = !isLoopEnabled
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    TextField {
                        id: searchField
                        placeholderText: "Search songs.."
                        implicitHeight: 44
                        Layout.fillWidth: true
                        onAccepted: searchSongs()
                    }

                    Button {
                        icon.source: "qrc:/icons/search.svg"
                        text: "Search"
                        implicitHeight: 44
                        Layout.preferredWidth: 140
                        background: Rectangle {
                            radius: 4
                            color: "#333"
                        }
                        onClicked: searchSongs()
                    }

                    Button {
                        icon.source: "qrc:/icons/close.svg"
                        text: "Clear"
                        implicitHeight: 44
                        Layout.preferredWidth: 140
                        background: Rectangle {
                            radius: 4
                            color: "#333"
                        }
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
                    spacing: 10
                    model: songModel

                    delegate: Rectangle {
                        width: listView.width
                        height: 160
                        color: player.source === fileUrl
                               ? Material.color(Material.Blue, Material.Shade700)
                               : (index % 2 === 0 ? "#1e1e1e" : Material.background)
                        border.color: "#666"
                        radius: 4

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 6

                            Text {
                                text: title
                                font.bold: true
                                font.pointSize: 15
                                color: Material.foreground
                            }

                            Text { text: "Album: " + (album || "Unknown"); color: "#afafaf" }
                            Text { text: "Artist: " + (artistName || "Unknown"); color: "#afafaf" }
                            Text { text: "Year: " + (year || "Unknown"); color: "#afafaf" }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                property int buttonSize: 44

                                Button {
                                    visible: fileUrl && fileUrl !== ""
                                    icon.source: (currentPlayingUrl === fileUrl &&
                                                  player.playbackState === MediaPlayer.PlayingState)
                                                 ? "qrc:/icons/pause.svg"
                                                 : "qrc:/icons/play.svg"
                                    Layout.preferredWidth: parent.buttonSize
                                    Layout.preferredHeight: parent.buttonSize
                                    background: Rectangle {
                                        radius: 4
                                        color: "#333"
                                    }
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
                                    icon.source: "qrc:/icons/pencil.svg"
                                    Layout.preferredWidth: parent.buttonSize
                                    Layout.preferredHeight: parent.buttonSize
                                    background: Rectangle {
                                        radius: 4
                                        color: "#333"
                                    }
                                    onClicked: {
                                        if (_id) {
                                            editDialog.songId = _id;
                                            editDialog.editTitleField.text = title || "";
                                            editDialog.editAlbumField.text = album || "";
                                            editDialog.editGenreField.text = genre || "";
                                            editDialog.editYearField.text = year || "";
                                            editDialog.selectedArtistId = artistId || "";
                                            editDialog.open();
                                        }
                                    }
                                }

                                Button {
                                    icon.source: "qrc:/icons/trash.svg"
                                    Layout.preferredWidth: parent.buttonSize
                                    Layout.preferredHeight: parent.buttonSize
                                    background: Rectangle {
                                        radius: 4
                                        color: "#333"
                                    }
                                    onClicked: {
                                        confirmDeleteDialog.songId = _id
                                        confirmDeleteDialog.open()
                                    }
                                }

                                Button {
                                    icon.source: "qrc:/icons/eye.svg"
                                    Layout.preferredWidth: parent.buttonSize
                                    Layout.preferredHeight: parent.buttonSize
                                    background: Rectangle {
                                        radius: 4
                                        color: "#333"
                                    }
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
                        color: Material.foreground
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
                                    title: songs[i].title || "",
                                    album: songs[i].album || "",
                                    genre: songs[i].genre || "",
                                    year: songs[i].year !== undefined && songs[i].year !== null ? String(songs[i].year) : "",
                                    artistId: songs[i].artistId || "",
                                    artistName: songs[i].artistName || "",
                                    fileUrl: songs[i].fileUrl || ""
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
            color: Material.background

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 10

                Label {
                    text: "Song Details"
                    font.bold: true
                    font.pointSize: 18
                    color: Material.foreground
                    Layout.alignment: Qt.AlignHCenter
                }

                Text { text: "Title: " + songTitle; font.pixelSize: 14; color: "#ccc" }
                Text { text: "Album: " + songAlbum; font.pixelSize: 14; color: "#ccc" }
                Text { text: "Artist: " + songArtist; font.pixelSize: 14; color: "#ccc" }
                Text { text: "Genre: " + songGenre; font.pixelSize: 14; color: "#ccc" }
                Text { text: "Year: " + songYear; font.pixelSize: 14; color: "#ccc" }

                Item { Layout.fillHeight: true }

                Button {
                    text: "Back to Music Library"
                    Layout.alignment: Qt.AlignHCenter
                    background: Rectangle {
                        radius: 4
                        color: "#333"
                    }
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
        property string selectedFilePath: ""
        property string selectedArtistId: ""
        property bool isAddingArtist: false
        standardButtons: Dialog.Ok | Dialog.Cancel

        ListModel { id: artistModel }

        ScrollView {
            id: addScroll
            anchors.fill: parent
            ColumnLayout {
                anchors.margins: 16
                spacing: 10
                width: addScroll.availableWidth
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

        MessageDialog {
            id: validationErrorDialog
            title: "Invalid input"
            text: ""
            buttons: MessageDialog.Ok
        }

        onOpened: loadArtists()

        onAccepted: {
            var missing = []

            if (!titleField.text.trim())
                missing.push("Song title")
            if (addDialog.isAddingArtist && !newArtistName.text.trim())
                missing.push("New artist name")
            if (!addDialog.isAddingArtist && !addDialog.selectedArtistId)
                missing.push("Artist")
            if (!addDialog.selectedFilePath)
                missing.push("Audio file")

            if (yearField.text.trim()) {
                var yearVal = parseInt(yearField.text)
                if (isNaN(yearVal) || yearVal < 1000 || yearVal > 2026)
                    missing.push("Year must be between 1000 and 2026")
            }

            if (missing.length > 0) {
                validationErrorDialog.text = "Please correct the following:\n• " + missing.join("\n• ")
                validationErrorDialog.open()
                return
            }

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
        height: 550
        standardButtons: Dialog.Ok | Dialog.Cancel
        property string songId: ""
        property string selectedArtistId: ""
        property bool isAddingArtist: false
        property alias editTitleField: internalEditTitleField
        property alias editAlbumField: internalEditAlbumField
        property alias editGenreField: internalEditGenreField
        property alias editYearField: internalEditYearField
        property string newArtistNameEdit: ""
        property string newArtistCountryEdit: ""
        property string newArtistGenreEdit: ""

        ScrollView {
            id: editScroll
            anchors.fill: parent
            ColumnLayout {
                anchors.margins: 16
                spacing: 10
                width: editScroll.availableWidth

                TextField { id: internalEditTitleField; placeholderText: "Song title"; Layout.fillWidth: true }
                TextField { id: internalEditAlbumField; placeholderText: "Album"; Layout.fillWidth: true }
                TextField { id: internalEditGenreField; placeholderText: "Genre"; Layout.fillWidth: true }
                TextField { id: internalEditYearField; placeholderText: "Year"; Layout.fillWidth: true }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    Label { text: "Artist:" }
                    ComboBox {
                        id: editArtistDropdown
                        Layout.fillWidth: true
                        textRole: "name"
                        model: artistModel
                        onActivated: {
                            editDialog.selectedArtistId = artistModel.get(currentIndex).id
                            editDialog.isAddingArtist = (editDialog.selectedArtistId === "new")
                        }
                    }
                }

                ColumnLayout {
                    visible: editDialog.isAddingArtist
                    spacing: 8
                    TextField {
                        placeholderText: "Artist name"
                        Layout.fillWidth: true
                        text: editDialog.newArtistNameEdit
                        onTextChanged: editDialog.newArtistNameEdit = text
                    }
                    TextField {
                        placeholderText: "Country"
                        Layout.fillWidth: true
                        text: editDialog.newArtistCountryEdit
                        onTextChanged: editDialog.newArtistCountryEdit = text
                    }
                    TextField {
                        placeholderText: "Artist genre"
                        Layout.fillWidth: true
                        text: editDialog.newArtistGenreEdit
                        onTextChanged: editDialog.newArtistGenreEdit = text
                    }
                }
            }
        }

        MessageDialog {
            id: validationErrorDialogEdit
            title: "Invalid input"
            text: ""
            buttons: MessageDialog.Ok
        }

        function sendEditRequest(finalArtistId) {
            var xhr = new XMLHttpRequest()
            xhr.open("PUT", "http://localhost:5000/api/songs/" + songId)
            xhr.setRequestHeader("Content-Type", "application/json")
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                    if (stackView.currentItem && stackView.currentItem.loadSongs)
                        stackView.currentItem.loadSongs()
                }
            }
            xhr.send(JSON.stringify({
                title: editTitleField.text,
                album: editAlbumField.text,
                genre: editGenreField.text,
                year: editYearField.text,
                artistId: finalArtistId
            }))
        }

        onOpened: {
            editDialog.isAddingArtist = false
            editDialog.newArtistNameEdit = ""
            editDialog.newArtistCountryEdit = ""
            editDialog.newArtistGenreEdit = ""

            var xhr = new XMLHttpRequest()
            xhr.open("GET", "http://localhost:5000/api/artists")
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                    var artists = JSON.parse(xhr.responseText)
                    artistModel.clear()
                    for (var i = 0; i < artists.length; i++) {
                        artistModel.append({ id: artists[i]._id, name: artists[i].name })
                    }
                    artistModel.append({ id: "new", name: "+ Add new artist" })

                    editDialog.selectedArtistId = editDialog.selectedArtistId || ""
                    editArtistDropdown.currentIndex = -1

                    for (var j = 0; j < artistModel.count; j++) {
                        if (artistModel.get(j).id === editDialog.selectedArtistId) {
                            editArtistDropdown.currentIndex = j
                            break
                        }
                    }
                }
            }
            xhr.send()
        }

        onAccepted: {
            var missing = []

            if (!editTitleField.text.trim())
                missing.push("Song title")

            if (editDialog.isAddingArtist) {
                if (!editDialog.newArtistNameEdit.trim())
                    missing.push("New artist name")
            } else if (!editDialog.selectedArtistId) {
                missing.push("Artist")
            }

            if (editYearField.text.trim()) {
                var yearVal = parseInt(editYearField.text)
                if (isNaN(yearVal) || yearVal < 1000 || yearVal > 2026)
                    missing.push("Year must be between 1000 and 2026")
            }

            if (missing.length > 0) {
                validationErrorDialogEdit.text = "Please correct the following:\n• " + missing.join("\n• ")
                validationErrorDialogEdit.open()
                return
            }

            if (editDialog.isAddingArtist) {
                var xhrArtist = new XMLHttpRequest()
                xhrArtist.open("POST", "http://localhost:5000/api/artists")
                xhrArtist.setRequestHeader("Content-Type", "application/json")
                xhrArtist.onreadystatechange = function() {
                    if (xhrArtist.readyState === XMLHttpRequest.DONE && xhrArtist.status === 201) {
                        var artist = JSON.parse(xhrArtist.responseText)
                        sendEditRequest(artist._id)
                    }
                }
                xhrArtist.send(JSON.stringify({
                    name: editDialog.newArtistNameEdit,
                    country: editDialog.newArtistCountryEdit,
                    genre: editDialog.newArtistGenreEdit
                }))
            } else {
                sendEditRequest(editDialog.selectedArtistId)
            }
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

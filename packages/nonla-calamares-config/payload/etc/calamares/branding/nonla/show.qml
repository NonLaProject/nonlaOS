import QtQuick 2.0
import calamares.slideshow 1.0

Presentation {
    id: presentation

    Timer {
        interval: 16000
        repeat: true
        onTriggered: presentation.goToNextSlide()
    }

    Slide {
        Image {
            id: welcomeImage
            source: "wallpaper.png"
            width: 560
            height: 315
            fillMode: Image.PreserveAspectCrop
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 16
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: welcomeImage.bottom
            anchors.topMargin: 18
            width: 620
            text: qsTr("Install nonlaOS with KDE Plasma and Vietnamese input defaults.")
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.Center
            color: "#173623"
            font.pixelSize: 18
        }
    }
}

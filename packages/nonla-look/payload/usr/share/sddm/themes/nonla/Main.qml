import QtQuick 2.15
import QtQuick.Layouts 1.15
import SddmComponents 2.0

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "#142018"

    Image {
        anchors.fill: parent
        source: "wallpaper.png"
        fillMode: Image.PreserveAspectCrop
        smooth: true
    }

    Rectangle {
        anchors.fill: parent
        color: "#800b130f"
    }

    ColumnLayout {
        anchors.centerIn: parent
        width: 360
        spacing: 18

        Image {
            Layout.alignment: Qt.AlignHCenter
            source: "boot_logo.png"
            sourceSize.width: 132
            sourceSize.height: 132
            fillMode: Image.PreserveAspectFit
            smooth: true
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "nonlaOS"
            color: "#f0e8c8"
            font.pixelSize: 34
            font.bold: true
        }

        TextBox {
            id: username
            Layout.fillWidth: true
            text: userModel.lastUser
            placeholderText: "Tên người dùng"
            focus: true
        }

        PasswordBox {
            id: password
            Layout.fillWidth: true
            placeholderText: "Mật khẩu"
            onAccepted: sddm.login(username.text, password.text, 0)
        }

        Button {
            Layout.fillWidth: true
            text: "Đăng nhập"
            onClicked: sddm.login(username.text, password.text, 0)
        }
    }
}

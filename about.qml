import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2

Pane {
    id: about

    Image {
        id: logo
        anchors.centerIn: parent
        width: parent.width / 2
        height: parent.height / 2
        anchors.verticalCenterOffset: -80
        fillMode: Image.PreserveAspectFit
        source: "/files/images/adjuster.png/"        
    }
    ColumnLayout {
        anchors.top: logo.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 20

        RowLayout {
            spacing: 20

            Label {
                id: version_label
                text: "Version"
                font.bold: true
                Layout.fillHeight: true
                Layout.rightMargin: 25
            }
            Text {
                id: version_text
                text: app_version
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                anchors.top: version_label.top
            }
        }
        RowLayout {
            spacing: 20

            Label {
                id: dev_label
                text: "Developer"
                font.bold: true
                Layout.fillHeight: true
                Layout.rightMargin: 8
            }
            Text {
                id: dev_text
                text: app_developer
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                anchors.top: dev_label.top
            }
        }

        RowLayout {
            id: desc
            spacing: 20

            Label {
                id: desc_label
                text: "Description"
                font.bold: true
                Layout.fillHeight: true
            }
            Text {
                id: desc_text
                text: app_description
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                anchors.top: desc_label.top
            }
        }
    }
}

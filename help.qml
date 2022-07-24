import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2

Pane {
    id: help
    padding: 0    
    property var map_help_content: {
        "tab": tab,
        "tab_detail": tab_detail,
        "tab_img": tab_img,
        "current": current,
        "current_img": current_img,
        "current_detail": current_detail,
        "target": target,
        "target_img": target_img,
        "target_detail": target_detail,
        "initial": initial,
        "initial_img": initial_img,
        "initial_detail": initial_detail,
        "cur_brightness": cur_brightness,
        "cur_brightness_img": cur_brightness_img,
        "cur_brightness_detail": cur_brightness_detail,
        "adjust_btn": adjust_btn,
        "adjust_btn_img": adjust_btn_img,
        "adjust_btn_detail": adjust_btn_detail
    }

    Component {
        id: tab

        Label {
            text: "Home"
            font.family: "Times"
            font.bold: true
            font.pixelSize: 16
        }
    }

    Component {
        id: tab_detail

        Label {
            text: "The initial page shows the current, target and initial times, current brightness as well as the adjust button following is their motive:"
            Layout.fillWidth: true
            wrapMode: Label.Wrap
        }
    }

    Component {
        id: tab_img

        Image {
            width: 400
            height: 400
            fillMode: Image.PreserveAspectFit
            source: "/files/images/main_window.PNG"
        }
    }

    Component {
        id: current

        Label {
            text: "Current :"
            font.pixelSize: 14
            font.weight: Font.DemiBold
        }
    }

    Component {
        id: current_img

        Image {
            fillMode: Image.Pad
            source: "/files/images/cur_time.PNG"
            Layout.alignment: Qt.AlignHCenter
        }
    }

    Component {
        id: current_detail

        Label {
            text: "As the name suggests it informes you about the current time of the system from the time the adjust mode was enabled."
            Layout.fillWidth: true
            wrapMode: Label.Wrap
        }
    }

    Component {
        id: target

        Label {
            text: "Target :"
            font.pixelSize: 14
            font.weight: Font.DemiBold
        }
    }

    Component {
        id: target_img

        Image {
            fillMode: Image.Pad
            source: "/files/images/target_time.PNG"
            Layout.alignment: Qt.AlignHCenter
        }
    }

    Component {
        id: target_detail

        Label {
            text: "This control shows the end time of the adjust mode (i.e the time when adjust mode will finish adjusting brightness)."
            Layout.fillWidth: true
            wrapMode: Label.Wrap
        }
    }
    Component {
        id: initial

        Label {
            text: "Initial :"
            font.pixelSize: 14
            font.weight: Font.DemiBold
        }
    }

    Component {
        id: initial_img

        Image {
            fillMode: Image.Pad
            source: "/files/images/initial_time.PNG"
            Layout.alignment: Qt.AlignHCenter
        }
    }

    Component {
        id: initial_detail

        Label {
            text: "This control shows the start time of the adjust mode (i.e the time at which you hit the adjust mode)."
            Layout.fillWidth: true
            wrapMode: Label.Wrap
        }
    }

    Component {
        id: cur_brightness

        Label {
            text: "Current Brightness :"
            font.pixelSize: 14
            font.weight: Font.DemiBold
        }
    }

    Component {
        id: cur_brightness_img

        Image {
            fillMode: Image.Pad
            source: "/files/images/cur_brightness.PNG"
            Layout.alignment: Qt.AlignHCenter
        }
    }

    Component {
        id: cur_brightness_detail

        Label {
            text: "This control shows you the current brightness level of the system. You can also use it to alter the brightness of your system."
            Layout.fillWidth: true
            wrapMode: Label.Wrap
        }
    }
    Component {
        id: adjust_btn

        Label {
            text: "Adjust Button :"
            font.pixelSize: 14
            font.weight: Font.DemiBold
        }
    }

    Component {
        id: adjust_btn_img

        Image {
            fillMode: Image.Pad
            source: "/files/images/adjust.PNG"
            Layout.alignment: Qt.AlignHCenter
        }
    }

    Component {
        id: adjust_btn_detail

        Label {
            text: "Last but not the least is the adjust button itself. It lets you enable/disable the adjust mode. When it is enabled the app will start adjusting the brightness of your system automatically in the background. The brightness will be adjusted as specified in the settings tab."
            Layout.fillWidth: true
            wrapMode: Label.Wrap
        }
    }

    property var settings_help_content: {
        "s_tab": s_tab,
        "s_tab_detail": s_tab_detail,
        "s_tab_img": s_tab_img,
        "day": day,
        "day_img": day_img,
        "day_detail": day_detail,
        "night": night,
        "night_img": night_img,
        "night_detail": night_detail,
        "min_max": min_max,
        "min_max_img": min_max_img,
        "min_max_detail": min_max_detail
    }

    Component {
        id: s_tab

        Label {
            text: "Settings"
            font.family: "Times"
            font.bold: true
            font.pixelSize: 16
        }
    }

    Component {
        id: s_tab_detail

        Label {
            text: "This page informs you about the various setting control like day, night, min and max settings following is their motive :"
            Layout.fillWidth: true
            wrapMode: Label.Wrap
        }
    }

    Component {
        id: s_tab_img

        Image {
            width: 400
            height: 400
            fillMode: Image.PreserveAspectFit
            source: "/files/images/settings_window.PNG"
        }
    }

    Component {
        id: day

        Label {
            text: "Day :"
            font.pixelSize: 14
            font.weight: Font.DemiBold
        }
    }

    Component {
        id: day_img

        Image {
            height: 120
            fillMode: Image.PreserveAspectFit
            source: "/files/images/day_settings.PNG"
            Layout.alignment: Qt.AlignHCenter
        }
    }

    Component {
        id: day_detail

        Label {
            text: "This is a group of two controls which are specific to day time: <br><br><b>Level</b>: specifies the amount of brightness level to be increased.<br><br><b>Time</b>: specifies after how many minutes should the brightness level be increased.<br><br>If we take above picture as our example then it means after every 1 minute 10 percent of brightness will increase until it times out ( specified by target time ) or until the maximum brightness is reached ( specified by max control )."
            Layout.fillWidth: true
            wrapMode: Label.Wrap
        }
    }

    Component {
        id: night

        Label {
            text: "Night :"
            font.pixelSize: 14
            font.weight: Font.DemiBold
        }
    }

    Component {
        id: night_img

        Image {
            height: 125
            fillMode: Image.PreserveAspectFit
            source: "/files/images/night_settings.PNG"
            Layout.alignment: Qt.AlignHCenter
        }
    }

    Component {
        id: night_detail

        Label {
            text: "This is also a group of two controls which are specific to night time.<br><br><b>Level</b>: It specifies the amount of brightness level to be decreased.<br><br><b>Time</b>: It specifies after how many minutes should the brightness level be decreased.<br><br> If we take above picture as our example then it means after every 30 minutes 20 percent of brightness will decrease until it times out ( specified by target time ) or until the minimum brightness is reached ( specified by min control )."
            Layout.fillWidth: true
            wrapMode: Label.Wrap
        }
    }

    Component {
        id: min_max

        Label {
            text: "Min & Max : "
            font.pixelSize: 14
            font.weight: Font.DemiBold
        }
    }

    Component {
        id: min_max_img

        Image {
            height: 80
            fillMode: Image.PreserveAspectFit
            source: "/files/images/min_max_settings.PNG"
            Layout.alignment: Qt.AlignHCenter
        }
    }

    Component {
        id: min_max_detail

        Label {
            text: "These control sets the minimum and maximum brightness of your system. When in adjust mode your system brightness will never bypass the limit specified by these control."
            Layout.fillWidth: true
            wrapMode: Label.Wrap
        }
    }

    SwipeView {
        id: swipe
        currentIndex: 0
        anchors.fill: parent

        Pane {
            width: swipe.width
            height: swipe.height

            ColumnLayout {
                id: column
                anchors.fill: parent
                anchors.topMargin: -5
                anchors.margins: 20

                ListView {
                    id: listView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    model: ListModel {
                        ListElement { type: "tab"; text: "tab"}
                        ListElement { type: "tab_detail"; text: "tab_detail"}
                        ListElement { type: "tab_img"; text: "tab_img"}
                        ListElement { type: "current"; text: "current"}
                        ListElement { type: "current_img"; text: "current_img" }
                        ListElement { type: "current_detail"; text: "current_detail" }
                        ListElement { type: "target"; text: "target"}
                        ListElement { type: "target_img"; text: "target_img" }
                        ListElement { type: "target_detail"; text: "target_detail" }
                        ListElement { type: "initial"; text: "initial"}
                        ListElement { type: "initial_img"; text: "initial_img" }
                        ListElement { type: "initial_detail"; text: "initial_detail" }
                        ListElement { type: "cur_brightness"; text: "cur_brightness"}
                        ListElement { type: "cur_brightness_img"; text: "cur_brightness_img" }
                        ListElement { type: "cur_brightness_detail"; text: "cur_brightness_detail" }
                        ListElement { type: "adjust_btn"; text: "adjust_btn"}
                        ListElement { type: "adjust_btn_img"; text: "adjust_btn_img" }
                        ListElement { type: "adjust_btn_detail"; text: "adjust_btn_detail" }
                    }

                    section.property: "type"
                    section.delegate: Pane {
                        width: listView.width
                        height: sectionLabel.implicitHeight + 20
                    }

                    delegate: Loader {
                        width: listView.width
                        sourceComponent: map_help_content[text]
                    }
                    ScrollIndicator.vertical: ScrollIndicator {}
                }
            }
        }

        Pane {
            width: swipe.width
            height: swipe.height

            ColumnLayout {
                anchors.fill: parent
                anchors.topMargin: -5
                anchors.margins: 20

                ListView {
                    id: settings_help
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    model: ListModel {
                        ListElement { type: "s_tab"; text: "s_tab"}
                        ListElement { type: "s_tab_detail"; text: "s_tab_detail"}
                        ListElement { type: "s_tab_img"; text: "s_tab_img"}
                        ListElement { type: "day"; text: "day"}
                        ListElement { type: "day_img"; text: "day_img"}
                        ListElement { type: "day_detail"; text: "day_detail"}
                        ListElement { type: "night"; text: "night"}
                        ListElement { type: "night_img"; text: "night_img"}
                        ListElement { type: "night_detail"; text: "night_detail"}
                        ListElement { type: "min_max"; text: "min_max"}
                        ListElement { type: "min_max_img"; text: "min_max_img"}
                        ListElement { type: "min_max_detail"; text: "min_max_detail"}
                    }

                    section.property: "type"
                    section.delegate: Pane {
                        width: settings_help.width
                        height: sectionLabel.implicitHeight + 20
                    }

                    delegate: Loader {
                        width: settings_help.width
                        sourceComponent: settings_help_content[text]
                    }
                    ScrollIndicator.vertical: ScrollIndicator {}
                }
            }
        }
    }
    PageIndicator {
        id: indicator
        count: swipe.count
        currentIndex: swipe.currentIndex

        anchors.top: swipe.top
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
    }
}

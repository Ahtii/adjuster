import QtQuick 2.6
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.2
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0

ApplicationWindow {

    id: root
    visible: true
    minimumWidth: 350
    minimumHeight: 500
    maximumWidth: 350
    maximumHeight: 500
    onSceneGraphInitialized: {

    }

    property string app_version: "1.0"
    property string app_description: "This app lets you change screen brightness on the go. It is also capable of adjusting brightness automatically in the background."
    property string app_developer: "Ahtisham Chishti"    

    // message box to show errors
    MessageDialog {
        id: err_msg
        title: "Error"
        visible: helpers.show_err_if_any()
        icon: MessageDialog.Critical
        onAccepted: adj.set_error("")
    }

    Row {        
        id: helpers
        visible: false

        // function to show error
        property string msg: ""
        function show_err_if_any(){
            msg = adj.get_error
            if (msg){
                err_msg.text = msg;
                return true;
            }
            return false;
        }

        // button focused in style
        function focus_in(btn, label){
            btn.color = "#7a847a"
            label.color = "white"

        }

        // button focused out style
        function focus_out(btn, label){
            btn.color = "white"
            label.color = "black"         
        }

        // when brightness slider value is changed
        function slider_value_changed(mouse){
            if (b_slider.pressed){
                var pos = mouse.x / b_slider.width * (b_slider.to - b_slider.from) + b_slider.from
                b_slider.value = pos                
                adj.set_brightness(b_slider.value)
                console.log("current brightness: "+adj.cur_level);
                console.log("slider value: "+b_slider.value);
            }
        }
    }   

    // setup systemtray for adjuster when minimized
    property bool first_time: false
    onVisibilityChanged: {
        if (!adj.get_state && visibility == 3){
            root.hide();
            systemtray.visible = true;
            if (!first_time){
                first_time = true;
                systemtray.showMessage("Adjuster running.","The adjuster is enabled in the background.",systemtray.iconSource,1000);
            }
        }
    }

    // system tray
    SystemTrayIcon {
         id: systemtray
         visible: false
         iconSource: "qrc:/files/images/adjuster.png"
         tooltip: "Current Brightness: " + adj.cur_level + "%\nTarget Time: " + adj.get_target_time;

         onActivated: {
             root.show()
             root.raise()
             root.requestActivate()
         }

         menu: Menu {
                   MenuItem {
                       text: qsTr("Quit")
                       onTriggered: Qt.quit()
                   }
               }
    }

    header: ToolBar {
        RowLayout {
            spacing: 20
            anchors.fill: parent

            ToolButton {
                contentItem: Image {
                    id: menu_label
                    fillMode: Image.Pad
                    source: home.depth > 1 ? "/files/images/back.png" : "/files/images/drawer.png"                    
                }
                background: Rectangle {
                    id: menu_back
                    color: "transparent"
                }
                onClicked: {
                    if (home.depth > 1){                        
                        home.pop()
                        list_view.currentIndex = -1
                    }else
                        drawer.open()
                }
                onHoveredChanged: {
                    if (hovered)
                        menu_back.color = "#D6D6D6"
                    else
                        menu_back.color = "transparent"
                }
            }

            Label {
                id: titleLabel
                text: list_view.currentItem ? list_view.currentItem.text : "Adjuster"
                font.pixelSize: 16
                horizontalAlignment: Qt.AlignHCenter
                leftPadding: -40
                Layout.fillWidth: true
            }

        }
    }

    Drawer {
        id: drawer
        width: Math.min(root.width, root.height) / 3 * 2
        height: root.height
        interactive: home.depth === 1

        ListView {
            id: list_view
            focus: true
            currentIndex: -1
            anchors.fill: parent

            delegate: ItemDelegate {
                width: parent.width
                text: model.title
                highlighted: ListView.isCurrentItem
                onClicked: {
                    list_view.currentIndex = index                                                            
                    home.push(model.source)
                    drawer.close()
                }
                onHoveredChanged: {
                    list_view.currentIndex = index                    
                }
            }

            model: ListModel {                      
                  ListElement { title: "Settings"; source: "settings.qml" }
                  ListElement { title: "About"; source: "about.qml" }
                  ListElement { title: "Help"; source: "help.qml" }
            }

            ScrollIndicator.vertical: ScrollIndicator {}
        }
    }

    StackView {
        id: home
        anchors.fill: parent

        initialItem: Pane {
            id: home_pane

            GridLayout {
                id: counter
                anchors.centerIn: parent
                width: home_pane.availableWidth / 2
                height: home_pane.availableHeight / 2
                anchors.horizontalCenterOffset: -50
                anchors.verticalCenterOffset: -50
                columnSpacing: 20
                columns: 2
                ColumnLayout{
                    Layout.leftMargin: 10
                    Label {
                        id: current_time_label
                        text: "Current"
                        Layout.alignment: Qt.AlignCenter
                        font.pixelSize: 18
                        font.letterSpacing: 1
                        bottomPadding: 10
                    }
                    Text {
                        id: current_time
                        text: adj.get_current_time
                        font.pixelSize: 25
                    }
                }
                ColumnLayout{
                    Layout.rightMargin: 10
                    Label {
                        id: target_time_label
                        text: "Target"
                        Layout.alignment: Qt.AlignCenter
                        font.pixelSize: 18
                        font.letterSpacing: 1
                        bottomPadding: 10
                    }
                    Text {
                        id: target_time
                        text: adj.get_target_time
                        font.pixelSize: 25
                    }
                }
                ColumnLayout{
                    Layout.leftMargin: 10
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    Layout.columnSpan: 2
                    Label {
                        id: initial_time_label
                        text: "Initial"
                        Layout.alignment: Qt.AlignCenter
                        font.pixelSize: 15
                        font.letterSpacing: 1
                        bottomPadding: 10
                    }
                    Text {
                        id: initial_time
                        text: adj.get_initial_time
                        font.pixelSize: 18
                    }
                }
            }

            ColumnLayout {
                id: slider_group
                anchors.margins: 20
                anchors.top: counter.bottom + 20
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                Label {
                    id: slider_label
                    text: "Current Brightness"
                    Layout.alignment: Qt.AlignHCenter
                    font.pixelSize: 15
                    bottomPadding: 15
                }

                Slider {
                    Layout.fillWidth: true
                    id: b_slider
                    from: 0
                    to: 100
                    value: adj.cur_level
                    stepSize: 1.0
                    enabled: adj.get_state
                    background: Rectangle {
                        implicitHeight: 4
                        height: implicitHeight
                        radius: 2
                        color: "silver"
                        Rectangle {
                            width: b_slider.visualPosition * parent.width
                            height: parent.height
                            color: "skyblue"
                            radius: 2
                        }
                    }
                    handle: Rectangle {
                        x: b_slider.leftPadding + b_slider.visualPosition * (b_slider.availableWidth - width)
                        y: -10
                        implicitWidth: 25
                        implicitHeight: 25
                        radius: 15
                        color: b_slider.pressed ? "skyblue" : "white"
                        border.color: "skyblue"
                        border.width: 3
                    }
                    /*MouseArea {
                        hoverEnabled: true
                        anchors.fill:  b_slider
                        onEntered: { cursorShape = Qt.PointingHandCursor }
                        onExited: { cursorShape = Qt.ArrowCursor }
                        onPressed: { b_slider.pressed = true; }
                        onReleased: { b_slider.pressed = false; }
                        onMouseXChanged: { helpers.slider_value_changed(mouse); }
                    }*/
                    onValueChanged: {
                        adj.set_brightness(b_slider.value);
                    }
                }
                Label {
                    id: cur_brightness_label
                    text: b_slider.value.toFixed(0)// + " %"
                    Layout.leftMargin: b_slider.handle.x + b_slider.handle.width / 4
                    font.pixelSize: 14
                    Layout.topMargin: -15
                }
            }
        }
    }

    footer: ToolBar {        
        ColumnLayout {
            anchors.margins: 20
            anchors.fill: parent
            // buttons

            RowLayout {
                id: adjust_btn_layout
                anchors.bottom: status.top
                Layout.alignment: Qt.AlignHCenter
                Rectangle {
                    id: adjust_btn
                    Layout.minimumWidth: 50
                    Layout.minimumHeight: 50
                    Label {
                        id: adjust_btn_label
                        text: adj.get_adjust_label
                        font.pixelSize: 14
                        anchors.centerIn: adjust_btn
                    }
                    border.color: "gray"
                    radius: 30
                    border.width: 2
                    MouseArea {
                        id: adjuster_mouse_area
                        anchors.fill: adjust_btn
                        hoverEnabled: true
                        onEntered: { helpers.focus_in(adjust_btn, adjust_btn_label); }
                        onExited: { helpers.focus_out(adjust_btn, adjust_btn_label); }
                        onClicked: {
                            adj.adjust();
                            adj.init_status(3);
                        }
                    }
                }
                DropShadow {
                    anchors.fill: adjust_btn
                    radius: 10.0
                    samples: 20
                    color: "gray"
                    source: adjust_btn
                }
            }

            // status
            Label {
                id: status
                anchors.bottom: parent.bottom
                text: adj.get_status
                topPadding: -5
                bottomPadding: -10
            }
        }
        background: Rectangle { color: "transparent" }
    }
}

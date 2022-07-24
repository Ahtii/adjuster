import QtQuick 2.6
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtGraphicalEffects 1.0

Pane {
    id: settings
    padding: 0

    function load_settings(){
        var new_settings = {};
        new_settings = adj.load();
        night_level_box.value = new_settings['e_level'];
        night_time_box.value = new_settings['e_time'];
        day_level_box.value = new_settings['m_level'];
        day_time_box.value = new_settings['m_time'];
        min_box.value = new_settings['min'];
        max_box.value = new_settings['max'];
    }

    // set default app settings
    function default_settings(){
        var old_settings = {
                            'e_level': 10,
                            'e_time': 60,
                            'm_level': 10,
                            'm_time': 60,
                            'min': 20,
                            'max': 80
                           };
        night_level_box.value = old_settings['e_level'];
        night_time_box.value = old_settings['e_time'];
        day_level_box.value = old_settings['m_level'];
        day_time_box.value = old_settings['m_time'];
        min_box.value = old_settings['min'];
        max_box.value = old_settings['max'];
        adj.save(old_settings);
    }

    function latest_settings(){
        var settings = {
                          'e_level': night_level_box.value,
                          'e_time': night_time_box.value,
                          'm_level': day_level_box.value,
                          'm_time': day_time_box.value,
                          'min': min_box.value,
                          'max': max_box.value
                       };
        return settings;
    }

    Component.onCompleted: {
        load_settings();
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 20

        // day group box
        GroupBox {
            id: day_group
            Layout.fillWidth: true
            label: Label{
                id: day_title
                text: "Day"
                font.pixelSize: 15
                leftPadding: 10
            }
            GridLayout {
                anchors.fill: parent
                id: day_grid
                columns: 2
                Label {
                    id: day_level_label
                    text: "Level"
                }
                SpinBox {
                    id: day_level_box
                    Layout.minimumWidth: 100
                    Layout.alignment: Qt.AlignRight
                    value: 10
                    from: 10
                    to: 30
                    stepSize: 10
                    enabled: adj.get_state
                    editable: true
                    textFromValue: function(value){ return value + " %"; }
                    contentItem: TextInput {
                          text: day_level_box.textFromValue(day_level_box.value, day_level_box.locale)
                          horizontalAlignment: Qt.AlignHCenter
                          verticalAlignment: Qt.AlignVCenter
                          onActiveFocusChanged: {
                              if (activeFocusItem.parent == day_level_box){
                                  day_level_box.textFromValue = function(value){ return value };
                                  color = "green";
                                  font.pixelSize = font.pixelSize + 3
                              }else{
                                  day_level_box.textFromValue = function(value){ return value + " %" };
                                  color = "";
                                  font.pixelSize = font.pixelSize - 3
                              }
                          }
                          onEditingFinished: { day_level_box.focus = false; }
                    }
                }
                Label {
                    id: day_time_label
                    text: "Time"
                }
                SpinBox {
                    id: day_time_box
                    Layout.minimumWidth: 100
                    Layout.alignment: Qt.AlignRight
                    value: 120
                    from: 1
                    to: 120
                    enabled: adj.get_state
                    editable: true
                    textFromValue: function(value){ return value + " min"; }
                    contentItem: TextInput {
                          text: day_time_box.textFromValue(day_time_box.value, day_time_box.locale)
                          horizontalAlignment: Qt.AlignHCenter
                          verticalAlignment: Qt.AlignVCenter
                          onActiveFocusChanged: {
                              if (activeFocusItem.parent == day_time_box){
                                  day_time_box.textFromValue = function(value){ return value };
                                  color = "green";
                                  font.pixelSize = font.pixelSize + 3
                              }else{
                                  day_time_box.textFromValue = function(value){ return value + " min" };
                                  color = "";
                                  font.pixelSize = font.pixelSize - 3
                              }
                          }
                          onEditingFinished: { day_time_box.focus = false; }
                    }
                }
            }
        }

        // night group box
        GroupBox {
            id: night_group
            Layout.fillWidth: true
            anchors.top: day_group.bottom
            anchors.topMargin: 15
            label: Label{
                id: night_title
                text: "Night"
                font.pixelSize: 15
                leftPadding: 10
            }
            GridLayout {
                anchors.fill: parent
                id: night_grid
                columns: 2
                Label {
                    id: night_level_label
                    text: "Level"
                }
                SpinBox {
                    Layout.minimumWidth: 100
                    Layout.alignment: Qt.AlignRight
                    id: night_level_box
                    value: 10
                    from: 10
                    to: 30
                    stepSize: 10
                    enabled: adj.get_state
                    editable: true
                    textFromValue: function(value){ return value + " %"; }
                    contentItem: TextInput {
                          text: night_level_box.textFromValue(night_level_box.value, night_level_box.locale)
                          horizontalAlignment: Qt.AlignHCenter
                          verticalAlignment: Qt.AlignVCenter
                          onActiveFocusChanged: {
                              if (activeFocusItem.parent == night_level_box){
                                  night_level_box.textFromValue = function(value){ return value };
                                  color = "green";
                                  font.pixelSize = font.pixelSize + 3
                              }else{
                                  night_level_box.textFromValue = function(value){ return value + " %" };
                                  color = "";
                                  font.pixelSize = font.pixelSize - 3
                              }
                          }
                          onEditingFinished: { night_level_box.focus = false; }
                    }
                }
                Label {
                    id: night_time_label
                    text: "Time"
                }
                SpinBox {
                    Layout.minimumWidth: 100
                    Layout.alignment: Qt.AlignRight
                    id: night_time_box
                    editable: true
                    value: 120
                    from: 1
                    to: 120
                    enabled: adj.get_state
                    textFromValue: function(value){ return value + " min"; }
                    contentItem: TextInput {
                          text: night_time_box.textFromValue(night_time_box.value, night_time_box.locale)
                          horizontalAlignment: Qt.AlignHCenter
                          verticalAlignment: Qt.AlignVCenter
                          onActiveFocusChanged: {
                              if (activeFocusItem.parent == night_time_box){
                                  night_time_box.textFromValue = function(value){ return value };
                                  color = "green";
                                  font.pixelSize = font.pixelSize + 3
                              }else{
                                  night_time_box.textFromValue = function(value){ return value + " min" };
                                  color = "";
                                  font.pixelSize = font.pixelSize - 3
                              }
                          }
                          onEditingFinished: { night_time_box.focus = false; }
                    }
                }
            }
        }

        // min max brightness group box
        RowLayout {
            id: min_max_group
            Layout.fillWidth: true
            anchors.top: night_group.bottom
            anchors.topMargin: 15
            spacing: 30
            Layout.alignment: Qt.AlignCenter
            ColumnLayout {
                id: min_max_grid
                Label {
                    id: min_label
                    text: "Min"
                    Layout.alignment: Qt.AlignCenter
                }
                SpinBox {
                    id: min_box
                    Layout.minimumWidth: 100
                    value: 20
                    from: 10
                    to: 30
                    stepSize: 10
                    enabled: adj.get_state
                    editable: true
                    textFromValue: function(value){ return value + " %"; }
                    contentItem: TextInput {
                          text: min_box.textFromValue(min_box.value, min_box.locale)
                          horizontalAlignment: Qt.AlignHCenter
                          verticalAlignment: Qt.AlignVCenter
                          onActiveFocusChanged: {
                              if (activeFocusItem.parent == min_box){
                                  min_box.textFromValue = function(value){ return value };
                                  color = "green";
                                  font.pixelSize = font.pixelSize + 3
                              }else{
                                  min_box.textFromValue = function(value){ return value + " %" };
                                  color = "";
                                  font.pixelSize = font.pixelSize - 3
                              }
                          }
                          onEditingFinished: { min_box.focus = false; }
                    }
                }
            }
            ColumnLayout{
                Label {
                    id: max_label
                    text: "Max"
                    Layout.alignment: Qt.AlignCenter
                }
                SpinBox {
                    id: max_box
                    Layout.minimumWidth: 100
                    Layout.alignment: Qt.AlignRight
                    value: 80
                    from: 80
                    to: 100
                    stepSize: 10
                    enabled: adj.get_state
                    editable: true
                    textFromValue: function(value){ return value + " %"; }
                    contentItem: TextInput {
                          text: max_box.textFromValue(max_box.value, max_box.locale)
                          horizontalAlignment: Qt.AlignHCenter
                          verticalAlignment: Qt.AlignVCenter
                          onActiveFocusChanged: {
                              if (activeFocusItem.parent == max_box){
                                  max_box.textFromValue = function(value){ return value };
                                  color = "green";
                                  font.pixelSize = font.pixelSize + 3
                              }else{
                                  max_box.textFromValue = function(value){ return value + " %" };
                                  color = "";
                                  font.pixelSize = font.pixelSize - 3
                              }
                          }
                          onEditingFinished: { max_box.focus = false; }
                    }
                }
            }
        }
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: settings.width / 2
            Layout.bottomMargin: -15
            RowLayout {
                id: default_btn_layout
                Rectangle {
                    id: default_btn
                    Layout.minimumWidth: 60
                    Layout.minimumHeight: 30
                    Label {
                        id: default_btn_label
                        text: "Default"
                        font.pixelSize: 12
                        parent: default_btn
                        anchors.centerIn: default_btn
                    }
                    border.color: "#7a847a"
                    radius: 30
                    border.width: 1
                    enabled: adj.get_state
                    MouseArea {
                        id: default_mouse_area
                        anchors.fill: default_btn
                        hoverEnabled: true
                        onEntered: { helpers.focus_in(default_btn, default_btn_label); }
                        onExited: { helpers.focus_out(default_btn, default_btn_label); }
                        onClicked: {
                            default_settings();
                            adj.init_status(2);
                        }
                    }
                }
                DropShadow {
                    anchors.fill: default_btn
                    radius: 6.0
                    samples: 20
                    color: "gray"
                    source: default_btn
                }
             }
            RowLayout {
                id: save_btn_layout
                Rectangle {
                    id: save_btn
                    Layout.minimumWidth: 60
                    Layout.minimumHeight: 30
                    Layout.leftMargin: parent.width / 2 - 12
                    Label {
                        id: save_btn_label
                        text: "Save"
                        font.pixelSize: 12
                        anchors.centerIn: save_btn
                    }
                    border.color: "#7a847a"
                    radius: 30
                    border.width: 1
                    enabled: adj.get_state
                    MouseArea {
                        id: save_mouse_area
                        anchors.fill: save_btn
                        hoverEnabled: true
                        onEntered: { helpers.focus_in(save_btn, save_btn_label); }
                        onExited: { helpers.focus_out(save_btn, save_btn_label); }
                        onClicked: {
                            adj.save(latest_settings());
                            adj.init_status(1);
                        }
                    }
                }
                DropShadow {
                    anchors.fill: save_btn
                    radius: 6.0
                    samples: 20
                    color: "gray"
                    source: save_btn
                }
            }
        }
    }
}

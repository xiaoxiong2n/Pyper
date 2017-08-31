import QtQuick 2.3
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.3
import QtQuick.Window 2.2
import QtQuick.Layouts 1.1
import QtQml.Models 2.2
import QtGraphicalEffects 1.0

import "../popup_messages"
import "../basic_types"
import "../help"
import "../style"
import "../config"


ApplicationWindow {
    id: main
    title: "Pyper"
    width: 880
    height: 700

    menuBar: MenuBar {
        id: pyperTopMenuBar

        Menu {
            title: qsTr("File")
            MenuItem {
                text: qsTr("&Open")
                shortcut: "Ctrl+O"
                onTriggered: {
                    if (py_iface.open_video()) {
                        infoScreen.flash(2000);
                        if (tabs){
                            if (previewTab) {
                                if (previewTab.wasLoaded) {
                                    previewTab.children[0].reload(); // Using children[0] because direct call doesn't work
                                    previewTab.children[0].disableControls();
                                }
                            }
                            if (trackTab) {
                                if (trackTab.wasLoaded) {
                                    trackTab.children[0].reload(); // Using children[0] because direct call doesn't work
                                }
                            }
                        }
                    }
                }
            }
            MenuItem {
                text: qsTr("Exit")
                onTriggered: Qt.quit();
            }
        }
        Menu {
            id: trackingAlgorithmMenu
            title: qsTr("Tracking Method")
            AlgorithmMenuItem { id: algo1; checked:true; text: "Open field"; className: "GuiTracker"; exclusiveGroup: trackingAlgorithmExclusiveGroup; pythonObject: py_iface}
            AlgorithmMenuItem { id: algo2; text: "Pupil tracking"; className: "PupilGuiTracker"; exclusiveGroup: trackingAlgorithmExclusiveGroup; pythonObject: py_iface}
            MenuSeparator { }
            MenuItem {
                text: qsTr("Add custom")
                onTriggered: {
                    var codeWindow = Qt.createComponent("CodeWindow.qml");
                    if(codeWindow.status === Component.Ready) {
                        var win = codeWindow.createObject(main);
                        win.algorithmsMenu = trackingAlgorithmMenu;
                        win.algorithmsExclusiveGroup = trackingAlgorithmExclusiveGroup;
                        win.pythonObject = py_iface;
                        win.show();
                    } else {
                        console.log("Code Window error, Status:", codeWindow.status, codeWindow.errorString());
                    }
                }
            }
            MenuSeparator { }
        }
        Menu {
            title: qsTr("Help")
            MenuItem {
                text: qsTr("Program documentation")
                onTriggered: {
                    helpWindow.url = "http://pyper.readthedocs.io/en/latest/";
                    helpWindow.visible = true;
                }
            }

            MenuItem {
                text: qsTr("Help on current tab")
                onTriggered: {
                    var currentTab = tabs.getTab(tabs.currentIndex).title;
                    if (currentTab === "Welcome") {
                        helpWindow.url = "http://pyper.readthedocs.io/en/latest/";
                    } else if (currentTab === "Preview") {
                        helpWindow.url = "http://pyper.readthedocs.io/en/latest/gettingStarted.html#preview";
                    } else if (currentTab === "Track") {
                        helpWindow.url = "http://pyper.readthedocs.io/en/latest/gettingStarted.html#tracking";
                    } else if (currentTab === "Record") {
                        helpWindow.url = "http://pyper.readthedocs.io/en/latest/gettingStarted.html#recording";
//                    } else if (currentTab === "Calibration") {
//                    helpWindow.url = "";
                    } else if (currentTab === "Analyse") {
                        helpWindow.url = "http://pyper.readthedocs.io/en/latest/gettingStarted.html#analysis";
                    }
                    helpWindow.visible = true;
                }
            }
        }
    }
    ExclusiveGroup {
        id: trackingAlgorithmExclusiveGroup
    }

    Rectangle{
        id: mainMenuBar
        width: 70
        height: parent.height
//        RadialGradient {
//            anchors.fill: parent
//            verticalRadius: parent.height * 2
//            horizontalRadius: parent.width
//            gradient: Gradient {
//                GradientStop {
//                    position: 0.0;
//                    color: theme.background;
//                }
//                GradientStop {
//                    position: 0.5;
//                    color: theme.frameBorder;
//                }
//            }
//        }

        Timer {
            id: timer
        }
        function checkPathLoaded(idx){
            if (py_iface.is_path_selected()){
                tabs.currentIndex = idx;
            } else {
                errorScreen.flash(2000);
            }
        }

        Image{
           anchors.fill: parent
           source: imageHandler.getPath("menu_bar.png")
        }
        Column {
            spacing: 15
            anchors.fill: parent
            CustomToolButton{
                id: welcomeTabBtn
                anchors.left: parent.left
                anchors.right: parent.right
                height: width * 1.25

                active: welcomeTab.visible

                text: "Welcome"
                tooltip: "Switch to welcome mode"
                iconSource: iconHandler.getPath("welcome.png")
                onClicked: tabs.currentIndex = 0
            }

            CustomToolButton{
                id: previewTabBtn
                anchors.left: parent.left
                anchors.right: parent.right
                height: width * 1.25

                active: previewTab.visible

                text: "Preview"
                tooltip: "Switch to preview mode"
                iconSource: iconHandler.getPath("preview.png")
                onClicked: { mainMenuBar.checkPathLoaded(1) }
            }
            CustomToolButton{
                id: trackTabBtn
                anchors.left: parent.left
                anchors.right: parent.right
                height: width * 1.25

                active: trackTab.visible

                text: "Track"
                tooltip: "Switch to tracking mode"
                iconSource: iconHandler.getPath("track.png")

                onClicked: { mainMenuBar.checkPathLoaded(2) }
            }
            CustomToolButton{
                id: recordTabBtn
                anchors.left: parent.left
                anchors.right: parent.right
                height: width * 1.25

                active: recordTab.visible

                text: "Record"
                tooltip: "Switch to recording mode"
                iconSource: iconHandler.getPath("camera.png")

                onClicked: { tabs.currentIndex = 3 }
            }
            CustomToolButton{
                id: calibrationBtn
                anchors.left: parent.left
                anchors.right: parent.right
                height: width * 1.25

                active: calibrationTab.visible

                text: "Calibration"
                tooltip: "Switch to camera calibration mode"
                iconSource: iconHandler.getPath("calibration.png")

                onClicked: { tabs.currentIndex = 4 }
            }
            CustomToolButton{
                id: analysisBtn
                anchors.left: parent.left
                anchors.right: parent.right
                height: width * 1.25

                active: analysisTab.visible

                text: "Analyse"
                tooltip: "Switch to analysis mode"
                iconSource: iconHandler.getPath("analyse.png")

                onClicked: { tabs.currentIndex = 5 }
            }
        }


    }
    Rectangle{
        id: mainUi
        color: theme.background
        width: parent.width - mainMenuBar.width
        x: mainMenuBar.width
        height: parent.height - log.height

        InfoScreen{
            id: infoScreen
            width: 400
            height: 200
            text: "Video selected\n Please proceed to preview or tracking"
            visible: false
            z: 1
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.verticalCenter
        }

        ErrorScreen{
            id: errorScreen
            width: 400
            height: 200
            text: "No video selected"
            visible: false
            z: 1
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.verticalCenter
        }

        TabView {
            id: tabs
            tabsVisible: false
            frameVisible: false
            anchors.fill: parent
            Tab {
                id: welcomeTab
                title: "Welcome"
                WelcomeTab {
                    id: welcomeWindow
                }
            }
            Tab {
                id: previewTab
                title: "Preview"
                PreviewTab {
                    id: previewWindow
                    objectName: "previewWindow"
                }
                property bool wasLoaded
                onLoaded: {wasLoaded = true}
            }
            Tab {
                id: trackTab
                title: "Track"
                TrackerTab {
                    id: trackerWindow
                    objectName: "Tracker"
                }
                property bool wasLoaded
                onLoaded: {wasLoaded = true}
            }
            Tab {
                id: recordTab
                title: "Record"
                RecorderTab{
                    id: recorderWindow
                }
            }
            Tab {
                id: calibrationTab
                title: "Calibrate"
                CalibrationTab{
                    id: calibrationWindow
                }
            }
            Tab {
                id: analysisTab
                title: "Analyse"
                AnalysisTab{
                    id: analysisWindow
                }
            }

            Tab {
                title: "Transcode"
            }
        }
    }
    TextArea {
        id: log
        objectName: "log"
        height: 50
        width: parent.width - mainMenuBar.width
        anchors.left:mainMenuBar.right
        anchors.top: mainUi.bottom
        style: TextAreaStyle{
            backgroundColor: theme.textBackground
            textColor: theme.text
            selectionColor: theme.terminalSelection
            selectedTextColor: theme.terminalSelectedText
        }
    }
    HelpWindow {
        id: helpWindow
    }
}
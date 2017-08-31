import QtQuick 2.3
import QtQml 2.0
import QtQuick.Controls 1.2

import "../popup_messages"
import "../basic_types"
import "../video"
import "../roi"
import "../style"
import "../config"

Rectangle {
    color: theme.background
    anchors.fill: parent

    function reload(){
        trackingControls.reload();
        vidTitle.reload();
    }

    onVisibleChanged: { if (visible){ reload() } }

    SplashScreen{
        id: splash
        width: 400
        height: 200
        text: "Loading, please wait."
        z: 1
        visible: false
        anchors.centerIn: trackerDisplay
    }
    ErrorScreen{
        id: videoErrorScreen
        objectName: "videoLoadingErrorScreen"

        anchors.centerIn: trackerDisplay
        width: 400
        height: 200

        text: "Loading video failed"
        visible: false
        z: 1
        onDoFlashChanged: {
            if (doFlash) {
                flash(3000)
            }
            doFlash = false
        }
    }

    Text {
        id: vidTitle
        anchors.topMargin: 10
        anchors.top: parent.top
        anchors.horizontalCenter: trackerDisplay.horizontalCenter

        color: theme.text
        text: py_iface.get_file_name()
        function reload(){
            text = py_iface.get_file_name();
        }

        style: Text.Raised
        font.bold: true
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 14
    }
    Video {
        id: trackerDisplay
        objectName: "trackerDisplay"

        width: 640
        height: 480

        anchors.margins: 10
        anchors.left: controlsColumn.right
        anchors.right: parent.right
        anchors.top: vidTitle.bottom
        anchors.bottom: parent.bottom

        source: "image://trackerprovider/img"

        RoiFactory {
            id: mouseRoi

            width: parent.imgWidth
            height: parent.imgHeight

            anchors.top: parent.top
            anchors.left: parent.left

            source: "../roi/EllipseRoi.qml"

            drawingMode: roiManager.drawingMode

            tracker_py_iface: py_tracker
            roiType: 'tracking'
        }

        RoiFactory {
            id: restrictionRoi

            width: parent.imgWidth
            height: parent.imgHeight

            anchors.top: parent.top
            anchors.left: parent.left

            source: "../roi/RectangleRoi.qml"

            drawingMode: roiManager.drawingMode

            tracker_py_iface: py_tracker
            roiType: 'restriction'
        }
        RoiFactory {
            id: measurementRoi

            width: parent.imgWidth
            height: parent.imgHeight

            anchors.top: parent.top
            anchors.left: parent.left

            source: "../roi/RectangleRoi.qml"

            drawingMode: roiManager.drawingMode

            tracker_py_iface: py_tracker
            roiType: 'measurement'
        }
    }

    Column {
        id: controlsColumn
        width: 140

        anchors.margins: 5
        anchors.top: parent.top
        anchors.left: parent.left
        // TODO: use SplitView

        spacing: 10

        Frame {
            id: controls
            height: row1.height + 20

            Row {
                id: row1

                anchors.centerIn: controls
                width: children[0].width *2 + spacing
                height: children[0].height
                spacing: 10

                CustomButton {
                    id: startTrackBtn

                    width: 45
                    height: width

                    iconSource: iconHandler.getPath("play.png")
                    pressedSource: iconHandler.getPath("play_pressed.png")
                    tooltip: "Start tracking"

                    onPressed:{ splash.visible = true; }
                    onClicked: { py_tracker.start() }
                    onReleased:{
                        py_tracker.load();
                        splash.visible = false;
                    }
                }
                CustomButton {
                    id: stopTrackBtn

                    width: startTrackBtn.width
                    height: width

                    iconSource: iconHandler.getPath("stop.png")
                    pressedSource: iconHandler.getPath("stop_pressed.png")
                    tooltip: "Stop tracking"

                    onClicked: py_tracker.stop()
                }
            }
        }
        TrackingControls {
            id: trackingControls
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: parent.spacing

            py_params_iface: py_iface
            py_tracking_iface: py_tracker

            visualisationOptions: ["Raw", "Diff", "Mask"]
        }
        CustomButton {
            id: roiManagerBtn

            width: 50
            height: width

            anchors.horizontalCenter: parent.horizontalCenter

            iconSource: iconHandler.getPath("roi.png")

            tooltip: "Open ROI manager"
            onClicked: {
                roiManager.visible = !roiManager.visible;
            }
        }
    }

    RoiManager {
        id: roiManager
        pythonObject: py_iface
        visible: false

        roisControlsModelsList: [
            RoiControlsModel { sourceRoi: mouseRoi; name: "Callback ROI"; drawingType: "ellipse"; drawingColor: theme.roiDefault; checked: true},
            RoiControlsModel { sourceRoi: restrictionRoi; name: "Restriction ROI"; drawingType: "rectangle"; drawingColor: 'red'},
            RoiControlsModel { sourceRoi: measurementRoi; name: "Measurement ROI"; drawingType: "rectangle"; drawingColor: 'orange'}
        ]
    }
}
import QtQuick 2.0
import Ubuntu.Components 1.1
import QtMultimedia 5.0

/*!
    \brief MainView with a Label and Button elements.
*/

MainView {
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "cameraapp.liu-xiao-guo"

    /*
     This property enables the application to change orientation
     when the device is rotated. The default is false.
    */
    //automaticOrientation: true

    // Removes the old toolbar and enables new features of the new header.
    useDeprecatedToolbar: false

    width: units.gu(60)
    height: units.gu(85)

    property var resolution

    // This function is used to get the writable private directory of this app
    function getPriateDirectory() {
        var sharepath = "/home/phablet/.local/share/";
        var path = sharepath + applicationName;
        console.log("path: " + path);
        return path;
    }

    Page {
        id: page
        title: i18n.tr("cameraapp")

        Camera {
            id: camera

            imageProcessing.whiteBalanceMode: CameraImageProcessing.WhiteBalanceFlash

            exposure {
                exposureCompensation: -1.0
                exposureMode: Camera.ExposurePortrait
            }

            flash.mode: Camera.FlashRedEyeReduction

            imageCapture {
                onImageCaptured: {
                    console.log("image captured! reqId: " + requestId)
                    image.source = preview  // Show the preview in an Image
                }

                onImageSaved: {
                    console.log("image has been saved: " + requestId);
                    console.log("saved path: " + path);
                    image.source = path;
                }
            }

            Component.onCompleted: {
                resolution = camera.viewfinder.resolution;
                console.log("resolution: " + resolution.width + " " + resolution.height);
            }
        }

        Row {
            id: container
            VideoOutput {
                id: video
                source: camera
                width: page.width
                height: page.height
                focus : visible // to receive focus and capture key events when visible
                orientation: -90

                //                Image {
                //                    id: photoPreview
                //                    anchors.fill: parent
                //                    rotation: -90
                //                }

                SwipeArea {
                    anchors.fill: parent
                    onSwipe: {
                        console.log("swipe happened!： " + direction)
                        switch (direction) {
                        case "left":
                            page.state = "image";
                            break
                        }
                    }
                }
            }

            Item {
                id: view
                width: page.width
                height: page.height

                Image {
//                    anchors.fill: parent
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.height
                    height: parent.width
                    id: image
                    rotation: 90
                    fillMode: Image.PreserveAspectFit
                }

                Text {
                    text: image.source
                    color:"red"
                    font.pixelSize: units.gu(2.5)
                    width: page.width
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                }

                SwipeArea {
                    anchors.fill: parent
                    onSwipe: {
                        console.log("swipe happened!： " + direction)
                        switch (direction) {
                        case "right":
                            page.state = "";
                            break
                        }
                    }
                }
            }
        }

        states: [
            State {
                name: "image"
                PropertyChanges {
                    target: container
                    x:-page.width
                }
                PropertyChanges {
                    target: capture
                    opacity:0
                }
            }
        ]

        transitions: [
            Transition {
                NumberAnimation { target: container; property: "x"; duration: 500
                    easing.type:Easing.OutSine}
                //                NumberAnimation { target: inputcontainer; property: "opacity"; duration: 200}
                NumberAnimation { target: capture; property: "opacity"; duration: 200}
            }
        ]

        Button {
            id: capture
            anchors.bottom: parent.bottom
            anchors.bottomMargin: units.gu(1)
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Capture"

            onClicked: {
                console.log("capture path: " + getPriateDirectory());
                camera.imageCapture.captureToLocation(getPriateDirectory());
                page.state = "image"
            }
        }
    }
}


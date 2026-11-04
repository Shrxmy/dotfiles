// Resident wallpaper: draws the wallpaper on the background layer and animates changes
// (circle growing from the center). Idle = one plain image per screen, no timers, no effects.
//   qs -c wallpaper -d                                   start (Hyprland autostart)
//   qs -c wallpaper ipc call wallpaper set /path/img     switch with transition
import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root

    // Saved by wallpaper.sh; Image follows the symlink.
    property string current: "file://" + Quickshell.env("HOME") + "/.local/state/wallpaper/current"

    IpcHandler {
        target: "wallpaper"
        function set(path: string): void {
            root.current = "file://" + path
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win
            required property var modelData
            screen: modelData
            WlrLayershell.layer: WlrLayer.Background
            WlrLayershell.namespace: "qs-wallpaper"
            exclusionMode: ExclusionMode.Ignore
            anchors { top: true; bottom: true; left: true; right: true }
            color: "#25222a"

            // Effect + mask buffers exist only while switching; idle is one plain Image.
            property bool busy: false

            function go(src) {
                if (grow.running || kick.running) { grow.stop(); kick.stop(); settle() } // jump to the newest target
                if (src === shown.source.toString()) { incoming.source = ""; busy = false; return }
                busy = true // effect must be visible before the animation starts, or it never draws
                incoming.source = src // transition starts once it has loaded
            }

            function settle() {
                shown.source = incoming.source // already decoded at the same size: instant
                incoming.source = "" // free the second copy
                mask.r = 0
                busy = false
            }

            Component.onCompleted: shown.source = root.current // not a binding: changes go through go()

            Connections {
                target: root
                function onCurrentChanged() { win.go(root.current) }
            }

            Image {
                id: shown
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                sourceSize: Qt.size(win.width, win.height) // never keep more pixels than the screen
                asynchronous: false // swap from the shared cache must land in the same frame
                cache: true
            }

            Image {
                id: incoming
                anchors.fill: parent
                visible: false // drawn through the mask effect only
                fillMode: Image.PreserveAspectCrop
                sourceSize: Qt.size(win.width, win.height)
                asynchronous: true
                cache: true
                onStatusChanged: {
                    if (status === Image.Ready && win.busy) kick.restart()
                    else if (status === Image.Error) { source = ""; win.busy = false } // unreadable: keep current
                }
            }

            Item {
                id: mask
                anchors.fill: parent
                visible: false
                layer.enabled: win.busy
                property real r: 0
                Rectangle {
                    x: mask.width / 2 - mask.r
                    y: mask.height / 2 - mask.r
                    width: mask.r * 2
                    height: width
                    radius: mask.r
                }
            }

            MultiEffect {
                anchors.fill: parent
                visible: win.busy
                source: incoming
                maskEnabled: true
                maskSource: mask
                maskThresholdMin: 0.5
                maskSpreadAtMin: 1.0 // soft edge on the circle
            }

            // A couple of frames for the freshly shown effect to set up (cached images load instantly).
            Timer { id: kick; interval: 50; onTriggered: grow.restart() }

            NumberAnimation {
                id: grow
                target: mask
                property: "r"
                from: 0
                to: Math.hypot(win.width, win.height) / 2
                duration: 800
                easing.type: Easing.OutCubic
                onFinished: win.settle()
            }
        }
    }
}

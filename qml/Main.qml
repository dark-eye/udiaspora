import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Qt.labs.settings 1.0
import QtWebEngine 1.7

import "components"
import "pages"

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'udiaspora-webapp.darkeye'
    automaticOrientation: true

    width: units.gu(45)
    height: units.gu(75)

    readonly property var version: "0.1.0"

    property var token: "4r45tg"

    // automatically anchor items to keyboard that are anchored to the bottom
    anchorToKeyboard: true

    PageStack {
        id: mainStack
    }

    property var mainWebProfile: WebEngineProfile {
		persistentCookiesPolicy: WebEngineProfile.ForcePersistentCookies
		storageName:"udiaspora"
        httpUserAgent: "Mozilla/5.0 (Ubports; CPU Ubuntu 16.04  like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Chrome/54.1"
    }

    Settings {
        id: appSettings
        property var instance
        property bool openLinksExternally: false
        property bool incognitoMode: false
        property bool hideBottomControls: false
    }

    QtObject {
		id:helperFunctions

		function getInstanceURL() {
			return appSettings.instance.indexOf("http") != -1 ? appSettings.instance : "https://" + appSettings.instance
		}
	}

    Component.onCompleted: {
        if ( appSettings.instance ) {
           mainStack.push(Qt.resolvedUrl("./pages/DiasporaWebview.qml"))
        }
        else {
            mainStack.push(Qt.resolvedUrl("./pages/InstancePicker.qml"))
        }
    }
}

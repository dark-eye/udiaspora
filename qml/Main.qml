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

    property var currentWebProfile: null
	property var proflieInstances : {}

    Settings {
        id: appSettings
        property var instance
        property var profileName: "udiaspora"
		property var profiles : [
			 "udiaspora"
		]
        property bool openLinksExternally: false
        property bool incognitoMode: false
        property bool hideBottomControls: false
    }

    QtObject {
		id:helperFunctions

		function getInstanceURL() {
			return appSettings.instance ? (appSettings.instance.indexOf("http") != -1 ? appSettings.instance : "https://" + appSettings.instance) : "";
		}

		function getWebProfile(name) {
			if(!root.proflieInstances) {
				root.proflieInstances = {};
			}
			if( !root.proflieInstances[name]) {
				helperFunctions.addWebProfile(name);
				if(appSettings.profiles.indexOf(name) == -1) {
					appSettings.profiles.push( name );
				}
			}

			return root.proflieInstances[name];
		}

		function addWebProfile(name) {
			if( !root.proflieInstances[name]) {
				root.proflieInstances[name] = webProfileComponent.createObject(root, {
						"storageName": name
				});
			}
		}

		function loadWebProfiles() {
			for(var i in appSettings.profiles) {
				helperFunctions.addWebProfile(appSettings.profiles[i]);
			}
		}

		function removeWebProfile(name) {
			delete(root.proflieInstances[name]);
			appSettings.profiles =  Object.getOwnPropertyNames(root.proflieInstances);
			console.log("Profile deleted : "+ name);
		}

		function changeWebProfile(name) {
			root.currentWebProfile = helperFunctions.getWebProfile(name);
			appSettings.profileName = name
		}
	}

	Component {
		id : webProfileComponent
		WebEngineProfile {
				persistentCookiesPolicy: WebEngineProfile.ForcePersistentCookies
				storageName: "udiaspora"
				httpUserAgent: "Mozilla/5.0 (Ubports; CPU Ubuntu 16.04  like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Chrome/54.1"
		}
	}

    Component.onCompleted: {
		helperFunctions.changeWebProfile( appSettings.profileName ? appSettings.profileName : "udiaspora");
		helperFunctions.loadWebProfiles();

        if ( appSettings.instance ) {
           mainStack.push(Qt.resolvedUrl("./pages/DiasporaWebview.qml"))
        }
        else {
            mainStack.push(Qt.resolvedUrl("./pages/InstancePicker.qml"))
        }
    }
}

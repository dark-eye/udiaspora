import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Web 0.2
import "../components"

Page {
	id: webviewPage
	width: parent.width
	height: parent.height

	header: Rectangle {
		color: UbuntuColors.orange
		width: parent.width * webView.loadProgress / 100
		height: units.gu(0.1)
		visible: webView.visible && webView.loading
	}

	Component {
		id: pickerComponent
		PickerDialog {}
	}

	WebView {
		id: webView
		width: parent.width
		height: parent.height
		visible: false
		onLoadProgressChanged: {
			progressBar.value = loadProgress
			visible = ( visible || loadProgress === 100 );
		}
		anchors.fill: parent
		url: helperFunctions.getInstanceURL()
		preferences.localStorageEnabled: true
		preferences.allowFileAccessFromFileUrls: true
		preferences.allowUniversalAccessFromFileUrls: true
		preferences.appCacheEnabled: true
		preferences.javascriptCanAccessClipboard: true
		preferences.allowUniversalAccessFromFileUrls: true
		
		incognito:settings.incognitoMode
		filePicker: pickerComponent

		contextualActions: ActionList {
			Action {
				id: linkAction
				text: i18n.tr("Copy Link")
				enabled: webView.contextualData.href.toString()
				onTriggered: Clipboard.push([webView.contextualData.href])
			}

			Action {
				id: imageAction
				text: i18n.tr("Copy Image")
				enabled: webView.contextualData.img.toString()
				onTriggered: Clipboard.push([webView.contextualData.img])
			}

			Action {
				text: i18n.tr("Open in browser")
				enabled: webview.contextualData.href.toString()
				onTriggered: linkAction.enabled ? Qt.openUrlExternally( webView.contextualData.href ) : Qt.openUrlExternally( webView.contextualData.img ) 
			}
		}


		// Open external URL's in the browser and not in the app
		onNavigationRequested: {
			console.log ( request.url, ("" + request.url).indexOf ( settings.instance ) !== -1 )
			if ( ("" + request.url).indexOf ( settings.instance ) !== -1 || !settings.openLinksExternally ) {
				request.action = 0
			} else {
				request.action = 1
				Qt.openUrlExternally( request.url )
			}
		}

		function goHome() {
			webView.url = helperFunctions.getInstanceURL();
		}
	}

	Rectangle {
		anchors.fill: parent
		visible: !webView.visible
		color: theme.palette.normal.background

		Label {
			id: progressLabel
			color: theme.palette.normal.backgroundText
			text: i18n.tr('Loading ') + settings.instance
			anchors.centerIn: parent
			textSize: Label.XLarge
		}

		ProgressBar {
			id: progressBar
			value: 0
			minimumValue: 0
			maximumValue: 100
			anchors.top: progressLabel.bottom
			anchors.horizontalCenter: parent.horizontalCenter
			anchors.topMargin: 10
		}

		Button {
			anchors.bottom: parent.bottom
			anchors.bottomMargin: height
			anchors.horizontalCenter: parent.horizontalCenter
			color: UbuntuColors.red
			text: "Choose another Instance"
			onClicked: {
				settings.instance = undefined
				mainStack.clear ()
				mainStack.push (Qt.resolvedUrl("./InstancePicker.qml"))
			}
		}
	}


	BottomEdge {
		id: instancBottomEdge
		visible: webView.visible
		height:units.gu(37)
		hint.text: i18n.tr("Add Post");
		hint.iconName: "go-up"
		hint.visible:visible
		preloadContent: true

		contentComponent: Component { 
			AddPost {
				Behavior on opacity {UbuntuNumberAnimation {duration:UbuntuAnimation.SlowDuration}}
				anchors.fill:instancBottomEdge
				filePickerComponent:pickerComponent
			}
		}
		
		onCommitCompleted: contentItem.resetURL();
		onCollapseCompleted: contentItem.resetURL();
	}

}

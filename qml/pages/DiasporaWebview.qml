
import QtQml 2.2
import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import QtGraphicalEffects 1.0
import Ubuntu.Web 0.2
import "../components"
import "../components/dialogs"

Page {
	id: webviewPage
	width: parent.width
	height: parent.height

	header:Item {
		height: 0
		visible: false
	}
	
	Component {
		id: pickerComponent
		PickerDialog {}
	}
	
	Item {
		id:webContainer
		anchors {
			top:parent.top
			left:parent.left
			right:parent.right
			bottom:bottomControls.top
		}
		MainWebView {
			id:webView
			url: helperFunctions.getInstanceURL()
			context:appWebContext
			incognito:false
			filePicker: pickerComponent
			confirmDialog: ConfirmDialog {}
			alertDialog: AlertDialog {}
			z: settings.incognitoMode ? -1 : 1
			onLoadProgressChanged: {
				progressBar.value = loadProgress
			}
		}
		MainWebView {
			id:webViewIncogito
			url: helperFunctions.getInstanceURL()
			context:incognitoWebContext
			incognito:true
			filePicker: pickerComponent
			confirmDialog: ConfirmDialog {}
			alertDialog: AlertDialog {}
			z: settings.incognitoMode ? 1 : -1
			onLoadProgressChanged: {
				progressBar.value = loadProgress
			}
			
		}
		InnerShadow {
			color: UbuntuColors.purple
			radius: 15
			samples: 5
			anchors.fill:webViewIncogito
			source:webViewIncogito
			fast:true
			horizontalOffset: 0
			verticalOffset: -2
			spread:0.6
			visible:settings.incognitoMode
			z:2
		}
	}


	Rectangle {
		id:loadingPage
		anchors.fill: parent
		visible: !webviewPage.currentView().visible
		color: theme.palette.normal.background

		onVisibleChanged: if(visible) {
			reloadButton.visible = false;
		}
		
		Timer {
			interval: 5000
			running: visible
			onTriggered: {
				reloadButton.visible = true;
			}
		}
		
		
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
			id:reloadButton
			visible:false
			anchors.top: progressBar.bottom
			anchors.topMargin: units.gu(2)
			anchors.horizontalCenter: parent.horizontalCenter
			color: UbuntuColors.blue
			width:height + units.gu(1)
			iconName:"reload"
			onClicked: {
				webviewPage.currentView().reload()
			}
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
	
	Rectangle {
		color: theme.pallete.highlighted.selected
		anchors.bottom:instancBottomEdge.status !== BottomEdge.Committed ? bottomControls.top : instancBottomEdge.top
		width: parent.width * webviewPage.currentView().loadProgress / 100
		height: units.gu(0.1)
		visible: webviewPage.currentView().visible && webviewPage.currentView().loading
		z:2
		layer.enabled: true
		layer.effect:DropShadow {
			 radius: 5
			 color:theme.palette.highlighted.selectedText
		}
	}

	BottomEdgeControlsHeader {
		id:bottomControls
		z:2
		anchors.bottom: parent.bottom
		visible: webviewPage.currentView().visible;
	}

	BottomEdge {
		id: instancBottomEdge
		visible: webviewPage.currentView().visible  && webviewPage.isOnDiaspora()
		height:units.gu(37)
		hint.iconName: "go-up"
		hint.visible:visible
		preloadContent: false
		contentComponent: Component { 
			AddPost {
				anchors.fill:instancBottomEdge
				height:instancBottomEdge.height
				width:instancBottomEdge.width
				filePickerComponent:pickerComponent
			}
		}

		onCommitStarted: contentItem.resetURL();
	}
	
	//========================== Functions =======================
	function currentView() {
		return  settings.incognitoMode ? webViewIncogito : webView;
	}
	
	function  isOnDiaspora() {
		return (currentView().url.toString().indexOf(settings.instance) !== -1)
	}
	
	function isLoggedin() {
		var loginPage = helperFunctions.getInstanceURL() + "/users/sign_in"
		return currentView().url != loginPage;
	}

}

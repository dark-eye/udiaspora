
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

	header: Rectangle {
		color: theme.pallete.highlighted.selected
		width: parent.width * webviewPage.currentView().loadProgress / 100
		height: units.gu(0.1)
		visible: webviewPage.currentView().visible && webviewPage.currentView().loading
		z:2
	}

	Component {
		id: pickerComponent
		PickerDialog {}
	}
	

	MainWebView {
		id:webView
		url: helperFunctions.getInstanceURL()
		context:appWebContext
		incognito:false
		filePicker: pickerComponent
 		confirmDialog: ConfirmDialog {}
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


	Rectangle {
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


	BottomEdge {
		id: instancBottomEdge
		visible: webView.visible
		height:units.gu(37)
		hint.text: i18n.tr("Add Post");
		hint.iconName: "go-up"
		hint.visible:visible
		hint.flickable: webviewPage.currentView()
		preloadContent: true
		regions: [
			BottomEdgeRegion {
				contentComponent: Component { 
					BottomEdgeControlsHeader {
						anchors.fill:instancBottomEdge
						title:i18n.tr("Controls")
						leadingActionBar {
							actions:[
								Action {
									text:i18n.tr("Collapse")
									iconName: "go-down"
									onTriggered: instancBottomEdge.collapse()
								}
							]
						}
					}
				}
				from:0
				to:0.16
			},
			BottomEdgeRegion {
				contentComponent: Component { 
					AddPost {
						anchors.fill:instancBottomEdge
						filePickerComponent:pickerComponent
					}
				}
				from:0.16
				to:1
			}
		]
		
		onCommitStarted: contentItem.resetURL();
	}
	
	//========================== Functions =======================
	function currentView() {
		return  settings.incognitoMode ? webViewIncogito : webView;
	}

}

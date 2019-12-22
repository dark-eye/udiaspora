import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3

import "../components"

Page {
	id: profilePickerPage
	anchors.fill: parent

	property bool searchRunning:false
	property var lastList: []
	property var updateTime: null
	property alias model: profileList.model

	header: PageHeader {
		id: header
		title: i18n.tr('Choose a Diaspora instance')
		StyleHints {
			foregroundColor: theme.palette.normal.backgroundText
				backgroundColor: theme.palette.normal.background
		}
		trailingActionBar {
			actions: [
				Action {
					iconName: "add"
					onTriggered: {
							if(!newInstanceInput.visible || newInstanceInput.displayText == "") {
								newInstanceInput.focus = newInstanceInput.visible = true
							} else {
								setProfile(newInstanceInput.displayText);
							}
					}
				}
			]
		}
	}

	TextField {
		id: newInstanceInput
		anchors.top: header.bottom
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.topMargin: height
		width: parent.width - height
		placeholderText: i18n.tr("Enter a name for the new profile")
		Keys.onReturnPressed:  setProfile(newInstanceInput.displayText)
	}


	ListView {
		id: profileList
		width: parent.width
		anchors.top: newInstanceInput.bottom
		anchors.topMargin: units.gu(2)
		anchors.bottom:parent.bottom
		clip:true
		delegate: InstanceItem {
			id:profileItem
			text:modelData
			status: root.currentWebProfile && root.currentWebProfile.storageName == modelData
			visible:modelData != null
			color : root.currentWebProfile && root.currentWebProfile.storageName == modelData ?
						theme.palette.highlighted.background :
						theme.palette.normal.background

			onClicked: {
				setProfile(text);
			}

			leadingActions: ListItemActions {
				actions: [
				Action {
					id: deleteAction
					objectName: "deleteAction"
					iconName: "delete"
					text: i18n.tr("Delete")
					onTriggered: {
						try {
							var profileToDelete = helperFunctions.getWebProfile(profileItem.text);
							profileToDelete.clearHttpCache();
							profileToDelete.clearAllVisitedLinks();
						} catch (e) {
							console.log("Faild when deleting profile: "+ e);
						}
						helperFunctions.removeWebProfile(profileItem.text);
						profilePickerPage.model = appSettings.profiles
					}
				}
				]
			}
		}
	}

	Label {
		id:noResultsLabel
		visible: !profileList.model  || !profileList.model.length
		anchors.centerIn: profileList;
		text:i18n.tr("No profile set yet");
		z:1
	}

	Label {
		anchors.bottom: parent.bottom
		anchors.horizontalCenter: parent.horizontalCenter
		text: i18n.tr("For now deleting a profile won't delete it`s disk data.")
		color:theme.palette.normal.negative
		font.pixelSize:units.gu(1.5)
	}

	//============================================ Functions ====================================

	function setProfile(profileName) {
		appSettings.profileName = profileName;
		helperFunctions.changeWebProfile(profileName);
		mainStack.pop();
	}

}

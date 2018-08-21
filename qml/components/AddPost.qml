/*
 * <one line to give the program's name and a brief idea of what it does.>
 * Copyright 2018  eran <email>
 * 
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License or (at your option) version 3 or any later version
 * accepted by the membership of KDE e.V. (or its successor approved
 * by the membership of KDE e.V.), which shall act as a proxy
 * defined in Section 14 of version 3 of the license.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Web 0.2

Page {
	
	property var filePickerComponent: null 
	
	header: PageHeader {
		z:1
		title:i18n.tr("Add Post")
		StyleHints {
			backgroundColor:theme.palette.normal.background
		}
		
		MouseArea {
			anchors.fill:parent
			z:-1
		}
		

		trailingActionBar {
			numberOfSlots: 4
			
			actions:[
				Action {
					text:i18n.tr("Go home")
					iconName:"home"
					onTriggered:webView.goHome();
				},
				Action {
					text:i18n.tr("Go Back")
					iconName:"back"
					enabled:webView.canGoBack
					onTriggered:webView.goBack()
				},
				Action {
					text: checked ? i18n.tr("Links open externally") : i18n.tr("Links open internally")
					iconName:checked ? "external-link" : "stock_link"
					checkable:true
					checked: settings.openLinksExternally
					onToggled:{
						settings.openLinksExternally = checked;
					}
				},
				Action {
					text: checked ? i18n.tr("Incongnito") : i18n.tr("None Incongito")
					iconName:checked ? "private-browsing" : "private-browsing-exit"
					checkable:true
					checked: settings.incognitoMode
					onToggled:{
						settings.incognitoMode = checked;
					}
				},
				Action {
					text:i18n.tr("Change Pod")
					iconName:"swap"
					onTriggered: {
						settings.instance = undefined
						mainStack.clear ()
						mainStack.push (Qt.resolvedUrl("../pages/InstancePicker.qml"))
					}				}
			]
		}
	}

	WebView {
		id: addPostWebView
		anchors.fill:parent
		visible:true
		preferences.localStorageEnabled: true
		preferences.appCacheEnabled: true
		preferences.javascriptCanAccessClipboard: true
        preferences.allowFileAccessFromFileUrls: true
        preferences.allowUniversalAccessFromFileUrls: true

        incognito:settings.incognitoMode
		
		url: helperFunctions.getInstanceURL() + "/status_messages/new"
		
		filePicker: pickerComponent
	}
	
	Rectangle {
		anchors.fill:parent
		z:-1
		color: theme.palette.normal.background
	}
	
	function resetURL() {
		var newPostURL =  helperFunctions.getInstanceURL() + "/status_messages/new";
		if(addPostWebView.url != newPostURL) {
			addPostWebView.url = newPostURL;
		}
	}

}

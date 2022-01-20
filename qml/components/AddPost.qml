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
import QtWebEngine 1.7
import "dialogs"

Page {
	id:_addPostPage
	property var filePickerComponent: null 
	
	anchors.fill:parent

	header:BottomEdgeControlsHeader {
		title: i18n.tr("Add Post")
		z:10
	}
	
	
	Loader {
		id:addPostWebViewLoader
		anchors.fill:parent
		active:webviewPage.isLoggedin()
		sourceComponent: active ? addPostComponent : undefined;
	}
	
	Component {
		id:addPostComponent
		MainWebView {
			id: addPostWebView
			anchors.fill:parent
			visible:false
			onLoadProgressChanged: {
				visible = ( visible || loadProgress == 100 )
			}
			
			profile:root.currentWebProfile

			url: helperFunctions.getInstanceURL() + "/status_messages/new"
			filePicker: pickerComponent
			confirmDialog: ConfirmDialog {}
			alertDialog: AlertDialog {}
			promptDialog:PromptDialog {}
			onLoadingChanged: if(!addPostWebView.loading) {
				_addPostPage.resetURL();
			}

		}
	}
	
	
	
	Rectangle {
		anchors.fill:parent
		z: -1

		color: theme.palette.normal.background
		Label {
			id:notLoggedInLbl
			anchors.centerIn:parent
			text: i18n.tr("Please log in")
			visible: !webviewPage.isLoggedin();

		}
		ActivityIndicator {
			id: addPostLoadingIndicator
			width: units.gu(4)
			anchors.centerIn:parent
			running: !webviewPage.isLoggedin() && (addPostWebViewLoader.item.loading)
			visible: running
		}
	}
	
	function resetURL() {
		var newPostURL =  helperFunctions.getInstanceURL() + "/status_messages/new";
		var streamURL =  helperFunctions.getInstanceURL() + "/stream";
		if(addPostWebViewLoader.item.url != newPostURL) {
			if(addPostWebViewLoader.item.url == streamURL && Math.random() > 0.5 ) {
				addPostWebViewLoader.item.url = helperFunctions.getInstanceURL() + "/mobile/toggle" ;
			} else {
				addPostWebViewLoader.item.url = newPostURL;
			}
		}
	}

}

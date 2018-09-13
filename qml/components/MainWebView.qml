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
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import QtGraphicalEffects 1.0
import Ubuntu.Web 0.2

WebView {
	id: webView
	width: parent.width
	height: parent.height
	visible: false
	property bool lastError:false
	
	onLoadProgressChanged: {
		visible = !(lastError && loadProgress == 100) && ( visible || loadProgress > 95 )
	}
	onLoadEvent:{
		lastError = event.isError
	}
	
	anchors.fill: parent
	
	preferences.localStorageEnabled: true
	preferences.allowFileAccessFromFileUrls: true
	preferences.allowUniversalAccessFromFileUrls: true
	preferences.appCacheEnabled: true
	preferences.javascriptCanAccessClipboard: true
	preferences.shrinksStandaloneImagesToFit: true
	fullscreen:true
	
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
			enabled: webView.contextualData.href.toString()
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

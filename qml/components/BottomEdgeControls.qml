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

Page {
	Rectangle {
		anchors.fill:parent
		z:-1
		color: theme.palette.normal.background
	}
    header: PageHeader {
		StyleHints {
			dividerColor:theme.palette.normal.background
		}
		leadingActionBar {
			actions: [
				Action {
					text:i18n.tr("Go Back")
					iconName:"back"
					visible:webView.canGoBack
					onTriggered:webView.goBack()
				}
			]
		}
		trailingActionBar {
			numberOfSlots: 1
			actions:[
				Action {
					text:i18n.tr("Links in external browser")
					iconName:checked ? "stock_link" : "external-link"
					checkable:true
					checked: settings.openLinksExternally
					onToggled:{
						settings.openLinksExternally = checked;
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
	
}

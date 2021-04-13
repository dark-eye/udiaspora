
import QtQuick 2.9
import Ubuntu.Components 1.3
import QtQuick.Controls 2.2 as QControls
import QtQuick.XmlListModel 2.0

Page {
	id:_page
	property alias message: msgText
	property alias messageBKColor: message.color
	Rectangle {
		id:message
		z:100
		clip:true
		opacity:0
		visible: opacity !== 0;
		Behavior on opacity { UbuntuNumberAnimation { duration:UbuntuAnimation.SlowDuration } }
		Behavior on height { UbuntuNumberAnimation { duration:UbuntuAnimation.SlowDuration } }
		
        height: visible ?  msgText.height : 0
		width:parent.width
		
		MouseArea {
			anchors.fill:parent
			onClicked:{
				message.opacity=0; 
			}
		}
		
		Timer {
			id:messageTimer
			repeat: false
			interval: msgText.text.length ? msgText.text.length * 60 : 1000
			onTriggered: { 
				message.opacity=0; 
			}
		}

        color: theme.palette.normal.raised
        Label {
			id:msgText
			anchors.centerIn: parent
			width:parent.width
            text: null
            color: theme.palette.normal.raisedText
            wrapMode:Text.Wrap
            horizontalAlignment:Text.AlignHCenter
            onTextChanged: { 
				messageTimer.restart(); 
				message.opacity=1; 
			}
        }
    }
}

/*
 * Copyright (C) 2021  Eran DarkEye Uzan
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * darkeye.ursses is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */


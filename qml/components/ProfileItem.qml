import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0

ListItem {
    id: task

    property var text: ""
	property var status: 0
	property var size: 0

    height: layout.height

    ListItemLayout {
        id: layout
        title.text: text
        subtitle.text: country ? i18n.tr("Location: %1").arg(country) : ""
        summary.text: host ? host : ""
        Image {
            id: icon
            source: iconSource
            width: units.gu(4)
            height: units.gu(4)
            SlotsLayout.position: SlotsLayout.Leading;
            anchors.verticalCenter: parent.verticalCenter
            visible: false
            onStatusChanged: if (status == Image.Ready) visible = true
        }
        Icon {
			name: "starred"
			visible : status != 0
			SlotsLayout.position: SlotsLayout.Last;
			width: units.gu(2)
		}

    }
    Component {
		id:starIcon
		Icon {
			width:units.gu(2)
			height:width
			name:"starred"
		}
	}
}

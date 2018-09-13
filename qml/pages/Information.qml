import QtQuick 2.0
import Ubuntu.Components 1.3

Page {

	header: PageHeader {
		id:infoHeader
		title: i18n.tr("About")

	}

	ListModel {
	id: infoModel
	}

	Component.onCompleted: {
		infoModel.append({ name: i18n.tr("Get the source"), url: "https://github.com/dark-eye/udiaspora" ,icon:"text-css-symbolic"})
		infoModel.append({ name: i18n.tr("Report issues"), url: "https://github.com/dark-eye/udiaspora/issues",icon:"dialog-warning-symbolic" })
		infoModel.append({ name: i18n.tr("GNU General Public License v3.0"), url: "https://github.com/dark-eye/udiaspora/blob/master/LICENSE",icon:"note" })
		infoModel.append({ name: i18n.tr("Contributors"), url: "https://github.com/dark-eye/udiaspora/graphs/contributors" ,icon:"contact-group"})
		infoModel.append({ name: i18n.tr("Based on uMastonauts webapp"), url: "https://github.com/ChristianPauly/uMastodon" ,icon:"info"})
		infoModel.append({ name: i18n.tr("Donate"), url: "https://www.patreon.com/darkeyeos", icon:"like" })
		infoModel.append({ name: i18n.tr("Telegram"), url: "https://t.me/uDiaspora", icon:"send" })
	}

	Column {
		id: aboutCloumn
		spacing:units.dp(2)
		width:parent.width

		Label { //An hack to add margin to the column top
			width:parent.width
			height:infoHeader.height *2
		}

		Image {
			anchors.horizontalCenter: parent.horizontalCenter
			height: Math.min(parent.width/2, parent.height/2)
			width:height
			source:"../../assets/logo.svg"
			layer.enabled: true
			layer.effect: UbuntuShapeOverlay {
				relativeRadius: 0.5
			}
			layer.sourceRect : Qt.rect(2,2,width-4,height-4)
		}
		Label {
			width: parent.width
			font.pixelSize: units.gu(5)
			font.bold: true
			color: theme.palette.normal.backgroundText
			horizontalAlignment: Text.AlignHCenter
			text: i18n.tr("uDiaspora WebApp")
		}

	}

	UbuntuListView {
		anchors {
			top: aboutCloumn.bottom
			bottom: parent.bottom
			left: parent.left
			right: parent.right
			topMargin: units.gu(2)
		}

		currentIndex: -1
		interactive: false

		model :infoModel
		delegate: ListItem {
			ListItemLayout {
			title.text : model.name
			Icon {
				width:units.gu(2)
				name:"external-link"
				SlotsLayout.position: SlotsLayout.Trailing;
			}
			Icon {
				width:units.gu(2)
				name:model.icon
				SlotsLayout.position: SlotsLayout.Leading;
			}
			}
			onClicked: Qt.openUrlExternally(model.url)


		}

	}

}

//  Converted to Swift 4 by Swiftify v4.2.20229 - https://objectivec2swift.com/
//
//  OpenHABSitemapPage.swift
//  HelloRestKit
//
//  Created by Victor Belov on 10/01/14.
//  Copyright (c) 2014 Victor Belov. All rights reserved.
//
//  Converted to Swift 4 by Tim Müller-Seydlitz and Swiftify on 06/01/18
//

import Foundation
import Fuzi
import os.log

class OpenHABSitemapPage: NSObject {
    var sendCommand: ((_ item: OpenHABItem, _ command: String?) -> Void)?
    var widgets: [OpenHABWidget] = []
    var pageId = ""
    var title = ""
    var link = ""
    var leaf = false

    init(pageId: String, title: String, link: String, leaf: Bool, widgets: [OpenHABWidget]) {
        super.init()
        self.pageId = pageId
        self.title = title
        self.link = link
        self.leaf = leaf
        var tempWidgets = [OpenHABWidget]()
        tempWidgets.flatten(widgets)
        self.widgets = tempWidgets
        self.widgets.forEach {
            $0.sendCommand = { [weak self] item, command in
                self?.sendCommand(item, commandToSend: command)
            }
        }
    }

    init(xml xmlElement: XMLElement) {
        super.init()
        for child in xmlElement.children {
            switch child.tag {
            case "widget": widgets.append(OpenHABWidget(xml: child))
            case "id": pageId = child.stringValue
            case "title": title = child.stringValue
            case "link": link = child.stringValue
            case "leaf": leaf = child.stringValue == "true" ? true : false
            default: break
            }
        }
        var tempWidgets = [OpenHABWidget]()
        tempWidgets.flatten(widgets)
        widgets = tempWidgets
        widgets.forEach {
            $0.sendCommand = { [weak self] item, command in
                self?.sendCommand(item, commandToSend: command)
            }
        }
    }

    init(pageId: String, title: String, link: String, leaf: Bool, expandedWidgets: [OpenHABWidget]) {
        super.init()
        self.pageId = pageId
        self.title = title
        self.link = link
        self.leaf = leaf
        widgets = expandedWidgets
        widgets.forEach {
            $0.sendCommand = { [weak self] item, command in
                self?.sendCommand(item, commandToSend: command)
            }
        }
    }

    private func sendCommand(_ item: OpenHABItem?, commandToSend command: String?) {
        guard let item = item else { return }

        os_log("SitemapPage sending command %{PUBLIC}@ to %{PUBLIC}@", log: OSLog.remoteAccess, type: .info, command ?? "", item.name)
        sendCommand?(item, command)
    }
}

extension OpenHABSitemapPage {
    func filter(_ isIncluded: (OpenHABWidget) throws -> Bool) rethrows -> OpenHABSitemapPage {
        let filteredOpenHABSitemapPage = OpenHABSitemapPage(pageId: pageId,
                                                            title: title,
                                                            link: link,
                                                            leaf: leaf,
                                                            expandedWidgets: try widgets.filter(isIncluded))
        return filteredOpenHABSitemapPage
    }
}

extension OpenHABSitemapPage {
    struct CodingData: Decodable {
        let pageId: String?
        let title: String?
        let link: String?
        let leaf: Bool?
        let widgets: [OpenHABWidget.CodingData]?

        private enum CodingKeys: String, CodingKey {
            case pageId = "id"
            case title
            case link
            case leaf
            case widgets
        }
    }
}

extension OpenHABSitemapPage.CodingData {
    var openHABSitemapPage: OpenHABSitemapPage {
        let mappedWidgets = widgets?.map { $0.openHABWidget } ?? []
        return OpenHABSitemapPage(pageId: pageId ?? "", title: title ?? "", link: link ?? "", leaf: leaf ?? false, widgets: mappedWidgets)
    }
}

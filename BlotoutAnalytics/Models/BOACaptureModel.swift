//
//  BOACaptureModel.swift
//  BlotoutAnalyticsSDK
//
//  Created by Poonam Tiwari on 21/03/22.
//

import Foundation
class BOACaptureModel: NSObject {
    var event = ""
    var properties: [AnyHashable : AnyHashable]?
    var eventSubCode: NSNumber?
    var screenName: String?
    var type: String?

    init(
        event: String,
        properties: [AnyHashable : AnyHashable]?,
        screenName: String?,
        withType type: String?
    ) {
        super.init()
            self.event = event
            self.properties = properties ?? [:]
            self.screenName = screenName ?? ""
            self.type = type
    }
}

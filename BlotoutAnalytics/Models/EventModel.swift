//
//  EventModel.swift
//  BlotoutAnalytics
//
//  Created by Poonam Tiwari on 13/05/22.
//

import Foundation
class EventModel: NSObject {
    var evn:String?
    var evt:NSNumber?
    var mid : String?
    var scrn : String?
    var session_id : String?
    var type:String?
    var userid:String?
    var additionalData : [AnyHashable : AnyHashable]?
    var screen : [AnyHashable : AnyHashable]?
    
    init(evn:String?,evt:NSNumber?,mid:String?,scrn:String?,session_id:String?,type:String?,userid:String?,additionalData:[AnyHashable : AnyHashable]?,screen : [AnyHashable : AnyHashable]?) {
       
        self.evn = evn
        self.evt = evt
        self.mid = mid
        self.scrn = scrn
        self.session_id = session_id
        self.type = type
        self.userid = userid
        
        self.additionalData = additionalData ?? [:]
        self.screen = screen ?? [:]
        super.init()
    }
}

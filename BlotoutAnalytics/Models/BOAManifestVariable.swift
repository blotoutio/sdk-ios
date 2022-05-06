//
//  BOAManifestVariable.swift
//  BlotoutAnalytics
//
//  Created by Poonam Tiwari on 03/05/22.
//

import Foundation


struct BlotoutManifest: Codable {
   var variables: [BOAManifestVariable]
}

struct BOAManifestVariable: Codable {
    var variableId: Double
    var value: String
    var variableDataType: Double
    var variableName: String
}

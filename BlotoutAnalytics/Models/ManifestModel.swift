//
//  ManifestModel.swift
//  BlotoutAnalytics
//
//  Created by Poonam Tiwari on 04/05/22.
//

import Foundation


struct ManifestModel: Codable {
    var variables: [ManifestVariableModel]
}


struct ManifestVariableModel:Codable {
    var variableId:Double
    var value:String
    var variableDataType:Double
    var variableName:String
}

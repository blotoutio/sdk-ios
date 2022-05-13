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
    var variable_options:[VariableOptions]?
    var variableDataType:Double
    var variableName:String
}

struct VariableOptions:Codable {
    var label:String
    var key:Double
}

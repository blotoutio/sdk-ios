//
//  BOASDKVariable.swift
//  BlotoutAnalytics
//
//  Created by Poonam Tiwari on 03/05/22.
//

import Foundation

class BOASDKVariable: NSObject {
    
    var variableID: NSNumber?
    var value: String?
    var variableDataType: NSNumber?
    
    
    static var properties: [String : String]?

    
    func getProperties() -> [String:String]
    {
        if BOASDKVariable.properties?.keys.count ?? 0 > 0
        {
            return BOASDKVariable.properties ?? [:]
        }
        else
        {
            BOASDKVariable.properties = [
                "variableId": "variableID",
                "value": "value",
                "variableDataType": "variableDataType"]
            return BOASDKVariable.properties ?? [:]
        }
    }
    
    //TODO: add conditions from where we are using this
    
    class func fromJSONDictionary(_ dict: [AnyHashable : Any]) -> Self {
      //  if dict.keys.count > 0 {
                return BOASDKVariable(jsonDictionary: dict) as! Self
        //    }
//        else
//        {
//            return [:]
//        }
    }
    
    init(jsonDictionary dict: [AnyHashable : Any]?) {
        super.init()
            if let dict = dict as? [String : Any] {
                setValuesForKeys(dict)
            }
    }
    
    override func setValue(_ value: Any?, forKey key: String) {

        let resolved = BOASDKVariable.properties?[key]
            if resolved != nil {
                super.setValue(resolved, forKey: key)
              //resolved  super[resolved] = value
            }
    }
    
    func jsonDictionary() -> [AnyHashable : Any]? {
        var dict: [String : Any]? = nil
        if let allValues = BOASDKVariable.properties?.values as? [String] {
            dict = dictionaryWithValues(forKeys: allValues)
        }
        // Rewrite property names that differ in JSON
        //TODO: fix this below condition
        
      /*  for jsonName in BOASDKVariable.properties {
            
            
            let propertyName = BOASDKVariable.properties?[jsonName]
           
            if jsonName != propertyName {
                dict?[jsonName] = dict?[propertyName]
                dict?.removeValue(forKey: propertyName)
            }
        }
        
        */
        return dict

    }
}


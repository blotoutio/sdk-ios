//
//  BOASDKManifest.swift
//  BlotoutAnalyticsSDK
//
//  Created by Poonam Tiwari on 21/03/22.
//

import Foundation



private func map(_ collection: Any?, _ f: Any?) -> Any? {
    do{
        var result: Any? = nil
        if collection is [AnyHashable] {
            result = [AnyHashable](repeating: 0, count: (collection as AnyHashable).count ?? 0)
            for x in collection! {
                result.append(f(x))
            }
            
        }
        else if collection is [AnyHashable : Any] {
            result = [AnyHashable : Any](minimumCapacity: collection.count())
            for key in collection? {
                result[key] = f(collection[key])
            }
        }
        return result
    }
    catch {
        BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
    }
    return nil
}


func BOASDKManifestFromData(_ data: Data?, _ error: NSErrorPointer) -> BOASDKManifest? {
    var error = error
    do{
        var json: Any? = nil
        do {
            if let data = data {
                json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            }
        } catch {
            //TODO:fix this
        }
        if error == nil {
            return BOASDKManifest.fromJSONDictionary(dict: json as? [AnyHashable : Any])
        }
    } catch {
        //TODO: fix this
        error = NSError(domain: "JSONSerialization", code: -1, userInfo: [
            "exception": exception
        ])
    }
    return nil
}

func BOASDKManifestFromJSON(_ json: String?, _ encoding: String.Encoding, _ error: NSErrorPointer) -> BOASDKManifest? {
    return BOASDKManifestFromData(json?.data(using: encoding), error)
}

func BOASDKManifestToData(_ manifest: BOASDKManifest?, _ error: NSErrorPointer) -> Data? {
    var error = error
        let json = manifest?.jsonDictionary()
        var data: Data? = nil
        do {
            if let json = json {
                data = try JSONSerialization.data(withJSONObject: json, options: [])
            }
        } catch {
        }
        if error == nil {
            return data
        }
}
func BOASDKManifestToJSON(_ manifest: BOASDKManifest?, _ encoding: String.Encoding, _ error: NSErrorPointer) -> String? {
        let data =  BOASDKManifestToData(manifest, error)
        if let data = data {
            return String(data: data, encoding: encoding)
        }
    }


class BOASDKManifest:NSObject {
    
    var variables: [BOASDKVariable]?
    class func properties() -> [String : String]? {
        do{
            return propertiesVar = propertiesVar ?? [
                "variables": "variables"
            ]
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
        return nil
    }
    
    class func fromData(data: Data?,error:Error) throws -> Self? {
        do{
            return BOASDKManifestFromData(data, error) as! Self
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
        return nil
    }
    
    class func fromJSON(json: String?, encoding: String.Encoding, error:Error) throws -> Self? {
        do{
            return BOASDKManifestFromJSON(json, encoding, error) as! Self
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
        return nil
    }
    
    class func fromJSONDictionary(dict: [AnyHashable : Any]?) -> Self {
        do{
            if let dict = dict {
                return BOASDKManifest(jsonDictionary: dict) as! Self
            }
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
        return nil
    }
    
    func initWithJSONDictionary( dict: [AnyHashable : Any]?) {
        if self == super.init(){
            if let dict = dict as? [String : Any] {
                setValuesForKeys(dict)
            }
            variables = map(variables, λ(id, x[BOASDKVariablefromJSONDictionary:x]))
        }
    }
    func jsonDictionary() -> [AnyHashable : Any]? {
        do{
            var dict: [String : Any]? = nil
            if let allValues = BOASDKManifest.properties()?.values as? [String] {
                dict = dictionaryWithValues(forKeys: allValues)
            }
            
            // Map values that need translation
            for (k, v) in [
                "variables": NSNullify(map(variables, λ(id, x[xJSONDictionary])))
            ] { dict?[k] = v }
            
            return dict
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
        return nil
    }
    
    func toData(error:Error) throws -> Data? {
        do{
            return BOASDKManifestToData(self, error)
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
        return nil
    }
    
    func toJSON(encoding: String.Encoding,error:Error) throws -> String? {
        do{
            return BOASDKManifestToJSON(self, encoding, error)
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
        return nil
    }
    
}

class BOASDKVariable: NSObject {
    
    var variableID: NSNumber?
    var value: String?
    var variableDataType: NSNumber?
    
    
    static var propertiesVar: [String : String]?

    static var properties:[String : String] {

        if propertiesVar?.keys.count ?? 0 > 0
        {
            return propertiesVar!
        }
        else
        {
             propertiesVar = [
                "variableId": "variableID",
                "value": "value",
                "variableDataType": "variableDataType"]
            return propertiesVar!
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
        do{
            let resolved = BOASDKVariable.properties[key]
            if resolved != nil {
                super[resolved] = value
            }
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOA_DEBUG, error.localizedDescription)
        }
    }
    
    func jsonDictionary() -> [AnyHashable : Any]? {
        var dict: [String : Any]? = nil
        if let allValues = BOASDKVariable.properties.values as? [String] {
            dict = dictionaryWithValues(forKeys: allValues)
        }
        // Rewrite property names that differ in JSON
        for jsonName in BOASDKVariable.properties {
            let propertyName = BOASDKVariable.properties[jsonName]
            if jsonName != propertyName {
                dict?[jsonName] = dict?[propertyName]
                dict?.removeValue(forKey: propertyName)
            }
        }
        return dict

    }
}

//
//  BOASDKManifest.swift
//  BlotoutAnalyticsSDK
//
//  Created by Poonam Tiwari on 21/03/22.
//

import Foundation

class BOASDKVariable: NSObject {
    var variableID: NSNumber?
    var value: String?
    var variableDataType: NSNumber?
    
}

extension BOASDKManifest {
    class func fromJSONDictionary(_ dict: [AnyHashable : Any]?) -> Self {
    }

    func jsonDictionary() -> [AnyHashable : Any]? {
    }
}

extension BOASDKVariable {
    class func fromJSONDictionary(_ dict: [AnyHashable : Any]?) -> Self {
    }

    func jsonDictionary() -> [AnyHashable : Any]? {
    }
}

/* //TODO
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
*/
func BOASDKManifestFromData(_ data: Data?, _ error: NSErrorPointer) -> BOASDKManifest? {
    var error = error
    do{
        var json: Any? = nil
        do {
            if let data = data {
                json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            }
        } catch {
        }
        if error == nil {
            return BOASDKManifest.fromJSONDictionary(json)
        }
    } catch {
        error = NSError(domain: "JSONSerialization", code: -1, userInfo: [
            "exception": exception
        ])
    })

    return nil
}

func BOASDKManifestFromJSON(_ json: String?, _ encoding: String.Encoding, _ error: NSErrorPointer) -> BOASDKManifest? {
    do{
        return BOASDKManifestFromData(json?.data(using: encoding), error)
    } catch {
        BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
    }
    return nil
}

func BOASDKManifestToData(_ manifest: BOASDKManifest?, _ error: NSErrorPointer) -> Data? {
    var error = error
    do{
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
    } catch {
        error = NSError(domain: "JSONSerialization", code: -1, userInfo: [
            "exception": exception
        ])
    }
    return nil
}
func BOASDKManifestToJSON(_ manifest: BOASDKManifest?, _ encoding: String.Encoding, _ error: NSErrorPointer) -> String? {
    do{
        let data = try BOASDKManifestToData(manifest, error)
        if let data = data {
            return String(data: data, encoding: encoding)
        }
    }
    catch {
        BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
    }
    return nil
}

class BOASDKManifest {
    
    
    var variables: [BOASDKVariable]?
    
    func λ(_ decl: Any, _ expr: Any) -> (decl) -> () {
        {
            return expr
        }
    }
    
    private func NSNullify(_ x: Any?) -> Any? {
        return (x == nil || x == NSNull.null()) ? NSNull.null : x
    }
    
    class func fromJSON(_ json: String?, encoding: String.Encoding) throws -> Self? {
    }
    
    class func from(_ data: Data?) throws -> Self? {
    }
    
    func toJSON(_ encoding: String.Encoding) throws -> String? {
    }
    
    func toData() throws -> Data? {
    }
    
    
    static var propertiesVar: [String : String]?
    
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
    
    class func from(_ data: Data?) throws -> Self? {
        do{
            return BOASDKManifestFromData(data, error)
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
        return nil
    }
    
    class func fromJSON(_ json: String?, encoding: String.Encoding) throws -> Self? {
        do{
            return BOASDKManifestFromJSON(json, encoding, error)
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
        return nil
    }
    
    class func fromJSONDictionary(_ dict: [AnyHashable : Any]?) -> Self {
        do{
            if let dict = dict {
                return BOASDKManifest(jsonDictionary: dict)
            }
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
        return nil
    }
    
    init(jsonDictionary dict: [AnyHashable : Any]?) {
        super.init()
        if let dict = dict as? [String : Any] {
            setValuesForKeys(dict)
        }
        variables = map(variables, λ(id, x[BOASDKVariablefromJSONDictionary:x]))
    }
    
    func jsonDictionary() -> [AnyHashable : Any]? {
        do{
            var dict: [String : Any]? = nil
            if let allValues = BOASDKManifest.properties.values as? [String] {
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
    
    func toData() throws -> Data? {
        do{
            return BOASDKManifestToData(self, error)
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
        return nil
    }
    
    func toJSON(_ encoding: String.Encoding) throws -> String? {
        do{
            return BOASDKManifestToJSON(self, encoding, error)
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
        return nil
    }
}
class BOASDKVariable {
        static var propertiesVar: [String : String]?

    class func properties() -> [String : String]? {
        do{
            return propertiesVar = propertiesVar ?? [
                "variableId": "variableID",
                "value": "value",
                "variableDataType": "variableDataType"
            ]
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
        return nil
    }
    
    class func fromJSONDictionary(_ dict: [AnyHashable : Any]?) -> Self {
        do{
            if let dict = dict {
                return BOASDKVariable(jsonDictionary: dict)
            }
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
        return nil
    }
    
    init(jsonDictionary dict: [AnyHashable : Any]?) {
        super.init()
            if let dict = dict as? [String : Any] {
                setValuesForKeys(dict)
            }
    }
    
    func setValue(_ value: Any?, forKey key: String) {
        do{
            let resolved = BOASDKVariable.properties[key]
            if resolved != nil {
                super[resolved] = value
            }
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
    }
    
    func jsonDictionary() -> [AnyHashable : Any]? {
        do{
            var dict: [String : Any]? = nil
            if let allValues = BOASDKVariable.properties.values as? [String] {
                dict = dictionaryWithValues(forKeys: allValues)
            }
            for jsonName in BOASDKVariable.properties {
                let propertyName = BOASDKVariable.properties[jsonName]
                if jsonName != propertyName {
                    dict[jsonName] = dict[propertyName]
                    dict.removeValue(forKey: propertyName)
                }
            }

            return dict
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
        return nil
    }
}

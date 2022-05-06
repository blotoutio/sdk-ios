//
//  BOASDKManifest.swift
//  BlotoutAnalyticsSDK
//
//  Created by Poonam Tiwari on 21/03/22.
//

import Foundation



private func map(_ collection: Any?, _ f: Any?) -> Any? {
  /*  do{
        var result: Any? = nil
        if collection is [AnyHashable] {
            result = [] as [AnyHashable]
            //[AnyHashable](repeating: 0, count: (collection as AnyHashable).count ?? 0)
            for x in collection as! [AnyHashable] {
               // (result as! [AnyHashable]).insert(contentsOf: f(x), at: 0)
                (result as! [AnyHashable]).append(f(x))
            }
            
        }
        else if collection is [AnyHashable : Any] {
            result = [AnyHashable : Any](minimumCapacity: (collection as? [AnyHashable : Any])?.count ?? 0)
            for key in collection as! [AnyHashable : Any]{
                result[key] = f(collection[key])
            }
        }
        return result
    }
    catch {
        BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
    }*/
    //need to rewrite this
    return nil
}


func BOASDKManifestFromData(data: Data?, error: Error?) -> BOASDKManifest? {
    var error = error

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
    return nil
}

func BOASDKManifestFromJSON(json: String?, encoding: String.Encoding, error: Error?) -> BOASDKManifest? {
    return BOASDKManifestFromData(data: json?.data(using: encoding), error: error)
}

func BOASDKManifestToData(_ manifest: BOASDKManifest?, _ error: Error) -> Data? {
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
    return nil
}
func BOASDKManifestToJSON(_ manifest: BOASDKManifest?, _ encoding: String.Encoding, _ error: Error) -> String? {
        let data =  BOASDKManifestToData(manifest, error)
        if let data = data {
            return String(data: data, encoding: encoding)
        }
    return nil
    }


class BOASDKManifest:NSObject {
    
    var variables: [BOASDKVariable]?
    
    static var propertiesVar: [String : String]?

    static var properties:[String : String] {

        if propertiesVar?.keys.count ?? 0 > 0
        {
            return propertiesVar!
        }
        else
        {
             propertiesVar = [
                "variables": "variables"
            ]
            return propertiesVar!
        }
    }
    //TODO:check this code
    
    class func fromData(data: Data?,error:Error?) throws -> Self? {

            return BOASDKManifestFromData(data: data, error: error) as! Self
    }
    
    class func fromJSON(json: String?, encoding: String.Encoding, error:Error?) throws -> Self? {

            return BOASDKManifestFromJSON(json: json, encoding: encoding, error: error) as? Self
    }
    
    class func fromJSONDictionary(dict: [AnyHashable : Any]?) -> Self? {

            if dict != nil  {
                let manifest = BOASDKManifest(WithJSONDictionary: dict)
                return manifest as? Self
            }
        return nil
    }
    
    // Shorthand for simple blocks
  /*  func λ(_ decl: Any, _ expr: Any) -> (decl) -> () {
        {
            return expr
        }
    }*/
    //need to rewrite this
    
     init(WithJSONDictionary dict: [AnyHashable : Any]?) {
         super.init()
         //TODO: fix this method
      //  if self == super.init(){
            if let dict = dict as? [String : Any] {
                setValuesForKeys(dict)
            }
        //need to rewrite this    variables = map(variables, λ(id, x[BOASDKVariablefromJSONDictionary:x]))
       // }
    }
    
    
    func jsonDictionary() -> [AnyHashable : Any]? {
        do{
            var dict: [String : Any]? = nil
            let allValues = BOASDKManifest.properties.values
            
//            let allValues =   BOASDKManifest.properties.values {//BOASDKManifest.properties()?.values as? [String] {
//                dict = dictionaryWithValues(forKeys: allValues)
//            }
            
            // Map values that need translation
        /*    for (k, v) in [
              //need to rewrite this  "variables": NSNullify(map(variables, λ(id, x[JSONDictionary])))
            ] { dict?[k] = v }
            */
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

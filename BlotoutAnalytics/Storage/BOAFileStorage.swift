//
//  BOAFileStorage.swift
//  BlotoutAnalytics
//
//  Created by Poonam Tiwari on 19/04/22.
//

import Foundation

class BOAFileStorage:NSObject, BOAStorage {
    
  //  var crypto: BOACrypto?

    
    var folderURL: URL!
    
    convenience override init() {
        self.init(folder: URL(fileURLWithPath: BOFFileSystemManager.getBOSDKRootDirectory() ?? ""), crypto: nil)
    }
    
    init(folder folderURL: URL, crypto: BOACrypto?) {
        super.init()
            self.folderURL = folderURL
           // self.crypto = crypto
        
        //won't need crypto further self.crypto = nil
        createDirectoryAtURLIfNeeded(url: folderURL)
    }
    
    func removeKey(_ key: String) {
        let url = self.url(forKey: key)
       // var error: Error? = nil
        do {
            if let url = url {
                try FileManager.default.removeItem(at: url)
            }
        } catch {
            BOFLogDebug(frmt: "Unable to remove key %@ - error removing file at path %@", args: key , url?.absoluteString as! CVarArg)
        }
    }
    func resetAll() {
       // var error: Error? = nil
        do {
            try FileManager.default.removeItem(at: folderURL)
        } catch {
            BOFLogDebug(frmt: "ERROR: Unable to reset file storage. Path cannot be removed - %@", args: folderURL.path)
        }

        createDirectoryAtURLIfNeeded(url: folderURL)
    }
    
    func setData(data: Data, forKey key: String) {
        var url = self.url(forKey: key)
     /*   if (crypto != nil) {
           
            /* Deprecating this
             let encryptedData = crypto?.encrypt(data)
            if let encryptedData = encryptedData, let url = url {
                NSData(data: encryptedData).write(to: url, atomically: true)
            }
            */
        } else {*/
            if data != nil && url != nil {
                NSData(data: data).write(to: url!, atomically: true)
           // }
        }

        var error: Error? = nil
        
        let paths = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)

        for dir in paths {
            print("the paths are \(dir)")
            var urlToExclude = URL(fileURLWithPath: dir)
            do {

                var resourceValues = URLResourceValues()
                resourceValues.isExcludedFromBackup = true
                try urlToExclude.setResourceValues(resourceValues)

            } catch { print("failed to set resource value") }
        }
        do {
            var resourceValues = URLResourceValues()
                   resourceValues.isExcludedFromBackup = true
            try url?.setResourceValues(resourceValues)
        } catch {
            BOFLogDebug(frmt: "Error excluding %@ from backup %@", args: url?.lastPathComponent as! CVarArg, error.localizedDescription)
        }

        //TODO: check this condition
    }
    func data(forKey key: String) -> Data? {
        let url = self.url(forKey: key)
        var data: Data? = nil
        do{
            if let url = url {
                data = try Data(contentsOf: url) }
        }
        catch
        {
            BOFLogDebug(frmt: "WARNING: No data file for key %@", args: key)
            
        }
        if data == nil {
            BOFLogDebug(frmt: "WARNING: No data file for key %@", args: key)
            return nil
        }
        
       /* if (crypto != nil && data != nil) {
          //Deprecating this  return crypto!.decrypt(data!)
        }
        */
        return data
    }
    
    func dictionary(forKey key: String) -> [String : Any]? {
        return plist(forKey: key) as? [String : Any]
    }

    func set(_ dictionary: [String : Any]?, forKey key: String) {
        setPlist(dictionary, forKey: key)
    }

    func array(forKey key: String) -> [Any]? {
        return plist(forKey: key) as? [Any]
    }
    
    func set(_ array: [Any]?, forKey key: String) {
        setPlist(array, forKey: key)
    }

    func string(forKey key: String) -> String? {
        return plist(forKey: key) as? String
    }

    func set(_ string: String?, forKey key: String) {
        setPlist(string, forKey: key)
    }
    
    func url(forKey key: String?) -> URL? {
        return folderURL.appendingPathComponent(key ?? "")
    }

    // MARK: - Helpers

    func plist(forKey key: String) -> Any? {
        let data = self.data(forKey: key)
        return data != nil ? plist(from: data!) : nil
    }

    func setPlist(_ plist: Any, forKey key: String?) {
        let data = self.dataFromPlist(plist: plist)
        if let data = data {
            setData(data: data, forKey: key ?? "")
        }
    }
    
    func dataFromPlist(plist: Any) -> Data? {
        var error: Error? = nil
        var data: Data? = nil
        do {
            data = try PropertyListSerialization.data(
                fromPropertyList: plist,
                format: .xml,
                options: 0)
            
            if error != nil {
                BOFLogDebug(frmt: "Unable to serialize data from plist object", args: error?.localizedDescription as! CVarArg, plist as! CVarArg)
            }
            
            return data
            
        } catch {
            BOFLogDebug(frmt: "Unable to serialize data from plist object", args: error.localizedDescription as! CVarArg, plist as! CVarArg)
            return nil
        }
        //TODO: check condition
    }

    
    func plist(from data: Data) -> Any? {
        let error: Error? = nil
        var plist: Any? = nil
        do {
            plist = try PropertyListSerialization.propertyList(
                from: data,
                options: [],
                format: nil)
        } catch {
        }
        if let error = error {
            BOFLogDebug(frmt: "Unable to parse plist from data %@", args: error.localizedDescription)
        }

        return plist
    }
    
    func createDirectoryAtURLIfNeeded( url: URL) {
        if FileManager.default.fileExists(
            atPath: url.path ,
            isDirectory: nil) {
            return
        }

        let error: Error? = nil
        do {
            try FileManager.default.createDirectory(
                atPath: url.path,
                withIntermediateDirectories: true,
                attributes: nil)
        } catch {
            BOFLogDebug(frmt: "error: %@", args: error.localizedDescription)
        }
    }
}


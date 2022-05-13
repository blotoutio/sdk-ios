//
//  BOAFileStorage.swift
//  BlotoutAnalytics
//
//  Created by Poonam Tiwari on 19/04/22.
//

import Foundation

class BOAFileStorage:NSObject, BOAStorage {
    

    var folderURL: URL!

    convenience override init() {
        self.init(folder: URL(fileURLWithPath: BOFFileSystemManager.getBOSDKRootDirectory() ?? ""))
    }

    init(folder folderURL: URL) {
        super.init()
        self.folderURL = folderURL
        createDirectoryAtURLIfNeeded(url: folderURL)
    }
    
    func removeKey(_ key: String) {
        let url = self.urlForKey(key)
        do {
            if let removeURL = url {
                try FileManager.default.removeItem(at: removeURL)
            }
        } catch {
            BOFLogDebug(frmt: "Unable to remove key %@ - error removing file at path %@", args: key , url?.absoluteString as! CVarArg)
        }
    }

    func resetAll() {
        do {
            try FileManager.default.removeItem(at: folderURL)
        } catch {
            BOFLogDebug(frmt: "ERROR: Unable to reset file storage. Path cannot be removed - %@", args: folderURL.path)
        }

        createDirectoryAtURLIfNeeded(url: folderURL)
    }


    func setData(_ data: Data, forKey key: String) {
        let url = self.urlForKey( key)
        if let url = url {
            NSData(data: data).write(to: url, atomically: true)
        }
        do {
            try (url as NSURL?)?.setResourceValue(NSNumber(value: true), forKey: .isExcludedFromBackupKey)
        } catch {
            BOFLogDebug(frmt: "Error excluding %@ from backup %@", args: url?.lastPathComponent as! CVarArg, error.localizedDescription)
        }
    }
    
    func dataForKey(_ key: String) -> Data? {
        let url = self.urlForKey(key)
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
        return data
    }
    
    func dictionaryForKey(_ key: String) -> [String : Any]? {
        return plistForKey(key) as? [String : Any]
    }
    
    
    func setDictionary(_ dictionary: [String : Any], forKey key: String) {
        setPlist(dictionary, forKey: key)
    }

    func arrayForKey(_ key: String) -> [EventModel]? {
        return plistForKey(key) as? [EventModel]
    }
    
    func setArray(_ array: [Any]?, forKey key: String) {
        setPlist(array, forKey: key)
    }

    func stringForKey(_ key: String) -> String? {
        return plistForKey(key) as? String
    }

    func setString(_ string: String?, forKey key: String) {
        setPlist(string, forKey: key)
    }
    
    func urlForKey(_ key: String?) -> URL? {
        return folderURL.appendingPathComponent(key ?? "")
    }

    // MARK: - Helpers

    
    func plistForKey(_ key: String) -> Any? {
        let data = self.dataForKey(key)
        return data != nil ? plistFromData(_:data!) : nil
    }
    
    func setPlist(_ plist: Any, forKey key: String) {
        let data = self.dataFromPlist(plist: plist)
        if let data = data {
            setData(data, forKey: key)
        }
    }
    
    func dataFromPlist(plist: Any) -> Data? {
        var data: Data? = nil
        do {
            data = try PropertyListSerialization.data(
                fromPropertyList: plist,
                format: .xml,
                options: 0)
            
            return data
            
        } catch {
            BOFLogDebug(frmt: "Unable to serialize data from plist object", args: error.localizedDescription as! CVarArg, plist as! CVarArg)
            return nil
        }
        //TODO: check condition
    }

    func plistFromData(_ data: Data) -> Any? {
        var plist: Any? = nil
        do {
            plist = try PropertyListSerialization.propertyList(
                from: data,
                options: [],
                format: nil)
        } catch {
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


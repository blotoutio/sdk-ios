//
//  BOAFileStorage.swift
//  BlotoutAnalytics
//
//  Created by Poonam Tiwari on 15/04/22.
//

import Foundation

class BOAFileStorage:NSObject {
    var folderURL: URL
    
    convenience init() {
        self.initWithFolder(folderURL: URL(fileURLWithPath: BOFFileSystemManager.getBOSDKRootDirectory()), crypto: nil)
    }

    func initWithFolder(folderURL: URL?, crypto: BOACrypto?) {
        super.init()
            self.folderURL = folderURL
            self.crypto = crypto
            createDirectory(atURLIfNeeded: folderURL)
        return nil
    }
    func removeKey(_ key: String?) {
        let url = self.url(forKey: key)
        var error: Error? = nil
        do {
            if let url = url {
                try FileManager.default.removeItem(at: url)
            }
        } catch {
            BOFLogDebug("Unable to remove key %@ - error removing file at path %@", key, url)
        }
    }
    
    func resetAll() {
        var error: Error? = nil
        do {
            try FileManager.default.removeItem(at: folderURL)
        } catch {
            BOFLogDebug("ERROR: Unable to reset file storage. Path cannot be removed - %@", folderURL.path)
        }

        createDirectory(atURLIfNeeded: folderURL)
    }
    
    func set(_ data: Data?, forKey key: String) {
        let url = self.url(forKey: key)
        if crypto {
            let encryptedData = crypto.encrypt(data)
            if let encryptedData = encryptedData, let url = url {
                NSData(data: encryptedData).write(to: url, atomically: true)
            }
        }
        else{
            if let data = data, let url = url {
                NSData(data: data).write(to: url, atomically: true)
            }
        }
        
        var error: Error? = nil
        do {
            try (url as NSURL?)?.setResourceValue(NSNumber(value: true), forKey: .isExcludedFromBackupKey)
        } catch {
            BOFLogDebug("Error excluding %@ from backup %@", url?.lastPathComponent, error)
        }
    }
    
    func data(forKey key: String) -> Data? {
        let url = self.url(forKey: key)
        var data: Data? = nil
        if let url = url {
            data = Data(contentsOf: url)
        }
        if data == nil {
            BOFLogDebug("WARNING: No data file for key %@", key)
            return nil
        }

        if crypto {
            return crypto.decrypt(data)
        }

        return data
    }
    
    func dictionary(forKey key: String) -> [String : Any]? {
        return plist(forKey: key)
    }

    func set(_ dictionary: [String : Any]?, forKey key: String) {
        setPlist(dictionary, forKey: key)
    }

    func array(forKey key: String) -> [Any]? {
        return plist(forKey: key)
    }
    
    func set(_ array: [Any]?, forKey key: String) {
        setPlist(array, forKey: key)
    }

    func string(forKey key: String) -> String? {
        return plist(forKey: key)
    }

    func set(_ string: String?, forKey key: String) {
        setPlist(string, forKey: key)
    }
    
    func url(forKey key: String?) -> URL? {
        return folderURL.appendingPathComponent(key ?? "")
    }

    // MARK: - Helpers

    func plist(forKey key: String?) -> Any? {
        let data = self.data(forKey: key ?? "")
        return data != nil ? plist(from: data) : nil
    }
    
    func setPlist(_ plist: Any, forKey key: String?) {
        let data = self.data(fromPlist: plist)
        if let data = data {
            set(data, forKey: key ?? "")
        }
    }
    
    func data(fromPlist plist: Any) -> Data? {
        do{
            let error: Error? = nil
            var data: Data? = nil
            do {
                data = try PropertyListSerialization.data(
                    fromPropertyList: plist,
                    format: .xml,
                    options: 0)
            } catch {
            }
            if let error = error {
                BOFLogDebug("Unable to serialize data from plist object", error, plist)
            }

            return data
        } catch { 
            return nil
        }, finallyBlock: {
        })

    }
    
    func plist(from data: Data) -> Any? {
        var error: Error? = nil
        var plist: Any? = nil
        do {
            plist = try PropertyListSerialization.propertyList(
                from: data,
                options: [],
                format: nil)
        } catch {
        }
        if let error = error {
            BOFLogDebug("Unable to parse plist from data %@", error)
        }

        return plist
    }
    
    func createDirectory(atURLIfNeeded url: URL) {
        if FileManager.default.fileExists(
            atPath: url.path ?? "",
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
            BOFLogDebug("error: %@", error.localizedDescription)
        }
    }
}

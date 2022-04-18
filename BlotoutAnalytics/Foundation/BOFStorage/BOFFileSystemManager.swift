//
//  BOFFileSystemManager.swift
//  BlotoutAnalyticsSDK
//
//  Created by Poonam Tiwari on 14/04/22.
//

import Foundation

class BOFFileSystemManager {
    
    let sIsDataWriteEnabled = true
    let sIsSDKEnabled = true
    
    class func addSkipBackupAttribute(toFilePath filePath: String?) -> Bool {
        do{
            if filePath == nil {
                return Bool(0)
            }
            
            let attrName = ("com.apple.MobileBackup" as NSString).utf8String
            var attrValue: UInt8 = 1
            let result = setxattr((filePath as NSString?)?.cString(using: String.Encoding.utf8.rawValue), attrName, &attrValue, MemoryLayout.size(ofValue: attrValue), 0, 0)
            return result == 0
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
        return false
    }
    
    class func addSkipBackupAttributeToItem(at URL: URL?) -> Bool {
        let success = false
        
        do{
            if FileManager.default.fileExists(atPath: URL.path) {
                var error: Error? = nil
                do {
                    success = try (URL as NSURL).setResourceValue(NSNumber(value: true), forKey: .isExcludedFromBackupKey)
                } catch {
                    //TODO: check & correct this condition
                    BOFLogDebug("Error excluding %@ from backup %@", URL.lastPathComponent, error as CVarArg)
                }
            }
        } catch: {
            //Exception will allow backup to iCloud, so either change URL or make alternative
            BOFLogDebug("Error excluding %@ from backup %@", URL?.lastPathComponent, error)
        }
        return success
    }
    
    class func addSkipBackupAttributeToItem(atPath path: String?) -> Bool {
        do{
            if let path = path {
                return self.addSkipBackupAttributeToItem(at: URL(fileURLWithPath: path))
            }
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
        return false
    }
    
    class func setIsDataWriteEnabled(_ isDataWriteEnabled: Bool) {
        self.sIsDataWriteEnabled = isDataWriteEnabled
    }
    
    class func setIsSDKEnabled(isSDKEnabled: Bool) {
        sIsSDKEnabled = isSDKEnabled
    }
    
    class func removeFile(fromLocationPath fileLocationPath: String?) ->Bool {
        do{
            let fileManager = FileManager.default
            var deleteError: Error? = nil
            let success = try fileManager.removeItem(atPath: fileLocationPath ?? "")
            if removalError != nil {
                if let deleteError = deleteError {
                    removalError = deleteError
                }
            }
            return success
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
        return false
    }
    
    class func removeFile(fromLocation fileLocation: URL) ->Bool {
        do{
            let fileManager = FileManager.default
            var deleteError: Error? = nil
            let success = try fileManager.removeItem(at: fileLocation)
            if let deleteError = deleteError {
                removalError = deleteError
            }
            return success
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
        return false
    }
    
    class func moveFile(fromLocation fileLocation: URL, toLocation newLocation: URL) -> Bool {
        do{
            let fileManager = FileManager.default
            var success = false
            var isDir = false
            var isNewDir = false
            
            var moveError: Error? = nil
            
            var filePath = fileLocation.path
            var newFilePath = newLocation.path
            
            var existAndDic = fileManager.fileExists(atPath: filePath, isDirectory: &isDir) && isDir
            var newExistAndDic = fileManager.fileExists(atPath: newFilePath, isDirectory: &isNewDir) && isNewDir
            
            if !existAndDic && newExistAndDic {
                let fileName = fileLocation.lastPathComponent
                newFilePath = URL(fileURLWithPath: newFilePath).appendingPathComponent(fileName).path
                
                success =  fileManager.moveItem(at: fileLocation, to: URL(fileURLWithPath: newFilePath))
                //TODO: check logic again
            } else {
                do {
                    success = try fileManager.moveItem(at: fileLocation, to: URL(fileURLWithPath: newFilePath))
                } catch let moveError {
                }
            }
            relocationError = moveError
            
            return success
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
        return false
    }
    
    class func moveFile(fromLocationPath fileLocation: String, toLocationPath newLocation: String) -> Bool {
        do{
            let fileManager = FileManager.default
            var success = false
            var isDir = false
            var isNewDir = false
            
            var moveError: Error? = nil
            var filePath = fileLocation
            var newFilePath = newLocation
            
            var existAndDic = fileManager.fileExists(atPath: filePath, isDirectory: &isDir) && isDir
            var newExistAndDic = fileManager.fileExists(atPath: newFilePath, isDirectory: &isNewDir) && isNewDir
            
            if !existAndDic && newExistAndDic {
                let fileName = fileLocation.lastPathComponent
                newFilePath = URL(fileURLWithPath: newFilePath).appendingPathComponent(fileName).path
                do {
                    success = try fileManager.moveItem(atPath: fileLocation, toPath: newFilePath)
                } catch let moveError {
                }
            } else {
                do {
                    success = try fileManager.moveItem(atPath: fileLocation, toPath: newLocation)
                } catch let moveError {
                }
            }
            relocationError = moveError
            
            return success
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
        return false
    }
    
    class func moveFile(fromLocation fileLocation: URL?, toLocation newLocation: URL?, mergeIfExist doMerge: Bool) -> Bool {
        return false
    }
    
    class func moveFile(fromLocation fileLocation: URL?, toLocation newLocation: URL?, replaceIfExist doReplace: Bool) -> Bool {
        return false
    }
    
    class func isWritableDirectory(atPath path: String?) -> Bool {
        do{
            var isDir = false
            if FileManager.default.fileExists(atPath: path ?? "", isDirectory: UnsafeMutablePointer<ObjCBool>(mutating: &isDir)) && isDir {
                isDir = FileManager.default.isWritableFile(atPath: path ?? "")
            }
            return isDir
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
        return false
    }
    
    class func isWritableFile(atPath path: String?) -> Bool {
        do{
            var isWritableFile = false
            let isDir = false
            
            if FileManager.default.fileExists(atPath: path, isDirectory: &isDir) && !isDir {
                isWritableFile = FileManager.default.isWritableFile(atPath: path ?? "")
            } else if !isDir {
                isWritableFile = FileManager.default.createFile(atPath: path ?? "", contents: nil, attributes: nil)
            }
            
            return isWritableFile
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
        return false
    }
    
    class func checkAndReturnWritableFilePath(_ givenPath: Any?) -> String? {
        do{
            var filePath: String? = nil
            if givenPath is NSURL {
                filePath = (givenPath as? URL)?.path
            } else if givenPath is NSString {
                filePath = givenPath as? String
            }
            
            if !filePath {
                throw NSException(name: NSExceptionName("BOFFilePathException"), reason: "Path must be String or URL", userInfo: [
                    "Description": "Path provided is not appropiate, must be either String or URL"
                ])
            }
            
            var writableFilePath = filePath
            if isWritableDirectory(atPath: filePath) {
                writableFilePath = URL(fileURLWithPath: filePath).appendingPathComponent(String(format: "BOFFile%ui", arc4random())).path
            } else if !isWritableFile(atPath: filePath) {
                throw NSException(name: NSExceptionName("BOFFileWritingException"), reason: "Directory is not writable", userInfo: [
                    "Description": "Directory or file path is not writable, use with writable file path"
                ])
            }
            
            return writableFilePath
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
        return nil
    }
    
    
    class func path(afterWriting contentString: String?, toFilePath filePath: String?, appendIfExist shouldAppend: Bool) throws -> String? {
        do{
            
            if sIsDataWriteEnabled && sIsSDKEnabled {
                let writableFilePath = checkAndReturnWritableFilePath(filePath)
                var completeString = contentString
                let writeError: Error? = nil
                
                if shouldAppend {
                    var fileHandle: FileHandle? = nil
                    do {
                        fileHandle = try FileHandle(forWritingTo: URL(fileURLWithPath: writableFilePath))
                    } catch let writeError {
                    }
                    fileHandle?.seekToEndOfFile()
                    if let data = contentString.data(using: .utf8) {
                        fileHandle?.write(data)
                    }
                    fileHandle?.closeFile()
                }
                else
                {
                    var success = false
                    do {
                        try completeString.write(toFile: writableFilePath, atomically: true, encoding: .utf8)
                        success = true
                    } catch let writeError {
                        writableFilePath = nil
                    }
                }
                if let writeError = writeError {
                    error = writeError
                }
                return writableFilePath
            } else {
                let writeError = NSError(domain: "io.blotout.FileSystem", code: 90001, userInfo: [
                    "info": "data write for blotout SDK not allowed"
                ])
                error = writeError
                return nil
            }
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
            
        }
        return nil
    }
    
    /// method to get path after writing string to file path
    /// - Parameters:
    ///   - contentString: as NSString
    ///   - filePath: as NSString
    ///   - error: as NSError
    /// - Returns: writableFilePath as NSString
    class func path(afterWriting contentString: String?, toFilePath filePath: String?) throws -> String? {
        do{
            if sIsDataWriteEnabled && sIsSDKEnabled {
                var writableFilePath = checkAndReturnWritableFilePath(filePath)
                var writeError: Error? = nil
                var success: Bool
                //write without encryption
                do {
                    success = try contentString.write(toFile: writableFilePath, atomically: true, encoding: .utf8)
                } catch let writeError {
                    writableFilePath = ""
                }
                if let writeError = writeError {
                    error = writeError
                }
                return writableFilePath
            } else {
                let writeError = NSError(domain: "io.blotout.FileSystem", code: 90001, userInfo: [
                    "info": "data write for blotout SDK not allowed"
                ])
                error = writeError
                return nil
            }
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
        return nil
    }
    
    
    /// method to get path after writing string to file url
    /// - Parameters:
    ///   - contentString: as NSString
    ///   - fileUrl: as NSURL
    ///   - error: as NSError
    /// - Returns: fileUrlPath as NSURL
    class func path(afterWriting contentString: String?, toFileUrl fileUrl: URL?) throws -> URL? {
        do{
            if sIsDataWriteEnabled && sIsSDKEnabled {
                var fileUrlPath = URL(fileURLWithPath: checkAndReturnWritableFilePath(fileUrl))
                var writeError: Error? = nil
                var success = false
                do {
                    fileUrlPath != nil ? try contentString.write(to: fileUrlPath, atomically: true, encoding: .utf8) : false
                    success = true
                } catch let writeError {
                    fileUrlPath = nil
                }
                if let writeError = writeError {
                    error = writeError
                }
                return fileUrlPath
            } else {
                let writeError = NSError(domain: "io.blotout.FileSystem", code: 90001, userInfo: [
                    "info": "data write for blotout SDK not allowed"
                ])
                error = writeError
                return nil
            }
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
        return nil
    }
    
    /// method to get content of file at path
    /// - Parameters:
    ///   - filePath: as NSString
    ///   - encoding: as NSStringEncoding
    ///   - err: as NSError
    /// - Returns: fileContent as NSString
    ///
    class func contentOfFile(atPath filePath: String?, with encoding: String.Encoding) throws -> String? {
        do{
            let fileContent = try String(contentsOfFile: filePath ?? "", encoding: encoding)
            return fileContent
        } catch{
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
        return nil
    }
    
    /// method to get application support directory path
    /// - Returns: dirPath as NSString
    ///
    ///
    class func getApplicationSupportDirectoryPath() -> String? {
        do{
            let bundleID = Bundle.main.bundleIdentifier
            let fm = FileManager.default
            var dirPath: URL? = nil
            
            // Find the application support directory in the home directory.
            //NSLibraryDirectory
            //NSCachesDirectory
            //NSApplicationSupportDirectory
            let appSupportDir = fm.urls(
                for: .applicationSupportDirectory,
                   in: .userDomainMask)
            if appSupportDir.count > 0 {
                // Append the bundle ID to the URL for the
                // Application Support directory
                dirPath = appSupportDir[0].appendingPathComponent(bundleID)
                
                // If the directory does not exist, this method creates it.
                // This method is only available in OS X v10.7 and iOS 5.0 or later.
                var theError: Error? = nil
                do {
                    try fm.createDirectory(at: dirPath, withIntermediateDirectories: true, attributes: nil)
                } catch let theError {
                    // Handle the error.
                    return nil
                }
                
                return dirPath?.path
            }} catch {
                BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
            }
        return nil
    }
    
    
    /// method to get document directory path
    /// - Returns: sBOFSDKDocumentsDirectory as NSString
    ///
    class func getDocumentDirectoryPath() -> String? {
        
        var getDocumentDirectoryPathSBOFSDKDocumentsDirectory: String? = nil
        do{
            if getDocumentDirectoryPathSBOFSDKDocumentsDirectory == nil {
                let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).map(\.path)
                getDocumentDirectoryPathSBOFSDKDocumentsDirectory = paths[0]
            }
            return getDocumentDirectoryPathSBOFSDKDocumentsDirectory
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
        return nil
    }
    
    
    /// method to create directory if required and return path
    /// - Parameter directoryPath: as NSString
    /// - Returns: directoryPath as NSArray
    ///
    class func createDirectoryIfRequiredAndReturnPath(_ directoryPath: String?) -> String? {
        var directoryPath = directoryPath
        do{
            var dirError: Error? = nil
            if !FileManager.default.fileExists(atPath: directoryPath ?? "") {
                do {
                    try FileManager.default.createDirectory(atPath: directoryPath ?? "", withIntermediateDirectories: false, attributes: nil)
                } catch let dirError {
                    directoryPath = nil
                }
            }
            return directoryPath
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
        return nil
    }
    
    /// method to get BOSDK root direcoty possible existance path
    /// - Returns: BOFSDKRootDir as NSString
    
    class func getBOSDKRootDirecotyPossibleExistancePath() -> String? {
        do{
            var systemRootDirectory: String? = nil
            if IS_OS_6_OR_LATER {
                systemRootDirectory = getApplicationSupportDirectoryPath()
            } else {
                systemRootDirectory = getDocumentDirectoryPath()
            }
            let BOFSDKRootDir = URL(fileURLWithPath: systemRootDirectory ?? "").appendingPathComponent(kBOSDKRootDirectoryName).path
            
            return BOFSDKRootDir
            
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
        return nil
    }
    
    /// method to check is file exist at path
    /// - Parameter filePath: as NSString
    /// - Returns: status as BOOL
    class func isFileExist(atPath filePath: String?) -> Bool {
        do{
            return FileManager.default.fileExists(atPath: filePath ?? "")
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
        return false
    }
    
    /// method to get SDK's root dir
    /// - Returns: BOFSDKRootDir as NSString
    class func getBOSDKRootDirectory() -> String? {
        do{
            let BOFSDKRootDir = self.createDirectoryIfRequiredAndReturnPath(self.getBOSDKRootDirecotyPossibleExistancePath())
            self.addSkipBackupAttributeToItem(atPath: BOFSDKRootDir)
            return BOFSDKRootDir
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
        return nil
    }
    
    /// method to get child directory creating in parents
    /// - Parameters:
    ///   - childDirName: as NSString
    ///   - parentPath: as NSString
    /// - Returns: childDirPath as NSString
    ///
    ///
     class func getChildDirectory(_ childDirName: String?, byCreatingInParent parentPath: String?) -> String? {
    do{
        let childDirPossiblePath = URL(fileURLWithPath: parentPath).appendingPathComponent(childDirName).path
        let childDirPath = createDirectoryIfRequiredAndReturnPath(childDirPossiblePath)
        addSkipBackupAttributeToItem(atPath: childDirPath)
        return childDirPath
        
    } catch {
        BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
    }
    return nil
}
    /// method to get bundle id
    /// - Returns: sBofBundleid as NSString
    static var sBofBundleid = ""

    class func bundleId() -> String? {
        // TODO: import SwiftTryCatch from https://github.com/ypopovych/SwiftTryCatch
        SwiftTryCatch.try({
            if sBofBundleid == "" {
                sBofBundleid = Bundle.main.bundleIdentifier ?? ""
            }
            return sBofBundleid
        }, catch: { exception in
            BOFLogDebug("%@:%@", BOF_DEBUG, exception)
        }, finallyBlock: {
        })
        return nil
    }
    
    /// method to get SDK manifest dir path
    /// - Returns: sdkManifestData as NSString
    class func getSDKManifestDirectoryPath() -> String? {
        // TODO: import SwiftTryCatch from https://github.com/ypopovych/SwiftTryCatch
        SwiftTryCatch.try({
            let eventsRootDir = self.getBOSDKRootDirectory()
            let sdkManifestData = BOFFileSystemManager.getChildDirectory("SDKManifestData", byCreatingInParent: eventsRootDir)
            return sdkManifestData
        }, catch: { exception in
            BOFLogDebug("%@:%@", BOF_DEBUG, exception)
        }, finallyBlock: {
        })
        return nil
    }
    
}

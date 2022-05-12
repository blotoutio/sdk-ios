//
//  BOFFileSystemManager.swift
//  BlotoutAnalyticsSDK
//
//  Created by Poonam Tiwari on 14/04/22.
//

import Foundation

class BOFFileSystemManager:NSObject {
    
    static var sIsDataWriteEnabled = true
    static var sIsSDKEnabled = true
    
    class func addSkipBackupAttribute(toFilePath filePath: String) -> Bool {
            if filePath.count <= 0 {
                return false
            }
            
            let attrName = ("com.apple.MobileBackup" as NSString).utf8String
            var attrValue: UInt8 = 1
            let result = setxattr((filePath as NSString?)?.cString(using: String.Encoding.utf8.rawValue), attrName, &attrValue, MemoryLayout.size(ofValue: attrValue), 0, 0)
            return result == 0
    }
    
    class func addSkipBackupAttributeToItem(at URL: URL) -> Bool {
        var success:Bool = false

            if FileManager.default.fileExists(atPath: URL.path) {
                var error: Error? = nil
                do {
                    success = true
                    try (URL as NSURL).setResourceValue(NSNumber(value: true), forKey: .isExcludedFromBackupKey)
                } catch {
                    success = false
                    //TODO: check & correct this condition
                    BOFLogDebug(frmt: "Error excluding %@ from backup %@", args: URL.lastPathComponent, error.localizedDescription)
                }
            }
       
        return success
    }
    
    class func addSkipBackupAttributeToItem(atPath path: String) -> Bool {
        if path.count > 0
        {
           // return [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:path]];
            return  addSkipBackupAttributeToItem(at: URL(fileURLWithPath: path))
        }
        return false
    }
    
   class  func setIsDataWriteEnabled(_ isDataWriteEnabled: Bool) {
        sIsDataWriteEnabled = isDataWriteEnabled
    }
    
   class  func setIsSDKEnabled(isSDKEnabled: Bool) {
         sIsSDKEnabled = isSDKEnabled
    }
    
    class func removeFile(fromLocationPath fileLocationPath: String, removalError:Error?) ->Bool {
            let fileManager = FileManager.default
            var deleteError: Error? = nil
            var success:Bool = false
            do {
                success = true
                try fileManager.removeItem(atPath: fileLocationPath )
            }
            catch {
                success = false
                BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
            }
            
            if removalError != nil {
                if let deleteError = deleteError {
                //TODO: why is this being set     removalError = deleteError
                }
            }
            return success
    }
    
    class func removeFile(fromLocation fileLocation: URL, removalError:Error) ->Bool {
        let fileManager = FileManager.default
//        var deleteError: Error? = nil
//        var removeError = removalError
        var success:Bool = false
        
        do{
            success = true
            try fileManager.removeItem(at: fileLocation)
        }
        catch
        {
            success = false
        }
//        if let deleteError = deleteError {
//            removeError = deleteError
//        }
        
        //TODO:check these conditions
        return success
        
    }
    
    class func moveFile(fromLocation fileLocation: URL, toLocation newLocation: URL,relocationError:Error) -> Bool {
        
        let fileManager = FileManager.default
        var success = false
        var isDir:ObjCBool = false
        var isNewDir:ObjCBool = false
        var relocError = relocationError
        var moveError: Error? = nil
        
        var filePath = fileLocation.path
        var newFilePath = newLocation.path
        
        var existAndDic = fileManager.fileExists(atPath: filePath, isDirectory: &isDir) && isDir.boolValue
        var newExistAndDic = fileManager.fileExists(atPath: newFilePath, isDirectory: &isNewDir) && isNewDir.boolValue
        
        if !existAndDic && newExistAndDic {
            let fileName = fileLocation.lastPathComponent
            newFilePath = URL(fileURLWithPath: newFilePath).appendingPathComponent(fileName).path
            do {
                success = true
                try fileManager.moveItem(at: fileLocation, to: URL(fileURLWithPath: newFilePath))
            }
            catch
            {
                success = false
            }
            //TODO: check logic again
        } else {
            do {
                success = true
                try fileManager.moveItem(at: fileLocation, to: URL(fileURLWithPath: newFilePath))
            } catch let moveError {
                success = false
            }
        }
        relocError = moveError as! Error
        
        return success
        
    }
    
    class func moveFile(fromLocationPath fileLocation: URL, toLocationPath newLocation: URL,relocationError:Error) -> Bool {

            let fileManager = FileManager.default
            var success = false
            var isDir:ObjCBool = false
            var isNewDir:ObjCBool = false
            
            var moveError: Error? = nil
            var filePath = fileLocation.path
            var newFilePath = newLocation.path
            
            var existAndDic = fileManager.fileExists(atPath: filePath, isDirectory: &isDir) && isDir.boolValue
            var newExistAndDic = fileManager.fileExists(atPath: newFilePath, isDirectory: &isNewDir) && isNewDir.boolValue
            
            if !existAndDic && newExistAndDic {
                let fileName = fileLocation.lastPathComponent
                newFilePath = URL(fileURLWithPath: newFilePath).appendingPathComponent(fileName ).path
                do {
                    success = true
                    try fileManager.moveItem(at: fileLocation, to: URL(fileURLWithPath: newFilePath))
                    
                   // moveItem(atPath: fileLocation, toPath: newFilePath)
                } catch let moveError {
                    success = false
                }
            } else {
                do {
                    success = true
                    try fileManager.moveItem(at: fileLocation, to: URL(fileURLWithPath: newFilePath))
                } catch let moveError {
                    success = false
                }
            }
            //TODO: why is this being set
            // relocationError = moveError
            
            return success
    }
    
    class func moveFile(fromLocation fileLocation: URL, toLocation newLocation: URL, mergeIfExist doMerge: Bool,relocationError:Error) -> Bool {
        return false
    }
    
    class func moveFile(fromLocation fileLocation: URL, toLocation newLocation: URL, replaceIfExist doReplace: Bool,relocationError:Error) -> Bool {
        return false
    }
    
    class func isWritableDirectory(atPath path: String) -> Bool {

            var isDir:ObjCBool = false
            var isWritable:Bool = false
            if FileManager.default.fileExists(atPath: path , isDirectory: &isDir) && isDir.boolValue {
                isWritable = FileManager.default.isWritableFile(atPath: path )
            }
            return isWritable
    }
    
    class func isWritableFile(atPath path: String) -> Bool {

            var isWritableFile = false
            var isDir:ObjCBool = false
            
            if FileManager.default.fileExists(atPath: path, isDirectory: &isDir) && !isDir.boolValue {
                isWritableFile = FileManager.default.isWritableFile(atPath: path )
            } else if !isDir.boolValue {
                isWritableFile = FileManager.default.createFile(atPath: path , contents: nil, attributes: nil)
            }
            
            return isWritableFile
        
    }
    
    class func checkAndReturnWritableFilePath(_ givenPath: Any) -> String? {
        do{
            var filePath: String? = nil
            if givenPath is NSURL {
                filePath = (givenPath as? URL)?.path
            } else if givenPath is NSString {
                filePath = givenPath as? String
            }
            
            if (filePath == nil) {
                
                //TODO: find what should be code
                
                throw NSError(domain: "BOFFilePathException", code: 42, userInfo: [
                    "Description": "Path provided is not appropiate, must be either String or URL"] )

                
//                throw NSException(name: NSExceptionName("BOFFilePathException"), reason: "Path must be String or URL", userInfo: [
//                    "Description": "Path provided is not appropiate, must be either String or URL"
//                ])
            }
            
            var writableFilePath = filePath
            if isWritableDirectory(atPath: filePath ?? "") {
                writableFilePath = URL(fileURLWithPath: filePath!).appendingPathComponent(String(format: "BOFFile%ui", arc4random())).path
            } else if !isWritableFile(atPath: filePath!) {
                
                throw NSError(domain: "BOFFileWritingException", code: 42, userInfo: [
                    "Description": "Directory or file path is not writable, use with writable file path"
                ] )
                
//                throw NSException(name: NSExceptionName("BOFFileWritingException"), reason: "Directory is not writable", userInfo: [
//                    "Description": "Directory or file path is not writable, use with writable file path"
//                ])
            }
            
            return writableFilePath
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOF_DEBUG, error.localizedDescription)
        }
        return nil
    }
    
    
    class func pathAfterWriting(contentString: String, toFilePath filePath: String, appendIfExist shouldAppend: Bool,writingError:Error) throws -> String? {
            
            if sIsDataWriteEnabled && sIsSDKEnabled {
                var writableFilePath = BOFFileSystemManager.checkAndReturnWritableFilePath(filePath) ?? ""
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
                        try completeString.write(toFile: writableFilePath , atomically: true, encoding: .utf8)
                        success = true
                    } catch let writeError {
                        writableFilePath = ""
                    }
                }
                if let writeError = writeError {
                    //TODO: why is this being set
                   // error = writeError
                }
                return writableFilePath
            } else {
                let writeError = NSError(domain: "io.blotout.FileSystem", code: 90001, userInfo: [
                    "info": "data write for blotout SDK not allowed"
                ])
               // error = writeError
                //TODO: why is this being set
                return nil
            }
        
    }
    
    /// method to get path after writing string to file path
    /// - Parameters:
    ///   - contentString: as NSString
    ///   - filePath: as NSString
    ///   - error: as NSError
    /// - Returns: writableFilePath as NSString
    class func pathAfterWriting( contentString: String, toFilePath filePath: String) throws -> String? {

            if sIsDataWriteEnabled && sIsSDKEnabled {
                var writableFilePath = BOFFileSystemManager.checkAndReturnWritableFilePath(filePath)
                var writeError: Error? = nil
                var success: Bool = false
                //write without encryption
                do {
                    success = true
                    try contentString.write(toFile: writableFilePath ?? "", atomically: true, encoding: .utf8)
                } catch let writeError {
                    success = false
                    writableFilePath = ""
                }
                if let writeError = writeError {
                    //TODO: why is this being set
                   // error = writeError
                }
                return writableFilePath
            } else {
                let writeError = NSError(domain: "io.blotout.FileSystem", code: 90001, userInfo: [
                    "info": "data write for blotout SDK not allowed"
                ])
                
                //TODO: why is this being set
              //  error = writeError
                return nil
            }
       
    }
    
    
    /// method to get path after writing string to file url
    /// - Parameters:
    ///   - contentString: as NSString
    ///   - fileUrl: as NSURL
    ///   - error: as NSError
    /// - Returns: fileUrlPath as NSURL
   class func pathAfterWriting( contentString: String, toFileUrl fileUrl: URL) throws -> URL? {
        
        if sIsDataWriteEnabled && sIsSDKEnabled {
            var fileUrlPath = URL(fileURLWithPath: BOFFileSystemManager.checkAndReturnWritableFilePath(fileUrl) ?? "")
            var writeError: Error? = nil
            var success = false
            
            if fileUrlPath.absoluteString.count > 0
            {
                do
                {
                    success = true
                    try contentString.write(to: fileUrlPath, atomically: true, encoding: .utf8)
                }catch
                {
                    success = false
                }
            }
            
            if let writeError = writeError {
                //TODO: why is this being set
                // error = writeError
            }
            return fileUrlPath
        } else {
            let writeError = NSError(domain: "io.blotout.FileSystem", code: 90001, userInfo: [
                "info": "data write for blotout SDK not allowed"
            ])
            
            //TODO: why is this being set
            // error = writeError
            return nil
        }
        
    }
    
    /// method to get content of file at path
    /// - Parameters:
    ///   - filePath: as NSString
    ///   - encoding: as NSStringEncoding
    ///   - err: as NSError
    /// - Returns: fileContent as NSString
    ///
    class func contentOfFile(atPath filePath: String, with encoding: String.Encoding) throws -> String? {
        do{
            let fileContent = try String(contentsOfFile: filePath , encoding: encoding)
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
                dirPath = appSupportDir[0].appendingPathComponent(bundleID ?? "")
                
                // If the directory does not exist, this method creates it.
                // This method is only available in OS X v10.7 and iOS 5.0 or later.
                var theError: Error? = nil
                do {
                    try fm.createDirectory(at: dirPath!, withIntermediateDirectories: true, attributes: nil)
                } catch let theError {
                    // Handle the error.
                    return nil
                }
                
                return dirPath?.path
            }
        return ""
    }
    
    
    /// method to get document directory path
    /// - Returns: sBOFSDKDocumentsDirectory as NSString
    ///
    class func getDocumentDirectoryPath() -> String? {
        
        var getDocumentDirectoryPathSBOFSDKDocumentsDirectory: String? = nil
            if getDocumentDirectoryPathSBOFSDKDocumentsDirectory == nil {
                let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).map(\.path)
                getDocumentDirectoryPathSBOFSDKDocumentsDirectory = paths[0]
            }
            return getDocumentDirectoryPathSBOFSDKDocumentsDirectory

    }
    
    
    /// method to create directory if required and return path
    /// - Parameter directoryPath: as NSString
    /// - Returns: directoryPath as NSArray
    ///
    class func createDirectoryIfRequiredAndReturnPath(_ directoryPath: String) -> String? {
        var directoryPath = directoryPath
            var dirError: Error? = nil
        if !FileManager.default.fileExists(atPath: directoryPath ) {
                do {
                    try FileManager.default.createDirectory(atPath: directoryPath , withIntermediateDirectories: false, attributes: nil)
                } catch _ {
                    directoryPath = ""
                }
            }
            return directoryPath
    }
    
    /// method to get BOSDK root direcoty possible existance path
    /// - Returns: BOFSDKRootDir as NSString
    
    class func getBOSDKRootDirecotyPossibleExistancePath() -> String? {
            var systemRootDirectory: String? = nil
                systemRootDirectory = getApplicationSupportDirectoryPath()
            
            let BOFSDKRootDir = URL(fileURLWithPath: systemRootDirectory ?? "").appendingPathComponent(kBOSDKRootDirectoryName).path
            
            return BOFSDKRootDir
    }
    
    /// method to check is file exist at path
    /// - Parameter filePath: as NSString
    /// - Returns: status as BOOL
    class func isFileExist(atPath filePath: String) -> Bool {
            return FileManager.default.fileExists(atPath: filePath )
    }
    
    /// method to get SDK's root dir
    /// - Returns: BOFSDKRootDir as NSString
    class func getBOSDKRootDirectory() -> String? {
            let BOFSDKRootDir = self.createDirectoryIfRequiredAndReturnPath(self.getBOSDKRootDirecotyPossibleExistancePath() ?? "") ?? ""
            self.addSkipBackupAttributeToItem(atPath: BOFSDKRootDir)
            return BOFSDKRootDir
       
    }
    
    /// method to get child directory creating in parents
    /// - Parameters:
    ///   - childDirName: as NSString
    ///   - parentPath: as NSString
    /// - Returns: childDirPath as NSString
    ///
    ///
     class func getChildDirectory(_ childDirName: String, byCreatingInParent parentPath: String) -> String? {
        let childDirPossiblePath = URL(fileURLWithPath: parentPath).appendingPathComponent(childDirName ).path
        let childDirPath = createDirectoryIfRequiredAndReturnPath(childDirPossiblePath)
        addSkipBackupAttributeToItem(atPath: childDirPath ?? "")
        return childDirPath
}
    /// method to get bundle id
    /// - Returns: sBofBundleid as NSString
    static var sBofBundleid = ""

    class func bundleId() -> String? {
            if sBofBundleid == "" {
                sBofBundleid = Bundle.main.bundleIdentifier ?? ""
            }
            return sBofBundleid
    }
    
    /// method to get SDK manifest dir path
    /// - Returns: sdkManifestData as NSString
    class func getSDKManifestDirectoryPath() -> String? {
            let eventsRootDir = self.getBOSDKRootDirectory() ?? ""
            let sdkManifestData = BOFFileSystemManager.getChildDirectory("SDKManifestData", byCreatingInParent: eventsRootDir)
            return sdkManifestData
    }
    
}

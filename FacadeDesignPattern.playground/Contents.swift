import UIKit

/// 组合为主 这里的protocl类似功能的组合 外观模式，主要是封装没有（这里没有各个分门别类功能的类，倒是各个protocol 而且遵循这个不是持有这个实例，思路有点不一样）
/// 和类不一样，没有持有关系，没有中间人。利用遵守协议这个特性
enum AppDirectories : String {
    case Documents = "Documents"
    case InBox = "InBox"
    case Library = "Library"
    case Temp = "Temp"
}

protocol AppDirectoryNames {
    func documentsDirectoryURL() -> URL
    
    func inboxDirectoryURL() -> URL
    
    func libraryDirectoryURL() -> URL
    
    func tempDirectoryURL() -> URL
    
    func getURL(for directory: AppDirectories) -> URL
    
    func buildFullPath(forFileName name: String, inDirectory directory: AppDirectories) -> URL
}

extension AppDirectoryNames {
    func documentsDirectoryURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func inboxDirectoryURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(AppDirectories.InBox.rawValue)
    }
    
    func libraryDirectoryURL() -> URL {
        return FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!
    }
    
    func tempDirectoryURL() -> URL {
        return FileManager.default.temporaryDirectory
    }
    
    func getURL(for directory: AppDirectories) -> URL {
        switch directory {
        case .Documents:
            return documentsDirectoryURL()
        case .InBox:
            return inboxDirectoryURL()
        case .Library:
            return libraryDirectoryURL()
        case .Temp:
            return tempDirectoryURL()
        }
    }
    
    func buildFullPath(forFileName name: String, inDirectory directory: AppDirectories) -> URL {
        return getURL(for: directory).appendingPathComponent(name)
    }
}

protocol AppFileStatusChecking {
    func isWritable(file at: URL) -> Bool
    func isReadable(file at: URL) -> Bool
    func exists(file at: URL) -> Bool
}

extension AppFileStatusChecking {
    func isWritable(file at: URL) -> Bool {
        debugPrint(at.path)
        return FileManager.default.isWritableFile(atPath: at.path)
    }
    
    func isReadable(file at: URL) -> Bool {
        debugPrint(at.path)
        return FileManager.default.isReadableFile(atPath: at.path)
    }
    
    func exists(file at: URL) -> Bool {
        return FileManager.default.fileExists(atPath: at.path)
    }
}


protocol AppFileSystemMetaData {
    func list(directory at: URL) -> Bool
    func attributes(ofFile atFullPath: URL) -> [FileAttributeKey: Any]
}

extension AppFileSystemMetaData {
    func list(directory at: URL) -> Bool {
        do {
            let listing = try FileManager.default.contentsOfDirectory(atPath: at.path)
            guard !listing.isEmpty else {
                return false
            }
            debugPrint("------------------------")
            debugPrint("LISTING: \(at.path)")
            listing.forEach {
                debugPrint("File: \($0.description)")
            }
            debugPrint("")
            debugPrint("-------------------------")
            return true
        } catch {
            return false
        }
    }
    
    func attributes(ofFile atFullPath: URL) -> [FileAttributeKey: Any] {
        do {
            return try FileManager.default.attributesOfItem(atPath: atFullPath.path)
        } catch {
            return [:]
        }
    }
}

protocol AppFileManipulation :  AppDirectoryNames {
    func writeFile(containing: String, to path: AppDirectories, withName name: String) -> Bool
    
    func readFile(at path: AppDirectories, withName name: String) -> String
    
    func deleteFile(at path: AppDirectories, withName name: String) -> Bool
    
    func renameFile(at path: AppDirectories, with oldName: String, to newName: String
    ) -> Bool
    
    func moveFile(withName name: String, inDirectory: AppDirectories, toDirectory directory: AppDirectories) -> Bool
    
    func copyFile(withName name: String, inDirectory: AppDirectories, toDirectory directory: AppDirectories) -> Bool
    
    func changeFileExtension(withName name: String, inDirectory: AppDirectories, toNewExtension newExtension: String) -> Bool
}

extension AppFileManipulation {
    func writeFile(containing: String, to path: AppDirectories, withName name: String) -> Bool {
        let filePath = getURL(for: path).appendingPathComponent(name).path
        let rawData: Data? = containing.data(using: .utf8)
        return FileManager.default.createFile(atPath: filePath, contents: rawData, attributes: nil)
    }
    
    func readFile(at path: AppDirectories, withName name: String) -> String {
        let filePath = getURL(for: path).appendingPathComponent(name).path
        let fileContents = FileManager.default.contents(atPath: filePath) ?? Data()
        let fileContentsAsString = String(bytes: fileContents, encoding: .utf8) ?? ""
        debugPrint("File read contents: \(fileContentsAsString)")
        return fileContentsAsString
    }
    
    func deleteFile(at path: AppDirectories, withName name: String) -> Bool {
        let filePath = buildFullPath(forFileName: name, inDirectory: path)
        do {
            try FileManager.default.removeItem(at: filePath)
            debugPrint("File Delted.")
            return true
        } catch {
            return false
        }
    }
    
    func renameFile(at path: AppDirectories, with oldName: String, to newName: String
    ) -> Bool {
        let oldPath = buildFullPath(forFileName: oldName, inDirectory: path)
        let newPath = buildFullPath(forFileName: newName, inDirectory: path)
        do {
            try FileManager.default.moveItem(at: oldPath, to: newPath)
            return true
        } catch {
            return false
        }
    }
    
    func moveFile(withName name: String, inDirectory: AppDirectories, toDirectory directory: AppDirectories) -> Bool {
        let originURL = buildFullPath(forFileName: name, inDirectory: inDirectory)
        let destinationURL = buildFullPath(forFileName: name, inDirectory: directory)
        do {
            try FileManager.default.moveItem(at: originURL, to: destinationURL)
            return true
        } catch {
            return false
        }
    }
    
    func copyFile(withName name: String, inDirectory: AppDirectories, toDirectory directory: AppDirectories) -> Bool {
        let originURL = buildFullPath(forFileName: name, inDirectory: inDirectory)
        let destinationURL = buildFullPath(forFileName: name, inDirectory: directory)
        do {
            try FileManager.default.copyItem(at: originURL, to: destinationURL)
            return true
        } catch {
            return false
        }
    }
    
    func changeFileExtension(withName name: String, inDirectory: AppDirectories, toNewExtension newExtension: String) -> Bool {
        var newFileName = NSString(string: name)
        newFileName = newFileName.deletingPathExtension as NSString
        newFileName = (newFileName.appendingPathExtension(newExtension) as NSString?)!
        let finalFileName = String(newFileName)
        
        let originURL = buildFullPath(forFileName: name, inDirectory: inDirectory)
        let destinationURL = buildFullPath(forFileName: finalFileName, inDirectory: inDirectory)
        do {
            try FileManager.default.moveItem(at: originURL, to: destinationURL)
            return true
        } catch {
            return false
        }
    }
}

struct iOSAppFileSystemDirectory : AppFileManipulation, AppFileStatusChecking, AppFileSystemMetaData {
    let workingDirectory: AppDirectories
    
    init(using directory: AppDirectories) {
        self.workingDirectory = directory
    }
    
    func writeFile(containing text: String, withName name: String) -> Bool {
        return writeFile(containing: text, to: workingDirectory, withName: name)
    }
    
    func readFile(withName name: String) -> String {
        return readFile(at: workingDirectory, withName: name)
    }
    
    func deleteFile(withName name: String) -> Bool {
        return deleteFile(at: workingDirectory, withName: name)
    }
    
    func showAttributes(forFile name: String) {
        let fullPath = buildFullPath(forFileName: name, inDirectory: workingDirectory)
        let fileAttributes = attributes(ofFile: fullPath)
        fileAttributes.forEach {
            debugPrint($0)
        }
    }
    
    func list() {
        list(directory: getURL(for: workingDirectory))
    }
}

let fileName = "newFile.txt"
var iOSDocumentsDirectory = iOSAppFileSystemDirectory(using: .Documents)
iOSDocumentsDirectory.writeFile(containing: "New File Created.", withName: fileName)
iOSDocumentsDirectory.list()
iOSDocumentsDirectory.readFile(withName: fileName)
iOSDocumentsDirectory.showAttributes(forFile: fileName)
iOSDocumentsDirectory.deleteFile(withName: fileName)

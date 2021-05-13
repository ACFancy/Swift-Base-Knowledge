import UIKit
// 感觉不应该叫适配器设计模式 没有Target，这个是利用POP的思想扩展了protocol的能力。利用protocol的继承的特性
// 和类不一样，没有持有关系
enum AppDirectories : String {
    case Documents = "Documents"
    case Temp = "tmp"
}

protocol AppDirecotryNames {
    func documentsDirectoryURL() -> URL
    func tempDirectoryURL() -> URL
}

extension AppDirecotryNames {
    func documentsDirectoryURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    func tempDirectoryURL() -> URL {
        return FileManager.default.temporaryDirectory
    }
}

struct iOSFile : AppDirecotryNames {
    let fileName: URL

    var fullPathInDocuments: String {
        return documentsDirectoryURL().appendingPathComponent(fileName.absoluteString).path
    }

    var fillPathInTemporary: String {
        return tempDirectoryURL().appendingPathComponent(fileName.absoluteString).path
    }

    var documentsStringPath: String {
        return documentsDirectoryURL().path
    }

    var temporaryStringPath: String {
        return tempDirectoryURL().path
    }

    init(fileName: String) {
        self.fileName = URL(string: fileName)!
    }
}

let url = URL(string: "sss.txt")!
debugPrint("\(url.path)")

let iOSfile = iOSFile(fileName: "newFile.txt")
iOSfile.fullPathInDocuments
iOSfile.fillPathInTemporary

iOSfile.documentsStringPath
iOSfile.temporaryStringPath

iOSfile.documentsDirectoryURL()
iOSfile.tempDirectoryURL()

protocol AppDirectoryAndFileStringPathNamesAdapter :  AppDirecotryNames {
    var fileName: String { get }
    var workingDirectory: AppDirectories { get }

    func documentsDirectoryStringPath() -> String
    func tempDirectoryStringPath() -> String

    func fullPath() -> String
}

extension AppDirectoryAndFileStringPathNamesAdapter {
    func documentsDirectoryStringPath() -> String {
        return documentsDirectoryURL().path
    }

    func tempDirectoryStringPath() -> String {
        return tempDirectoryURL().path
    }

    func fullPath() -> String {
        switch workingDirectory {
        case .Documents:
            return documentsDirectoryURL().appendingPathComponent(fileName).path
        case .Temp:
            return tempDirectoryURL().appendingPathComponent(fileName).path
        }
    }
}

struct AppDirectoryAndFileStringPathNames :  AppDirectoryAndFileStringPathNamesAdapter {
    let fileName: String
    let workingDirectory: AppDirectories

    init(fileName: String, workingDirectory: AppDirectories) {
        self.fileName = fileName
        self.workingDirectory = workingDirectory
    }
}

let appFileDocumentsDirectoryPaths = AppDirectoryAndFileStringPathNames(fileName: "newfile.txt", workingDirectory: .Documents)
appFileDocumentsDirectoryPaths.fullPath()
appFileDocumentsDirectoryPaths.documentsDirectoryStringPath()

appFileDocumentsDirectoryPaths.documentsDirectoryURL()

let appFileTemporaryDirectoryPaths = AppDirectoryAndFileStringPathNames(fileName: "tmp.txt", workingDirectory: .Temp)
appFileTemporaryDirectoryPaths.fullPath()
appFileTemporaryDirectoryPaths.tempDirectoryStringPath()

appFileTemporaryDirectoryPaths.tempDirectoryURL()

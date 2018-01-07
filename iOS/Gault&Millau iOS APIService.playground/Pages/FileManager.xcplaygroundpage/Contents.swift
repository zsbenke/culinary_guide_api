import Foundation

extension FileManager {
    static var documentDirectoryURL: URL {
        return self.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    static var cacheDirectoryURL: URL {
        return self.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}

FileManager.documentDirectoryURL.path
FileManager.cacheDirectoryURL.path

let fileURL = FileManager.documentDirectoryURL.appendingPathComponent("test").appendingPathExtension("txt")

let anotherFileURL = URL(fileURLWithPath: "test", relativeTo: FileManager.documentDirectoryURL).appendingPathExtension("txt")
anotherFileURL.lastPathComponent

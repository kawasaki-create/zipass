import Foundation
import SSZipArchive

public func createPasswordProtectedZip(paths: [String], password: String, outputPath: String, result: @escaping FlutterResult) {
    let success = SSZipArchive.createZipFile(atPath: outputPath, withFilesAtPaths: paths, withPassword: password)
    result(success)
}
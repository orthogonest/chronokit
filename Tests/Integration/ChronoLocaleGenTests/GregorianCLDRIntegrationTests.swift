@testable import ChronoLocaleGen
import Foundation
import Testing

@Suite("Gregorian CLDR Integration Suite", .enabled(if: CLDRValidationCondition.isSubmoduleAvailable))
struct GregorianCLDRIntegrationTests {
    private let fileManager: FileManager = .default
    private let decoder: JSONDecoder = .init()

    private var cldrMainDirectory: URL {
        let currentPath = URL(fileURLWithPath: fileManager.currentDirectoryPath)
        return currentPath.appendingPathComponent("Tools/cldr/cldr-json/cldr-dates-full/main")
    }

    @Test("Validate Gregorian Model against all CLDR locales")
    func validateAllCLDRLocale() throws {
        let mainDir = cldrMainDirectory

        guard fileManager.fileExists(atPath: mainDir.path) else {
            Issue.record("Missing CLDR data folder at: '\(mainDir.path)'. Ensure git submodules are initialized.")
            return
        }

        let content = try fileManager.contentsOfDirectory(at: mainDir, includingPropertiesForKeys: nil)
        let localeDirectories = content.filter {
            (try? $0.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
        }

        #expect(!localeDirectories.isEmpty, "No locale subdirectories were discovered in the target path.")

        var successCount = 0
        var failureCount = 0

        for directory in localeDirectories {
            let localeIdentifier = directory.lastPathComponent
            let jsonFileURL = directory.appendingPathComponent("ca-gregorian.json")

            guard fileManager.fileExists(atPath: jsonFileURL.path) else { continue }

            do {
                let data = try Data(contentsOf: jsonFileURL)
                let result = try decoder.decode(Gregorian.self, from: data)

                if result.main[localeIdentifier] != nil {
                    successCount += 1
                } else {
                    failureCount += 1
                    Issue.record(
                        "Decoded payload succeeded but missing root container key for locale: '\(localeIdentifier)'"
                    )
                }

            } catch {
                failureCount += 1
                Issue.record(
                    error,
                    "Decoding Failure on Target Locale Code: [\(localeIdentifier)] at: \(jsonFileURL.path)"
                )
            }
        }

        print("""
        ======================================================================
        📊 CLDR MODEL VERIFICATION RESULTS
        ======================================================================
         • Successful Decodes : \(successCount) languages
         • Failed Decodes     : \(failureCount) languages
         • Schema Status      : \(failureCount == 0 ? "🟢 100% Compliant" : "🔴 Broken / Drifiting")
        ----------------------------------------------------------------------
        """)
    }
}

enum CLDRValidationCondition {
    static var isSubmoduleAvailable: Bool {
        let fileManager = FileManager.default
        let currentPath = URL(fileURLWithPath: fileManager.currentDirectoryPath)
        let cldrMainPath = currentPath.appendingPathComponent("Tools/cldr/cldr-json/cldr-dates-full/main")
        return fileManager.fileExists(atPath: cldrMainPath.path)
    }
}

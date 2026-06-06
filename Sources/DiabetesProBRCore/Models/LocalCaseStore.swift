import Foundation

public struct SavedCase: Codable, Identifiable, Equatable, Sendable {
    public let id: UUID
    public let createdAt: Date
    public let title: String
    public let result: ClinicalResult

    public init(id: UUID = UUID(), createdAt: Date = Date(), title: String, result: ClinicalResult) {
        self.id = id
        self.createdAt = createdAt
        self.title = title
        self.result = result
    }
}

public enum LocalCaseStoreError: Error, Equatable {
    case explicitConsentRequired
}

public actor LocalCaseStore {
    private let fileURL: URL

    public init(fileURL: URL) {
        self.fileURL = fileURL
    }

    public func load() throws -> [SavedCase] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return [] }
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode([SavedCase].self, from: data)
    }

    public func save(_ savedCase: SavedCase, explicitConsent: Bool) throws {
        guard explicitConsent else { throw LocalCaseStoreError.explicitConsentRequired }
        var cases = try load()
        cases.append(savedCase)
        let data = try JSONEncoder().encode(cases)
        try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: fileURL, options: [.atomic])
    }
}

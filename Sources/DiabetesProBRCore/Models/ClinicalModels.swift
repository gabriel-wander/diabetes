import Foundation

public enum Severity: String, Codable, Sendable, CaseIterable {
    case compatible = "compatível"
    case caution = "cautela"
    case emergency = "emergência"
}

public struct ClinicalAlert: Codable, Equatable, Sendable {
    public let severity: Severity
    public let title: String
    public let message: String

    public init(severity: Severity, title: String, message: String) {
        self.severity = severity
        self.title = title
        self.message = message
    }
}

public struct SourceReference: Codable, Equatable, Sendable {
    public let document: String
    public let edition: String
    public let topic: String

    public init(document: String, edition: String = "SBD 2025", topic: String) {
        self.document = document
        self.edition = edition
        self.topic = topic
    }
}

public struct RuleMetadata: Codable, Equatable, Sendable {
    public let id: String
    public let version: String
    public let updatedAt: String
    public let references: [SourceReference]

    public init(id: String, version: String, updatedAt: String = "2026-06-06", references: [SourceReference]) {
        self.id = id
        self.version = version
        self.updatedAt = updatedAt
        self.references = references
    }
}

public struct ClinicalResult: Codable, Equatable, Sendable {
    public let module: String
    public let classification: String
    public let justification: [String]
    public let recommendation: [String]
    public let alerts: [ClinicalAlert]
    public let metadata: RuleMetadata

    public init(module: String, classification: String, justification: [String], recommendation: [String], alerts: [ClinicalAlert], metadata: RuleMetadata) {
        self.module = module
        self.classification = classification
        self.justification = justification
        self.recommendation = recommendation
        self.alerts = alerts
        self.metadata = metadata
    }

    public var clinicalSummary: String {
        let alertText = alerts.map { "[\($0.severity.rawValue)] \($0.title): \($0.message)" }.joined(separator: "\n")
        return """
        Módulo: \(module)
        Classificação: \(classification)
        Justificativa: \(justification.joined(separator: "; "))
        Recomendações: \(recommendation.joined(separator: "; "))
        Alertas: \(alertText)
        Regra: \(metadata.id) v\(metadata.version) (\(metadata.updatedAt))
        """
    }
}

public enum DiabetesType: String, Codable, Sendable, CaseIterable {
    case type1 = "DM1"
    case type2 = "DM2"
    case prediabetes = "Pré-diabetes"
    case gestational = "Gestacional"
    case unknown = "Não definido"
}

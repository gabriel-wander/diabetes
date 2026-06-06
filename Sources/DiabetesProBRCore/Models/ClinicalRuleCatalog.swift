import Foundation

public struct ClinicalRuleCatalog: Codable, Equatable, Sendable {
    public let catalogVersion: String
    public let updatedAt: String
    public let sourceEdition: String
    public let rules: [ClinicalRuleDefinition]

    public init(catalogVersion: String, updatedAt: String, sourceEdition: String, rules: [ClinicalRuleDefinition]) {
        self.catalogVersion = catalogVersion
        self.updatedAt = updatedAt
        self.sourceEdition = sourceEdition
        self.rules = rules
    }

    public func rule(withID id: String) -> ClinicalRuleDefinition? {
        rules.first { $0.id == id }
    }

    public static func bundled() throws -> ClinicalRuleCatalog {
        guard let url = Bundle.module.url(forResource: "clinical_rules_sbd2025", withExtension: "json") else {
            throw ClinicalRuleCatalogError.missingBundledCatalog
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(ClinicalRuleCatalog.self, from: data)
    }
}

public struct ClinicalRuleDefinition: Codable, Equatable, Sendable {
    public let id: String
    public let module: String
    public let document: String
    public let topic: String
    public let version: String
    public let updatedAt: String
    public let parameters: [String: RuleParameter]
}

public enum RuleParameter: Codable, Equatable, Sendable {
    case string(String)
    case number(Double)
    case boolean(Bool)
    case stringArray([String])

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Bool.self) {
            self = .boolean(value)
        } else if let value = try? container.decode(Double.self) {
            self = .number(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode([String].self) {
            self = .stringArray(value)
        } else {
            throw DecodingError.typeMismatch(RuleParameter.self, .init(codingPath: decoder.codingPath, debugDescription: "Parâmetro de regra não suportado"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value): try container.encode(value)
        case .number(let value): try container.encode(value)
        case .boolean(let value): try container.encode(value)
        case .stringArray(let value): try container.encode(value)
        }
    }
}

public enum ClinicalRuleCatalogError: Error, Equatable {
    case missingBundledCatalog
}

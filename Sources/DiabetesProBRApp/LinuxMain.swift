#if !canImport(SwiftUI)
import DiabetesProBRCore

@main
struct DiabetesProBRCommandLineFallback {
    static func main() throws {
        let catalog = try ClinicalRuleCatalog.bundled()
        print("Diabetes Pro BR — catálogo de regras \(catalog.sourceEdition) v\(catalog.catalogVersion) carregado com \(catalog.rules.count) regras.")
    }
}
#endif

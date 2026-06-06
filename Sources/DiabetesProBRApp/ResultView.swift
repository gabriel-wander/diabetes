#if canImport(SwiftUI)
import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
import DiabetesProBRCore

struct ResultView: View {
    let result: ClinicalResult
    @State private var showJustification = true
    @State private var showReferences = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ResultCard(title: "Classificação", icon: "doc.text.magnifyingglass") {
                    Text(result.classification).font(.title3.bold())
                }

                ResultCard(title: "Recomendação", icon: "checklist") {
                    BulletList(items: result.recommendation)
                }

                ForEach(Array(result.alerts.enumerated()), id: \.offset) { _, alert in
                    AlertCard(alert: alert)
                }

                Button(showJustification ? "Ocultar justificativa" : "Ver justificativa") {
                    withAnimation { showJustification.toggle() }
                }
                .buttonStyle(.borderedProminent)

                if showJustification {
                    ResultCard(title: "Justificativa", icon: "text.quote") {
                        BulletList(items: result.justification)
                    }
                }

                Button(showReferences ? "Ocultar referências" : "Ver referências") {
                    withAnimation { showReferences.toggle() }
                }
                .buttonStyle(.bordered)

                if showReferences {
                    ResultCard(title: "Referências e auditoria", icon: "books.vertical") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Regra: \(result.metadata.id) v\(result.metadata.version)")
                            Text("Data: \(result.metadata.updatedAt)")
                            ForEach(Array(result.metadata.references.enumerated()), id: \.offset) { _, reference in
                                Text("\(reference.edition): \(reference.document) — \(reference.topic)")
                            }
                        }
                        .font(.footnote)
                    }
                }

                CopySummaryButton(summary: result.clinicalSummary)
            }
            .padding()
        }
        .navigationTitle(result.module)
        .navigationBarTitleDisplayMode(.inline)
    }
}


struct CopySummaryButton: View {
    let summary: String
    @State private var didCopy = false

    var body: some View {
        Button {
            copyToPasteboard(summary)
            didCopy = true
        } label: {
            Label(didCopy ? "Resumo copiado" : "Copiar resumo clínico", systemImage: didCopy ? "checkmark" : "doc.on.doc")
        }
        .buttonStyle(.borderedProminent)
    }

    private func copyToPasteboard(_ text: String) {
        #if canImport(UIKit)
        UIPasteboard.general.string = text
        #elseif canImport(AppKit)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #else
        // Em plataformas sem pasteboard gráfico, o texto permanece disponível via clinicalSummary para integração pelo host.
        #endif
    }
}

struct ResultCard<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon).font(.headline)
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct AlertCard: View {
    let alert: ClinicalAlert

    var color: Color {
        switch alert.severity {
        case .compatible: return .green
        case .caution: return .yellow
        case .emergency: return .red
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(alert.title, systemImage: alert.severity == .emergency ? "exclamationmark.octagon.fill" : "exclamationmark.triangle.fill")
                .font(.headline)
            Text(alert.message).font(.subheadline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.16), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(color.opacity(0.45)))
    }
}

struct BulletList: View {
    let items: [String]
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(items, id: \.self) { item in
                HStack(alignment: .top) {
                    Text("•")
                    Text(item)
                }
            }
        }
    }
}
#endif

#if canImport(SwiftUI)
import SwiftUI
import DiabetesProBRCore

struct ModuleCard: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let systemImage: String
    let result: ClinicalResult
}

struct HomeView: View {
    private let engine = ClinicalRuleEngine()
    private var modules: [ModuleCard] {
        [
            ModuleCard(title: "Diagnóstico", subtitle: "Critérios e rastreamento", systemImage: "stethoscope", result: engine.evaluateDiagnosis(MockCases.diagnosisConfirmed)),
            ModuleCard(title: "Classificação", subtitle: "DM1, DM2 e outros", systemImage: "list.bullet.clipboard", result: engine.evaluateClassification(MockCases.classificationType1)),
            ModuleCard(title: "Metas", subtitle: "Alvos individualizados", systemImage: "target", result: engine.evaluateTargets(MockCases.targetsAdultDM1CGM)),
            ModuleCard(title: "DM2", subtitle: "Tratamento inicial/seguimento", systemImage: "pills", result: engine.evaluateDM2Treatment(MockCases.dm2Cardiorenal)),
            ModuleCard(title: "DM1 Insulina", subtitle: "Basal-bolus e cálculos", systemImage: "syringe", result: engine.evaluateDM1Insulin(MockCases.dm1InsulinAdult)),
            ModuleCard(title: "Dias de doença", subtitle: "Alertas de CAD", systemImage: "exclamationmark.triangle", result: engine.evaluateSickDay(MockCases.sickDayEmergency)),
            ModuleCard(title: "Insulina segura", subtitle: "Técnica e armazenamento", systemImage: "checkmark.shield", result: engine.insulinSafetyEducation()),
            ModuleCard(title: "Idoso", subtitle: "Fragilidade e desintensificação", systemImage: "figure.walk", result: engine.evaluateElderly(MockCases.elderlyComplex)),
            ModuleCard(title: "Pré-diabetes", subtitle: "Versão futura", systemImage: "clock", result: engine.futureModule(title: "Pré-diabetes")),
            ModuleCard(title: "DHEM/obesidade", subtitle: "Versão futura", systemImage: "heart.text.square", result: engine.futureModule(title: "DHEM/obesidade"))
        ]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    MedicalDisclaimerCard()
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 14)], spacing: 14) {
                        ForEach(modules) { module in
                            NavigationLink(value: module.title) {
                                VStack(alignment: .leading, spacing: 12) {
                                    Image(systemName: module.systemImage).font(.title2).foregroundStyle(.blue)
                                    Text(module.title).font(.headline).foregroundStyle(.primary)
                                    Text(module.subtitle).font(.caption).foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Diabetes Pro BR")
            .navigationDestination(for: String.self) { title in
                if let module = modules.first(where: { $0.title == title }) {
                    ResultView(result: module.result)
                }
            }
        }
    }
}

struct MedicalDisclaimerCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Uso médico — apoio à decisão", systemImage: "cross.case")
                .font(.headline)
            Text("Aplicativo offline-first para apoio técnico. Não substitui julgamento clínico, diretrizes completas, prescrição individualizada ou protocolos locais. Nenhum dado sensível é enviado a servidores; salve casos localmente apenas se desejar.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.yellow.opacity(0.14), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
#endif

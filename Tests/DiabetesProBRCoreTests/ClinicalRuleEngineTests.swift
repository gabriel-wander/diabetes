import Foundation
import Testing
@testable import DiabetesProBRCore

@Suite("Motor de regras clínicas SBD 2025")
struct ClinicalRuleEngineTests {
    let engine = ClinicalRuleEngine()

    @Test("Diagnóstico confirmado quando há dois critérios laboratoriais")
    func diagnosisConfirmedWithTwoCriteria() {
        let result = engine.evaluateDiagnosis(.init(fastingGlucose: 126, hba1c: 6.5))
        #expect(result.classification == "Diabetes confirmado")
        #expect(result.justification.contains { $0.contains("Glicemia de jejum") })
        #expect(result.justification.contains { $0.contains("HbA1c") })
    }

    @Test("Um critério isolado gera diabetes provável e pede repetição")
    func singleCriterionRequiresConfirmation() {
        let result = engine.evaluateDiagnosis(.init(fastingGlucose: 130))
        #expect(result.classification == "Diabetes provável")
        #expect(result.recommendation.contains { $0.localizedCaseInsensitiveContains("Repetir") })
    }

    @Test("Condição invalidante sinaliza HbA1c potencialmente incongruente")
    func invalidHbA1cConditionsAlert() {
        let result = engine.evaluateDiagnosis(.init(hba1c: 6.6, hba1cInvalidatingConditions: ["anemia"]))
        #expect(result.alerts.contains { $0.title == "HbA1c potencialmente incongruente" })
    }

    @Test("Metas com gestação ficam bloqueadas no MVP")
    func targetsPregnancyBlocked() {
        let result = engine.evaluateTargets(.init(diabetesType: .type1, pregnancy: true))
        #expect(result.classification == "Não implementado")
        #expect(result.recommendation.first?.contains("Não implementado") == true)
    }

    @Test("DM2 cardiorrenal prioriza benefício cardiorrenal")
    func dm2CardiorenalPriority() {
        let result = engine.evaluateDM2Treatment(.init(hba1c: 7.2, bmi: 30, eGFR: 45, albuminuria: true, ckd: true))
        #expect(result.classification.contains("cardiorrenal"))
        #expect(result.recommendation.contains { $0.contains("benefício cardiorrenal") })
    }

    @Test("DM1 insulina calcula DTD, basal-bolus, FS e razão carboidrato")
    func dm1InsulinCalculations() {
        let result = engine.evaluateDM1Insulin(.init(weightKg: 70, mealCarbohydrates: 60, currentTotalDailyDose: 56))
        #expect(result.recommendation.contains { $0.contains("28") && $0.contains("basal") })
        #expect(result.recommendation.contains { $0.contains("2000/DTD") })
        #expect(result.recommendation.contains { $0.contains("400/DTD") })
        #expect(result.alerts.contains { $0.title == "Nunca suspender basal" })
    }

    @Test("Dias de doença aciona emergência por cetonemia e vômitos")
    func sickDayEmergency() {
        let result = engine.evaluateSickDay(.init(vomitingHours: 3, ketonemia: 2.0))
        #expect(result.classification == "Procurar emergência imediatamente")
        #expect(result.alerts.contains { $0.severity == .emergency })
    }

    @Test("Idoso complexo sugere simplificação/desintensificação")
    func elderlyComplex() {
        let result = engine.evaluateElderly(.init(age: 84, functionalDependence: true, frailty: true, hypoglycemia: true, usesInsulinOrSulfonylurea: true))
        #expect(result.classification.contains("simplificação"))
        #expect(result.recommendation.contains { $0.localizedCaseInsensitiveContains("desintensificação") })
    }

    @Test("Catálogo JSON versionado é carregado dos recursos locais")
    func bundledRuleCatalogLoads() throws {
        let catalog = try ClinicalRuleCatalog.bundled()
        #expect(catalog.sourceEdition == "SBD 2025")
        #expect(catalog.rule(withID: "diagnosis.v1")?.document == "01_diagnostico_diabetes.pdf")
        #expect(catalog.rule(withID: "dm1-sick-day.v1")?.parameters["emergencyTriggers"] != nil)
    }

    @Test("Salvar caso exige consentimento explícito")
    func localCaseStoreRequiresExplicitConsent() async throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathComponent("cases.json")
        let store = LocalCaseStore(fileURL: url)
        let result = engine.evaluateDiagnosis(.init(fastingGlucose: 126, hba1c: 6.5))
        let savedCase = SavedCase(title: "Caso teste", result: result)

        do {
            try await store.save(savedCase, explicitConsent: false)
            Issue.record("Salvar sem consentimento deveria falhar")
        } catch LocalCaseStoreError.explicitConsentRequired {
            // Esperado: o MVP só persiste caso local se o usuário/host confirmar consentimento explícito.
        }

        try await store.save(savedCase, explicitConsent: true)
        let loaded = try await store.load()
        #expect(loaded == [savedCase])
    }

}

import Foundation

public struct ClinicalRuleEngine: Sendable {
    public init() {}

    public func evaluateDiagnosis(_ input: DiagnosisInput) -> ClinicalResult {
        var justifications: [String] = []
        var recommendations: [String] = []
        var alerts: [ClinicalAlert] = safetyDisclaimer()
        var diabetesCriteriaCount = 0
        var prediabetesCriteriaCount = 0

        // Regra SBD 2025: glicemia de jejum >=126 mg/dL preenche critério laboratorial para diabetes.
        if let value = input.fastingGlucose {
            if value >= 126 { diabetesCriteriaCount += 1; justifications.append("Glicemia de jejum \(format(value)) mg/dL ≥126 mg/dL") }
            else if value >= 100 { prediabetesCriteriaCount += 1; justifications.append("Glicemia de jejum \(format(value)) mg/dL entre 100–125 mg/dL") }
            else { justifications.append("Glicemia de jejum \(format(value)) mg/dL em faixa não diagnóstica") }
        }

        // Regra SBD 2025: HbA1c >=6,5% preenche critério para diabetes quando o método é confiável.
        if let value = input.hba1c {
            if value >= 6.5 { diabetesCriteriaCount += 1; justifications.append("HbA1c \(format(value))% ≥6,5%") }
            else if value >= 5.7 { prediabetesCriteriaCount += 1; justifications.append("HbA1c \(format(value))% entre 5,7–6,4%") }
            else { justifications.append("HbA1c \(format(value))% em faixa não diagnóstica") }
        }

        // Regra SBD 2025: TTGO de 1 hora >=209 mg/dL é considerado critério de diabetes no documento-base informado.
        if let value = input.ogtt1h {
            if value >= 209 { diabetesCriteriaCount += 1; justifications.append("TTGO 1h \(format(value)) mg/dL ≥209 mg/dL") }
        }

        // Regra SBD 2025: TTGO de 2 horas >=200 mg/dL preenche critério laboratorial para diabetes.
        if let value = input.ogtt2h {
            if value >= 200 { diabetesCriteriaCount += 1; justifications.append("TTGO 2h \(format(value)) mg/dL ≥200 mg/dL") }
            else if value >= 140 { prediabetesCriteriaCount += 1; justifications.append("TTGO 2h \(format(value)) mg/dL entre 140–199 mg/dL") }
        }

        if input.typicalSymptoms {
            alerts.append(.init(severity: .caution, title: "Sintomas típicos", message: "Sintomas de hiperglicemia aumentam a urgência de avaliação clínica e podem modificar a necessidade de confirmação laboratorial."))
        }

        if !input.hba1cInvalidatingConditions.isEmpty {
            alerts.append(.init(severity: .caution, title: "HbA1c potencialmente incongruente", message: "Condições informadas: \(input.hba1cInvalidatingConditions.joined(separator: ", ")). Interpretar HbA1c com cautela e priorizar glicemia/TTGO quando apropriado."))
        }

        let classification: String
        if diabetesCriteriaCount >= 2 || (diabetesCriteriaCount >= 1 && input.typicalSymptoms) {
            classification = "Diabetes confirmado"
            recommendations.append("Registrar critérios positivos, avaliar tipo de diabetes e iniciar plano individualizado de tratamento/seguimento.")
        } else if diabetesCriteriaCount == 1 {
            classification = "Diabetes provável"
            recommendations.append("Repetir exame alterado ou obter segundo teste diagnóstico para confirmação, salvo contexto clínico inequívoco.")
        } else if prediabetesCriteriaCount > 0 {
            classification = "Pré-diabetes"
            recommendations.append("Orientar intervenção de estilo de vida e considerar módulo específico de pré-diabetes; se risco elevado, TTGO pode ser útil.")
        } else {
            classification = "Normal"
            recommendations.append(input.riskFactors.isEmpty ? "Manter rastreamento conforme risco clínico." : "Há fatores de risco; considerar periodicidade de rastreamento e TTGO se suspeita clínica persistir.")
        }

        if input.ogtt1h == nil && input.ogtt2h == nil && !input.riskFactors.isEmpty && diabetesCriteriaCount == 0 {
            recommendations.append("Sugerir TTGO quando houver fatores de risco ou discordância entre exames disponíveis.")
        }

        return ClinicalResult(module: "Diagnóstico e rastreamento", classification: classification, justification: justifications, recommendation: recommendations, alerts: alerts, metadata: metadata("diagnosis.v1", "1.0", "01_diagnostico_diabetes.pdf", "Critérios diagnósticos e rastreamento"))
    }

    public func evaluateClassification(_ input: ClassificationInput) -> ClinicalResult {
        var justifications: [String] = []
        var recommendations = ["Solicitar investigação complementar quando a apresentação não for típica ou houver sinais de etiologia específica."]
        var alerts = safetyDisclaimer()
        var classification = "Necessidade de investigação complementar"

        // Regra: gestação direciona a possibilidade de diabetes gestacional; o MVP não fecha diagnóstico gestacional.
        if input.pregnancy {
            classification = "Diabetes gestacional possível"
            justifications.append("Gravidez informada")
            recommendations.append("Não implementado nesta versão — consultar diretriz específica de diabetes na gestação.")
        // Regra: pancreatopatia/endocrinopatia ou medicação diabetogênica favorece diabetes secundário/outros tipos.
        } else if input.pancreatopathyOrEndocrinopathy || !input.associatedMedications.isEmpty {
            classification = "Diabetes secundário/outros tipos possível"
            justifications.append("Há pancreatopatia/endocrinopatia ou medicação associada")
        // Regra: autoanticorpos positivos, cetose/CAD, necessidade precoce de insulina ou peptídeo C baixo favorecem DM1.
        } else if input.autoantibodiesPositive == true || input.ketosisOrDKA || (input.needsInsulin && (input.evolutionWeeks ?? 999) <= 12) || input.cPeptideLow == true {
            classification = "DM1 provável"
            justifications.append("Autoimunidade/cetose/CAD/insulinopenia ou necessidade precoce de insulina sugerem DM1")
            alerts.append(.init(severity: .emergency, title: "Risco de CAD", message: "Se cetose, CAD ou sintomas graves estiverem presentes, avaliar urgência/emergência imediatamente."))
        // Regra: início jovem com história familiar forte e ausência de marcadores de insulinopenia sugere diabetes monogênico.
        } else if let age = input.age, age < 35, input.familyHistory, input.autoantibodiesPositive == false, input.cPeptideLow == false {
            classification = "Diabetes monogênico possível"
            justifications.append("Idade jovem, história familiar e ausência de autoimunidade/insulinopenia sugerem investigação de MODY/monogênico")
        // Regra: idade adulta, IMC elevado e ausência de cetose/autoimunidade favorecem DM2.
        } else if (input.age ?? 0) >= 35 || (input.bmi ?? 0) >= 25 {
            classification = "DM2 provável"
            justifications.append("Idade adulta e/ou IMC elevado sem sinais predominantes de insulinopenia favorecem DM2")
        }

        return ClinicalResult(module: "Classificação do diabetes", classification: classification, justification: justifications, recommendation: recommendations, alerts: alerts, metadata: metadata("classification.v1", "1.0", "02_classificacao_diabetes.pdf", "Classificação etiológica"))
    }

    public func evaluateTargets(_ input: TargetsInput) -> ClinicalResult {
        var recommendations: [String] = []
        var alerts = safetyDisclaimer()
        var classification = "Meta padrão"
        var hba1cTarget = "HbA1c <7%"

        // Regra: gestação tem metas próprias e está bloqueada neste MVP.
        if input.pregnancy || input.diabetesType == .gestational {
            return ClinicalResult(module: "Metas individualizadas", classification: "Não implementado", justification: ["Gestação informada"], recommendation: ["Não implementado nesta versão — consultar diretriz específica."], alerts: alerts, metadata: metadata("targets.v1", "1.0", "03_metas_tratamento_diabetes.pdf", "Metas glicêmicas"))
        }

        // Regra: meta geral de HbA1c <7% se não houver hipoglicemia grave/frequente.
        if input.severeOrFrequentHypoglycemia || input.frailty || input.limitedLifeExpectancy {
            classification = "Meta relaxada"
            hba1cTarget = "Individualizar acima de 7% conforme fragilidade, hipoglicemia e expectativa de vida"
            alerts.append(.init(severity: .caution, title: "Evitar hipoglicemia", message: "História de hipoglicemia/fragilidade favorece metas menos intensivas e revisão de insulina/sulfonilureia."))
        } else if input.age ?? 99 < 65 && input.comorbidities.isEmpty {
            classification = "Meta mais intensiva possível"
            hba1cTarget = "HbA1c <7%; considerar alvo menor apenas se seguro e sem hipoglicemia"
        }

        recommendations.append(hba1cTarget)
        // Regra: alvo pré-prandial/jejum 80–130 mg/dL para adultos não gestantes, individualizando.
        recommendations.append("Glicemia de jejum/pré-prandial: 80–130 mg/dL, se seguro")
        // Regra: alvo de glicemia 2h pós-refeição <180 mg/dL no MVP.
        recommendations.append("Glicemia 2h pós-refeição: <180 mg/dL")
        if input.cgmAvailable {
            // Regra: TIR 70–180 mg/dL >70%, tempo <70 <4%, tempo <54 <1% e CV <36% para DM1 não gestante.
            recommendations.append("CGM: TIR 70–180 mg/dL >70%; tempo <70 mg/dL <4%; tempo <54 mg/dL <1%; CV glicêmico <36%")
        }
        recommendations.append("Individualizar por comorbidades, DRC/DCV, risco de hipoglicemia, preferências e segurança.")

        return ClinicalResult(module: "Metas individualizadas", classification: classification, justification: ["Metas definidas por segurança, hipoglicemia, idade, fragilidade e comorbidades"], recommendation: recommendations, alerts: alerts, metadata: metadata("targets.v1", "1.0", "03_metas_tratamento_diabetes.pdf", "Metas glicêmicas"))
    }

    public func evaluateDM2Treatment(_ input: DM2TreatmentInput) -> ClinicalResult {
        var justifications = ["Risco CV, IMC, HbA1c e função renal devem ser avaliados antes da estratégia terapêutica."]
        var recommendations: [String] = []
        var alerts = safetyDisclaimer()
        let hasCardiorenalDisease = input.ascvd || input.heartFailure || input.ckd || input.albuminuria || (input.eGFR ?? 999) < 60
        let highRisk = hasCardiorenalDisease || input.hypertension || input.smoking || (input.ldl ?? 0) >= 100 || input.prematureCADFamilyHistory
        let risk = hasCardiorenalDisease ? "alto/muito alto risco cardiovascular ou cardiorrenal" : (highRisk ? "risco cardiovascular aumentado" : "baixo/intermediário risco cardiovascular")

        // Regra: alto/muito alto risco CV, DRC ou IC prioriza classes com benefício cardiorrenal.
        if hasCardiorenalDisease {
            recommendations.append("Priorizar iSGLT2 e/ou AR GLP-1 com benefício cardiorrenal conforme fenótipo (DRC, IC ou DCV), TFG, contraindicações e acesso.")
            justifications.append("Presença de DCV/IC/DRC/albuminúria ou TFG reduzida")
        // Regra: baixo/intermediário risco, sem sobrepeso/obesidade e HbA1c <7,5%: metformina em monoterapia como primeira escolha.
        } else if !input.overweightOrObesity && (input.hba1c ?? 99) < 7.5 {
            recommendations.append("Metformina em monoterapia como primeira escolha, se tolerada e sem contraindicação.")
            justifications.append("Baixo/intermediário risco, sem sobrepeso/obesidade e HbA1c <7,5%")
        // Regra: baixo/intermediário risco com sobrepeso/obesidade e HbA1c <7,5%: considerar AR GLP-1 ou agonista GLP-1/GIP.
        } else if input.overweightOrObesity && (input.hba1c ?? 99) < 7.5 {
            recommendations.append("Considerar AR GLP-1 ou agonista GLP-1/GIP para glicemia e peso.")
            recommendations.append("Se AR GLP-1/GIP não acessível ou tolerado, considerar iSGLT2 ou metformina.")
            justifications.append("Sobrepeso/obesidade com HbA1c <7,5%")
        } else {
            recommendations.append("Priorizar controle glicêmico com combinação individualizada; avaliar necessidade de intensificação e encaminhamento se descompensação ou dúvida diagnóstica.")
            justifications.append("HbA1c acima do limiar inicial ou dados incompletos exigem estratégia individualizada")
        }

        if input.eGFR == nil || input.hba1c == nil || input.bmi == nil {
            alerts.append(.init(severity: .caution, title: "Dados obrigatórios incompletos", message: "HbA1c, IMC e função renal são necessários para uma recomendação mais segura."))
        }
        alerts.append(.init(severity: .caution, title: "Escolha depende do contexto", message: "Verificar TFG, contraindicações/intolerâncias, custo, SUS/particular e disponibilidade antes de prescrever."))
        if input.hypoglycemiaRisk { recommendations.append("Evitar classes com maior risco de hipoglicemia quando possível e revisar metas.") }
        recommendations.append("Intensificar se HbA1c permanecer acima da meta após período adequado de adesão/intervenção; encaminhar se CAD, insulinopenia, DRC avançada, IC instável, hipoglicemia grave ou falha terapêutica.")

        return ClinicalResult(module: "Tratamento do DM2", classification: risk, justification: justifications, recommendation: recommendations, alerts: alerts, metadata: metadata("dm2-treatment.v1", "1.0", "04_manejo_dm2.pdf", "Manejo da terapia antidiabética"))
    }

    public func evaluateDM1Insulin(_ input: DM1InsulinInput) -> ClinicalResult {
        var alerts = safetyDisclaimer()
        guard let weight = input.weightKg, weight > 0 else {
            return ClinicalResult(module: "Insulinoterapia no DM1", classification: "Dados insuficientes", justification: ["Peso não informado"], recommendation: ["Informar peso para estimativa inicial. Não implementado nesta versão para gestação — consultar diretriz específica se gestante."], alerts: alerts, metadata: metadata("dm1-insulin.v1", "1.0", "09_insulinoterapia_dm1.pdf", "Insulinoterapia no DM1"))
        }

        // Regra: DTD estimada em DM1 varia de 0,4 a 1,0 U/kg/dia, ajustável por puberdade, gestação e infecção.
        let baseRange = (0.4 * weight, 1.0 * weight)
        let selectedTDD = input.currentTotalDailyDose ?? ((baseRange.0 + baseRange.1) / 2)
        // Regra: distribuição inicial aproximada de 50% basal e 50% prandial em adultos, com individualização.
        let basal = selectedTDD * 0.5
        let prandialTotal = selectedTDD * 0.5
        // Regra: fator de sensibilidade = 2000/DTD; pode-se considerar 1800/DTD em adultos.
        let sensitivity2000 = 2000 / selectedTDD
        let sensitivity1800 = 1800 / selectedTDD
        // Regra: razão insulina/carboidrato = 400/DTD.
        let carbRatio = 400 / selectedTDD

        var recommendations = [
            "DTD estimada: \(format(baseRange.0))–\(format(baseRange.1)) U/dia (usar \(format(selectedTDD)) U/dia como referência inicial/configurada).",
            "Basal-bolus é estratégia preferencial; basal aproximada \(format(basal)) U/dia e prandial total aproximada \(format(prandialTotal)) U/dia, individualizando.",
            "FS: 2000/DTD ≈ \(format(sensitivity2000)) mg/dL por U; em adultos, considerar 1800/DTD ≈ \(format(sensitivity1800)) mg/dL por U conforme diretriz.",
            "Razão insulina/carboidrato: 400/DTD ≈ 1 U para \(format(carbRatio)) g de carboidrato.",
            "Horários dependem do tipo de insulina basal/prandial informado, rotina alimentar e monitorização."
        ]
        if let carbs = input.mealCarbohydrates { recommendations.append("Bolus estimado para refeição de \(format(carbs)) g: \(format(carbs / carbRatio)) U antes de correções e segurança clínica.") }
        if input.pregnancy { recommendations.append("Não implementado nesta versão para gestação — consultar diretriz específica.") }
        if input.acuteIllness || input.pubertalPhase { recommendations.append("Puberdade/doença aguda podem aumentar necessidade de insulina; reavaliar frequentemente.") }
        alerts.append(.init(severity: .emergency, title: "Nunca suspender basal", message: "No DM1, não recomendar suspensão de insulina basal; risco de CAD."))

        return ClinicalResult(module: "Insulinoterapia no DM1", classification: "Estimativa inicial auditável", justification: ["Peso \(format(weight)) kg; regra 0,4–1,0 U/kg/dia; basal-bolus 50/50 inicial"], recommendation: recommendations, alerts: alerts, metadata: metadata("dm1-insulin.v1", "1.0", "09_insulinoterapia_dm1.pdf", "Insulinoterapia no DM1"))
    }

    public func evaluateSickDay(_ input: SickDayInput) -> ClinicalResult {
        var emergencyReasons: [String] = []
        // Regra: vômitos persistentes >2h é alerta obrigatório de emergência.
        if input.vomitingHours > 2 { emergencyReasons.append("vômitos persistentes >2h") }
        // Regra: alteração neurológica é alerta obrigatório de emergência.
        if input.drowsinessOrConfusion { emergencyReasons.append("alteração neurológica") }
        // Regra: cetonemia >1,5 mmol/L ou cetonúria alta apesar de hidratação/insulina é alerta obrigatório.
        if (input.ketonemia ?? 0) > 1.5 || input.highKetonuria { emergencyReasons.append("cetonemia >1,5 mmol/L ou cetonúria alta") }
        if input.abdominalPain { emergencyReasons.append("dor abdominal importante") }
        if input.kussmaulBreathing { emergencyReasons.append("respiração de Kussmaul") }
        if input.dehydration { emergencyReasons.append("desidratação") }
        if let glucose = input.glucose, glucose <= 70 && !input.oralIntakePossible { emergencyReasons.append("incapacidade de manter glicemia >70 mg/dL") }
        if input.ageUnder5 { emergencyReasons.append("criança <5 anos") }
        if !input.familyCanManageHomeCare { emergencyReasons.append("família incapaz de acompanhar em domicílio") }

        var alerts = safetyDisclaimer()
        let classification: String
        let recommendations: [String]
        if emergencyReasons.isEmpty {
            classification = "Manejo domiciliar possível com cautela"
            recommendations = ["Intensificar monitorização de glicemia e cetonas.", "Manter hidratação e carboidratos conforme tolerância.", "Nunca suspender insulina basal.", "Dose extra de insulina deve seguir protocolo institucional configurável; não há prescrição automática definitiva."]
        } else {
            classification = "Procurar emergência imediatamente"
            recommendations = ["Encaminhar para avaliação emergencial agora.", "Manter medidas de segurança enquanto aguarda atendimento; não suspender basal."]
            alerts.append(.init(severity: .emergency, title: "Critérios de emergência", message: emergencyReasons.joined(separator: "; ")))
        }

        return ClinicalResult(module: "Dias de doença no DM1", classification: classification, justification: emergencyReasons.isEmpty ? ["Nenhum alerta obrigatório de emergência informado"] : emergencyReasons, recommendation: recommendations, alerts: alerts, metadata: metadata("dm1-sick-day.v1", "1.0", "10_dias_de_doenca_dm1.pdf", "Manejo dos dias de doença no DM1"))
    }

    public func insulinSafetyEducation() -> ClinicalResult {
        let recommendations = ["Aplicação subcutânea com técnica adequada.", "Preferir agulha curta quando apropriado.", "Realizar rodízio estruturado dos locais de aplicação.", "Inspecionar e evitar áreas de lipohipertrofia.", "Orientar armazenamento e transporte conforme tipo de insulina.", "Descartar perfurocortantes de forma segura.", "Insulina é medicamento de alto risco: conferir tipo, dose, horário e dispositivo."]
        return ClinicalResult(module: "Técnica segura de insulina", classification: "Conteúdo educacional médico", justification: ["Boas práticas de preparo e aplicação segura"], recommendation: recommendations, alerts: safetyDisclaimer() + [.init(severity: .caution, title: "Medicamento de alto risco", message: "Erros com insulina podem causar hipoglicemia grave, hiperglicemia e CAD.")], metadata: metadata("insulin-safety.v1", "1.0", "11_aplicacao_segura_insulina.pdf", "Práticas seguras de preparo e aplicação"))
    }

    public func evaluateElderly(_ input: ElderlyInput) -> ClinicalResult {
        var alerts = safetyDisclaimer()
        let complex = input.functionalDependence || input.cognitiveImpairment || input.frailty || input.multimorbidity || input.limitedLifeExpectancy
        let classification = complex ? "Meta relaxada / simplificação terapêutica" : "Meta padrão ou mais intensiva se segura"
        var recommendations = complex ? ["Priorizar evitar hipoglicemia, sintomas e eventos adversos.", "Considerar desintensificação e simplificação terapêutica."] : ["Meta pode ser padrão ou mais intensiva se baixo risco de hipoglicemia e boa funcionalidade."]
        if input.polypharmacy { recommendations.append("Revisar polifarmácia, interações e adesão.") }
        if input.hypoglycemia || input.usesInsulinOrSulfonylurea {
            alerts.append(.init(severity: .caution, title: "Risco de hipoglicemia", message: "Reavaliar insulina/sulfonilureia, metas e capacidade de autocuidado."))
        }
        return ClinicalResult(module: "Idoso com diabetes", classification: classification, justification: ["Funcionalidade, cognição, fragilidade, multimorbidade, polifarmácia e expectativa de vida informam metas"], recommendation: recommendations, alerts: alerts, metadata: metadata("elderly.v1", "1.0", "08_idoso_com_diabetes.pdf", "Paciente idoso com diabetes"))
    }

    public func futureModule(title: String) -> ClinicalResult {
        ClinicalResult(module: title, classification: "Não implementado", justification: ["Módulo previsto para versão futura"], recommendation: ["Não implementado nesta versão — consultar diretriz específica."], alerts: safetyDisclaimer(), metadata: metadata("future.v1", "0.1", "05_pre_diabetes.pdf / 06_obesidade_prevencao_cv.pdf / 07_dhem_dm2_pre_diabetes.pdf", "Escopo futuro"))
    }

    private func safetyDisclaimer() -> [ClinicalAlert] {
        [.init(severity: .caution, title: "Apoio clínico", message: "Ferramenta de apoio técnico para médicos; não substitui julgamento clínico, prescrição individualizada nem protocolos locais.")]
    }

    private func metadata(_ id: String, _ version: String, _ document: String, _ topic: String) -> RuleMetadata {
        RuleMetadata(id: id, version: version, references: [.init(document: document, topic: topic)])
    }

    private func format(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(value)) : String(format: "%.1f", value)
    }
}

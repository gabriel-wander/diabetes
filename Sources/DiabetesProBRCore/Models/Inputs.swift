import Foundation

public struct DiagnosisInput: Codable, Equatable, Sendable {
    public var fastingGlucose: Double?
    public var hba1c: Double?
    public var ogtt1h: Double?
    public var ogtt2h: Double?
    public var typicalSymptoms: Bool
    public var riskFactors: [String]
    public var hba1cInvalidatingConditions: [String]

    public init(fastingGlucose: Double? = nil, hba1c: Double? = nil, ogtt1h: Double? = nil, ogtt2h: Double? = nil, typicalSymptoms: Bool = false, riskFactors: [String] = [], hba1cInvalidatingConditions: [String] = []) {
        self.fastingGlucose = fastingGlucose
        self.hba1c = hba1c
        self.ogtt1h = ogtt1h
        self.ogtt2h = ogtt2h
        self.typicalSymptoms = typicalSymptoms
        self.riskFactors = riskFactors
        self.hba1cInvalidatingConditions = hba1cInvalidatingConditions
    }
}

public struct ClassificationInput: Codable, Equatable, Sendable {
    public var age: Int?
    public var bmi: Double?
    public var symptoms: Bool
    public var ketosisOrDKA: Bool
    public var evolutionWeeks: Int?
    public var needsInsulin: Bool
    public var familyHistory: Bool
    public var autoantibodiesPositive: Bool?
    public var cPeptideLow: Bool?
    public var pregnancy: Bool
    public var associatedMedications: [String]
    public var pancreatopathyOrEndocrinopathy: Bool

    public init(age: Int? = nil, bmi: Double? = nil, symptoms: Bool = false, ketosisOrDKA: Bool = false, evolutionWeeks: Int? = nil, needsInsulin: Bool = false, familyHistory: Bool = false, autoantibodiesPositive: Bool? = nil, cPeptideLow: Bool? = nil, pregnancy: Bool = false, associatedMedications: [String] = [], pancreatopathyOrEndocrinopathy: Bool = false) {
        self.age = age; self.bmi = bmi; self.symptoms = symptoms; self.ketosisOrDKA = ketosisOrDKA; self.evolutionWeeks = evolutionWeeks; self.needsInsulin = needsInsulin; self.familyHistory = familyHistory; self.autoantibodiesPositive = autoantibodiesPositive; self.cPeptideLow = cPeptideLow; self.pregnancy = pregnancy; self.associatedMedications = associatedMedications; self.pancreatopathyOrEndocrinopathy = pancreatopathyOrEndocrinopathy
    }
}

public struct TargetsInput: Codable, Equatable, Sendable {
    public var diabetesType: DiabetesType
    public var age: Int?
    public var frailty: Bool
    public var limitedLifeExpectancy: Bool
    public var severeOrFrequentHypoglycemia: Bool
    public var comorbidities: [String]
    public var ckd: Bool
    public var cardiovascularDisease: Bool
    public var usesInsulinOrSulfonylurea: Bool
    public var cgmAvailable: Bool
    public var pregnancy: Bool

    public init(diabetesType: DiabetesType = .unknown, age: Int? = nil, frailty: Bool = false, limitedLifeExpectancy: Bool = false, severeOrFrequentHypoglycemia: Bool = false, comorbidities: [String] = [], ckd: Bool = false, cardiovascularDisease: Bool = false, usesInsulinOrSulfonylurea: Bool = false, cgmAvailable: Bool = false, pregnancy: Bool = false) {
        self.diabetesType = diabetesType; self.age = age; self.frailty = frailty; self.limitedLifeExpectancy = limitedLifeExpectancy; self.severeOrFrequentHypoglycemia = severeOrFrequentHypoglycemia; self.comorbidities = comorbidities; self.ckd = ckd; self.cardiovascularDisease = cardiovascularDisease; self.usesInsulinOrSulfonylurea = usesInsulinOrSulfonylurea; self.cgmAvailable = cgmAvailable; self.pregnancy = pregnancy
    }
}

public struct DM2TreatmentInput: Codable, Equatable, Sendable {
    public var age: Int?
    public var sex: String
    public var hba1c: Double?
    public var hba1cTarget: Double?
    public var bmi: Double?
    public var overweightOrObesity: Bool
    public var eGFR: Double?
    public var albuminuria: Bool
    public var ascvd: Bool
    public var heartFailure: Bool
    public var ckd: Bool
    public var hypertension: Bool
    public var smoking: Bool
    public var ldl: Double?
    public var dm2DurationYears: Int?
    public var prematureCADFamilyHistory: Bool
    public var currentMedications: [String]
    public var contraindicationsOrIntolerances: [String]
    public var hypoglycemiaRisk: Bool
    public var accessPreference: String

    public init(age: Int? = nil, sex: String = "", hba1c: Double? = nil, hba1cTarget: Double? = nil, bmi: Double? = nil, overweightOrObesity: Bool = false, eGFR: Double? = nil, albuminuria: Bool = false, ascvd: Bool = false, heartFailure: Bool = false, ckd: Bool = false, hypertension: Bool = false, smoking: Bool = false, ldl: Double? = nil, dm2DurationYears: Int? = nil, prematureCADFamilyHistory: Bool = false, currentMedications: [String] = [], contraindicationsOrIntolerances: [String] = [], hypoglycemiaRisk: Bool = false, accessPreference: String = "Individualizar") {
        self.age = age; self.sex = sex; self.hba1c = hba1c; self.hba1cTarget = hba1cTarget; self.bmi = bmi; self.overweightOrObesity = overweightOrObesity; self.eGFR = eGFR; self.albuminuria = albuminuria; self.ascvd = ascvd; self.heartFailure = heartFailure; self.ckd = ckd; self.hypertension = hypertension; self.smoking = smoking; self.ldl = ldl; self.dm2DurationYears = dm2DurationYears; self.prematureCADFamilyHistory = prematureCADFamilyHistory; self.currentMedications = currentMedications; self.contraindicationsOrIntolerances = contraindicationsOrIntolerances; self.hypoglycemiaRisk = hypoglycemiaRisk; self.accessPreference = accessPreference
    }
}

public struct DM1InsulinInput: Codable, Equatable, Sendable {
    public var weightKg: Double?
    public var age: Int?
    public var pubertalPhase: Bool
    public var pregnancy: Bool
    public var acuteIllness: Bool
    public var currentGlucose: Double?
    public var glucoseTarget: Double?
    public var mealCarbohydrates: Double?
    public var currentTotalDailyDose: Double?
    public var basalInsulinType: String
    public var prandialInsulinType: String

    public init(weightKg: Double? = nil, age: Int? = nil, pubertalPhase: Bool = false, pregnancy: Bool = false, acuteIllness: Bool = false, currentGlucose: Double? = nil, glucoseTarget: Double? = nil, mealCarbohydrates: Double? = nil, currentTotalDailyDose: Double? = nil, basalInsulinType: String = "", prandialInsulinType: String = "") {
        self.weightKg = weightKg; self.age = age; self.pubertalPhase = pubertalPhase; self.pregnancy = pregnancy; self.acuteIllness = acuteIllness; self.currentGlucose = currentGlucose; self.glucoseTarget = glucoseTarget; self.mealCarbohydrates = mealCarbohydrates; self.currentTotalDailyDose = currentTotalDailyDose; self.basalInsulinType = basalInsulinType; self.prandialInsulinType = prandialInsulinType
    }
}

public struct SickDayInput: Codable, Equatable, Sendable {
    public var fever: Bool
    public var vomitingHours: Double
    public var diarrhea: Bool
    public var oralIntakePossible: Bool
    public var glucose: Double?
    public var ketonemia: Double?
    public var highKetonuria: Bool
    public var abdominalPain: Bool
    public var drowsinessOrConfusion: Bool
    public var kussmaulBreathing: Bool
    public var dehydration: Bool
    public var ageUnder5: Bool
    public var familyCanManageHomeCare: Bool

    public init(fever: Bool = false, vomitingHours: Double = 0, diarrhea: Bool = false, oralIntakePossible: Bool = true, glucose: Double? = nil, ketonemia: Double? = nil, highKetonuria: Bool = false, abdominalPain: Bool = false, drowsinessOrConfusion: Bool = false, kussmaulBreathing: Bool = false, dehydration: Bool = false, ageUnder5: Bool = false, familyCanManageHomeCare: Bool = true) {
        self.fever = fever; self.vomitingHours = vomitingHours; self.diarrhea = diarrhea; self.oralIntakePossible = oralIntakePossible; self.glucose = glucose; self.ketonemia = ketonemia; self.highKetonuria = highKetonuria; self.abdominalPain = abdominalPain; self.drowsinessOrConfusion = drowsinessOrConfusion; self.kussmaulBreathing = kussmaulBreathing; self.dehydration = dehydration; self.ageUnder5 = ageUnder5; self.familyCanManageHomeCare = familyCanManageHomeCare
    }
}

public struct ElderlyInput: Codable, Equatable, Sendable {
    public var age: Int?
    public var functionalDependence: Bool
    public var cognitiveImpairment: Bool
    public var frailty: Bool
    public var multimorbidity: Bool
    public var polypharmacy: Bool
    public var hypoglycemia: Bool
    public var limitedLifeExpectancy: Bool
    public var usesInsulinOrSulfonylurea: Bool

    public init(age: Int? = nil, functionalDependence: Bool = false, cognitiveImpairment: Bool = false, frailty: Bool = false, multimorbidity: Bool = false, polypharmacy: Bool = false, hypoglycemia: Bool = false, limitedLifeExpectancy: Bool = false, usesInsulinOrSulfonylurea: Bool = false) {
        self.age = age; self.functionalDependence = functionalDependence; self.cognitiveImpairment = cognitiveImpairment; self.frailty = frailty; self.multimorbidity = multimorbidity; self.polypharmacy = polypharmacy; self.hypoglycemia = hypoglycemia; self.limitedLifeExpectancy = limitedLifeExpectancy; self.usesInsulinOrSulfonylurea = usesInsulinOrSulfonylurea
    }
}

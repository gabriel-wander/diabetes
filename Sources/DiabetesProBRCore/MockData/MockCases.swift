import Foundation

public enum MockCases {
    public static let diagnosisConfirmed = DiagnosisInput(fastingGlucose: 132, hba1c: 6.7, typicalSymptoms: false, riskFactors: ["IMC elevado"])
    public static let diagnosisPrediabetesWithInvalidHbA1c = DiagnosisInput(fastingGlucose: 108, hba1c: 6.0, riskFactors: ["História familiar"], hba1cInvalidatingConditions: ["anemia", "DRC"])
    public static let classificationType1 = ClassificationInput(age: 18, bmi: 21, symptoms: true, ketosisOrDKA: true, needsInsulin: true, autoantibodiesPositive: true, cPeptideLow: true)
    public static let targetsAdultDM1CGM = TargetsInput(diabetesType: .type1, age: 32, cgmAvailable: true)
    public static let dm2Cardiorenal = DM2TreatmentInput(age: 66, sex: "F", hba1c: 7.2, hba1cTarget: 7.0, bmi: 31, overweightOrObesity: true, eGFR: 48, albuminuria: true, ckd: true, hypertension: true, accessPreference: "SUS/particular")
    public static let dm1InsulinAdult = DM1InsulinInput(weightKg: 70, age: 28, mealCarbohydrates: 60, basalInsulinType: "análoga basal", prandialInsulinType: "análoga rápida")
    public static let sickDayEmergency = SickDayInput(vomitingHours: 3, oralIntakePossible: false, glucose: 260, ketonemia: 2.1, abdominalPain: true)
    public static let elderlyComplex = ElderlyInput(age: 82, functionalDependence: true, cognitiveImpairment: true, frailty: true, multimorbidity: true, polypharmacy: true, hypoglycemia: true, usesInsulinOrSulfonylurea: true)
}

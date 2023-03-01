import 'package:ease/src/util/function.dart';

const heightMin = 10;
const heightMax = 350;
const weightMin = 0;
const weightMax = 350;

dynamic getQuestions([keys]) {
  var health1 = """
<table><colgroup><col width="5%" /><col width="95%" /></colgroup>
<tr><td>1.</td><td>${getLocale("Have you ever, for any illness (other than common cold), injury, growth, cyst, lump, disease, disorder, physical disability or impairment (including hereditary, congenital, genetic, mental/psychiatic conditions)")},</td></tr>
<tr><td></td><td><p>
<table><colgroup><col width="3%" /><col width="97%" /></colgroup>
<tr><td>•</td><td>${getLocale("Been investigated or diagnosed and/or received any treatment or medication; or")}</td></tr>
<tr><td>•</td><td>${getLocale("Been advised to undergo follow-up, periodic monitoring or observation; or")}</td></tr>
<tr><td>•</td><td>${getLocale("Consulted any medical practitioner or any alternative health practitioner?")}</td></tr>
</table></p></td></tr>
</table>
""";

  var health2 = """
<table><colgroup><col width="5%" /><col width="95%" /></colgroup>
<tr><td>2.</td><td>${getLocale("Have you ever been hospitalized, or undergone any medical procedure (including surgeries and endoscopes) on a day-care or outpatient basis?")}</td></tr>
</table><br>
""";

  var health3 = """
<table><colgroup><col width="5%" /><col width="95%" /></colgroup>
<tr><td>3.</td><td>${getLocale("Have you ever had, or been advised to perform any medical test?")}</td></tr>
<tr><td></td><td><p><b>${getLocale("Example")}</b>
<table><colgroup><col width="3%" /><col width="97%" /></colgroup>
<tr><td>•</td><td>${getLocale("Blood/urine/stool test")}</td></tr>
<tr><td>•</td><td>${getLocale("HIV Screening")}</td></tr>
<tr><td>•</td><td>${getLocale("X-Ray,Ultrasound, CT/MRI/PET Scan")}</td></tr>
<tr><td>•</td><td>${getLocale("Mammogram, Pap Smear")}</td></tr>
<tr><td>•</td><td>${getLocale("Electrocardiogram (ECG), Treadmill ECG, Angiogram, Echocardiogram (ECHO)")}</td></tr>
<tr><td>•</td><td>${getLocale("Biopsy, Fine-needle aspiration")}</td></tr>
<tr><td>•</td><td>${getLocale("Endoscopy, Laparoscopy")}</td></tr>
</table></p></td></tr>
</table>
""";

  var health4 = """
<table><colgroup><col width="5%" /><col width="95%" /></colgroup>
<tr><td>4.</td><td>${getLocale("Have you ever had, or been advised to perform any medical test?")}</td></tr>
<tr><td></td><td><p>
<table><colgroup><col width="3%" /><col width="97%" /></colgroup>
<tr><td>•</td><td>${getLocale("Vomiting blood, prolonged cough, persistent nose bleed, blood in urine/stool/phlegm")}</td></tr>
<tr><td>•</td><td>${getLocale("Fainting spells, recurrent severe headache, blurring of vision, fits")}</td></tr>
<tr><td>•</td><td>${getLocale("Persistent fever, persistent and unexplained fatigue, weight loss")}</td></tr>
<tr><td>•</td><td>${getLocale("Irregular heartbeat, chest pain, numbness")}</td></tr>
<tr><td>•</td><td>${getLocale("Lump/growth/cyst/swelling of any part of the body, ascites, unusual skin lesions")}</td></tr>
<tr><td>•</td><td>${getLocale("Abnormal vaginal discharge, abnormal uterine bleeding")}</td></tr>
<tr><td>•</td><td>${getLocale("Persistent diarrhea or abdominal pain, enlarged lymph nodes or spleen")}</td></tr>
<tr><td>•</td><td>${getLocale("Join pain, meniscus or ligament injury/tear")}</td></tr>
</table></p></td></tr>
</table>
""";

  var life1 = """
<table><colgroup><col width="5%" /><col width="95%" /></colgroup>
<tr><td>1.</td><td>${getLocale("Do you smoke or use, or have you smoked or used, any form of tobacco or nicotine based products in the past 24 months")}</td></tr>
<tr><td></td><td><p>(${getLocale("such as cigarettes, vape, cigars, e-cigarettes, pipe, water pipe, shisha, nicotine patches, nicotine gum")})</p></td></tr>
</table><br>
""";
// <tr><td></td><td><p><b>Such as</b>
// <table><colgroup><col width="50%" /><col width="50%" /></colgroup>
// <tr><td>- cigarettes</td><td>- vape</td></tr>
// <tr><td>- cigars</td><td>- e-cigarettes</td></tr>
// <tr><td>- pipe</td><td>- water pipe</td></tr>
// <tr><td>- shisha</td><td>- nicotine patches</td></tr>
// <tr><td>- nicotine gum</td><td></td></tr>
// </table></p></td></tr>

  var life2 = """
<table><colgroup><col width="5%" /><col width="95%" /></colgroup>
<tr><td>2.</td><td>${getLocale("Do you consume beer, wine, spirits or any other type of alcohol or have you ever been treated for alcohol addiction")}?</td></tr>
</table><br>
""";

  var life3 = """
<table><colgroup><col width="5%" /><col width="95%" /></colgroup>
<tr><td>3.</td><td>${getLocale("Have you ever used non-prescribed drugs")}?</td></tr>
<tr><td></td><td><p>(${getLocale("non-prescribed drugs include but are not limited to illegal drugs, recreational drugs, or narcotics")})</p></td></tr>
</table><br>
""";

  var life4 = """
<table><colgroup><col width="5%" /><col width="95%" /></colgroup>
<tr><td>4.</td><td>${getLocale("Are you currently participating, or do you intend to participate, in a hazardous occupation, sport or pastime")}?</td></tr>
<tr><td></td><td><p>(${getLocale("including but not limited to activities, hobbies and sport such as private aviation, caving, rock climbing, diving, horse riding, motorsports, mountaineering, boxing or yachting")})</p></td></tr>
</table><br>
""";

  var coverage1 = """
<table><colgroup><col width="5%" /><col width="95%" /></colgroup>
<tr><td>1.</td><td>${getLocale("Have you ever had an application, renewal or reinstatement of a life policy or family takaful certificates, declined, postponed, rated or subject to special terms, please provide details. Policy or contract includes life, Family Takaful, accident, medical, disability, critical illness or health insurance")}.</td></tr>
</table><br>
""";

  var coverage2 = """
<table><colgroup><col width="5%" /><col width="95%" /></colgroup>
<tr><td>2.</td><td>${getLocale("If you have medical, health, life policy or family takaful certificates with us, or any other insurance company/takaful operator, please provide details of all in force policies/certificates and pending applications. If sufficient space, please add an attachments with details for all")}.</td></tr>
</table><br>
""";

  var replace1 = """
<table><colgroup><col width="5%" /><col width="95%" /></colgroup>
<tr><td>1.</td><td>${getLocale("Do you intend to surrender or terminate any of your existing life insurance policies or family takaful certificates with this new application, even you may not receive any returns under these policies or contracts, and the returns may be lesser than the premiums or contributions paid")}?</td></tr>
</table><br>
""";

  var replace2 = """
<table><colgroup><col width="5%" /><col width="95%" /></colgroup>
<tr><td>2.</td><td>${getLocale("Has the intermediary or any party in any way influenced you to surrender or terminate any of your existing policies or contracts")}?</td></tr>
</table><br>
""";

  var questionTable =
      """<table><colgroup><col width="5%" /><col width="95%" /></colgroup><tr><td>{{number}}</td><td>{{question}}</td></tr></table><br>""";

  dynamic questionList = {
    "1030": getLocale(
        "Have you ever had or been told to have or been treated for cancer, tumor, cysts, abnormal lump /growth/ swelling, leukemia, melanoma or lymphoma?"),
    "1044": getLocale(
        "Have you ever had or been told to have or been treated for any condition, illness, disease, or disorder, whether medically diagnosed or not, affecting your cardiovascular system, including the heart, blood, blood vessels, lymph or lymph glands, (such as chest pain or breathlessness, palpitations, coronary artery disease, heart attack, heart murmur, hypertension, high cholesterol, anemia, stroke, Transient Ischaemic Attack (TIA)?"),
    "1046": getLocale(
        "Have you ever had or been told to have or been treated for any condition, illness, disease, or disorder, whether medically diagnosed or not, affecting your respiratory system, including lungs, throat and sinuses (such as asthma, bronchitis, pneumonia, tuberculosis)?"),
    "1048": getLocale(
        "Have you ever had or been told to have or been treated for any condition, illness, disease, or disorder, whether medically diagnosed or not, affecting your digestive system, including the gall bladder, liver, stomach, esophagus and bowel (such as ulcers, hepatitis B or C, gastritis or diarrhea lasting for more than a week, jaundice, blood in the stools, colitis, Crohn's disease)?"),
    "1050": getLocale(
        "Have you ever had or been told to have or been treated for any condition, illness, disease, or disorder, whether medically diagnosed or not, affecting your mental health or central nervous system, including the brain and nerves, (such as epilepsy, convulsions, seizures, fits, blackouts, migraines, severe headaches lasting for more than 12 hours, Parkinson's disease, multiple sclerosis, Alzheimer's disease, paralysis, numbness for a period exceeding a day, involuntary tremors, psychiatric illnesses, dementia, schizophrenia, suicide attempts, nervous breakdown, medically diagnosed depression/anxiety)?"),
    "1052": getLocale(
        "Have you ever had or been told to have or been treated for any condition, illness, disease, or disorder, whether medically diagnosed or not, affecting your eyes (excluding refractive eyesight problems corrected by an optometrist), ears, nose and speech (such as double vision or nose bleeds which recur at least weekly)?"),
    "1054": getLocale(
        "Have you ever had or been told to have or been treated for any condition, illness, disease, or disorder, whether medically diagnosed or not, affecting your endocrine system, including the thyroid, pancreas and other endocrine glands (such as diabetes, goiter, pancreatitis, hormone disorders)?"),
    "1056": getLocale(
        "Have you ever had or been told to have or been treated for any condition, illness, disease, or disorder, whether medically diagnosed or not, affecting your muscles and bones, including joints (such as gout, arthritis, rheumatism, prolapsed intervertebral disc, physical abnormality, physical dismemberment or disability)?"),
    "1072": getLocale(
        "Have you ever had or been told to have or been treated for any condition, illness, disease, or disorder, whether medically diagnosed or not, affecting your urinary or reproductive system, including kidneys, bladder and urinary tract,(such as blood in the urine, abnormal levels of sugar or protein in the urine, kidney stones and for males, the prostate)?"),
    "1058": getLocale(
        "Have you ever had or been told to have or been treated for any condition, illness, disease, or disorder, whether medically diagnosed or not, affecting your skin or immune system (such as eczema, psoriasis, scleroderma, systemic lupus erythematosus (SLE), skin rashes or infections of at least one month,unusual skin lesions)?"),
    "1060": getLocale(
        "Have you, your spouse or partner, ever been told to be tested, diagnosed with or treated for AIDS, HIV or a Sexually Transmitted Disease (such as herpes, Human Papilloma Virus (HPV), syphilis or gonorrhea)?"),
    "1062": getLocale("Are you now pregnant?"),
    "1074": getLocale(
        "Have you ever had during your previous pregnancy/childbirth or do you currently have any pregnancy related complications (e.g. pre-eclampsia/eclampsia, ectopic pregnancy, stillbirth, miscarriage, disseminated intravascular coagulation, hydatidiform mole, or postpartum haemorrhage requiring hysterectomy)?"),
    "1064": getLocale(
        "Have you ever had any disease or disorder of the breast, cervix uteri, uterus or ovaries including breast lump, breast or ovarian cyst, carcinoma in situ, fibroid, polyp, abnormal menstrual bleeding?"),
    "1266": getLocale(
        "Have your children ever suffered from Spina bifida, Down's syndrome, Tetralogy of Fallot, cleft lip and/or palate, ventricular septal defect, atrial septal defect, patent ductus arteriosus or truncus arteriosus?"),
    "1066": getLocale(
        "In the past 5 years have you ever had or been advised to have or do you intend to undergo any investigations / screening test including blood / urine test (this include routine blood screening test done at laboratories / GP clinics), x-ray, ultrasound, CT / MRI scan, calcium score / heart scan, angiogram, echocardiogram, electrocardiogram (resting / stress ECG), pap smear, mammogram, scope, biopsy or predictive genetic test?"),
    "1076": getLocale(
        "Are you currently receiving / considering to seek any medical treatment / advice or in the past 5 years have you ever been referred to or admitted to a hospital or medical facility or ever undergone / been advised to undergo a surgery?"),
    "1068": getLocale(
        "Do you have any Regular / Personal Doctor? If yes, please provide details."),
    "1070": getLocale(
        "Have any of your natural parents and/or siblings, ever suffered from or died as a result of diabetes, cancer, kidney disease, stroke or any other hereditary disease before the age of sixty (60) years? If yes, please provide details of diagnosis, age of onset, current age if living or age deceased."),
    "1260": getLocale(
        "Was the child born earlier than 36 weeks of gestation or after 40 weeks of gestation?"),
    "1262": getLocale("Was there any complication following birth?"),
    "1264":
        "${getLocale("Does the")} ${getLocale("Life Insured", entity: true)} ${getLocale("has any physical defects, any sign of slow physical or mental development, or any other behavioral or developmental disorder")}?",
    "1288": getLocale(
        "Do you smoke or use, or have you smoked or used, any form of tobacco or nicotine based products in the past 24 months"),
    "s1288": getLocale(
        "such as cigarettes, vape, cigars, e-cigarettes, pipe, water pipe, shisha, nicotine patches, nicotine gum"),
    "1034": getLocale(
        "Do you consume beer, wine, spirits or any other type of alcohol or have you ever been treated for alcohol addiction? If yes, please provide details including types of alcohol and average quantity consumed per week (in ml)."),
    "1036": getLocale(
        "Have you ever used non-prescribed drugs? (non-prescribed drugs include but are not limited to illegal drugs, recreational drugs, or narcotics)? If yes, please provide details."),
    // "s1036": getLocale(
    //     "non-prescribed drugs include but are not limited to illegal drugs, recreational drugs, or narcotics"),
    "1038": getLocale(
        "Are you currently participating, or do you intend to participate, in a hazardous occupation, sport or pastime? (including but not limited to activities, hobbies and sport such as private aviation, caving, rock climbing, diving, horse riding, motorsports, mountaineering, boxing or yachting)? If yes, please provide details (including the type of sport, frequency of participation, locations, level of expertise and any prior accidents or injuries)"),
    // "s1038": getLocale(
    //     "including but not limited to activities, hobbies and sport such as private aviation, caving, rock climbing, diving, horse riding, motorsports, mountaineering, boxing or yachting"),
    "1040": getLocale(
        "Have you ever had an application, renewal or reinstatement of a life policy or Family Takaful contract, declined, postponed, rated or subject to special terms, please provide details. Policy or contract includes life, Family Takaful, accident, medical, disability, critical illness or health insurance."),
    "1042": getLocale(
        "If you have any medical, health or life policy or Family Takaful contracts, with us or any other insurance / Takaful company, please provide details of all inforce policies /contracts and pending applications."),
    "1333": getLocale(
        "Do you intend to surrender or terminate any of your existing life insurance policies or Family Takaful contracts with this new application, even you may not receive any returns under these policies or contracts, and the returns may be lesser than the premiums or contributions paid?"),
    "1334": getLocale(
        "Has the agent or any party in any way influenced you to surrender or terminate any of your existing policies or contracts?"),
    "1335": getLocale(
        "If yes, are you fully satisfied with the explanation given to you?"),
    "none": {}
  };

  dynamic subQList = {
    "AmountOfWeight":
        getLocale("Amount of weight loss/gain, and reason for weight change."),
    "Symptoms":
        getLocale("Symptoms (description and dates symptoms presented)"),
    "CurrCondition": getLocale("Current condition"),
    "Diagnosis": getLocale("Diagnosis if any"),
    "MedInvestigation": getLocale(
        "Medical investigations if any (investigation dates and results)"),
    "MedDetails":
        getLocale("Medication details if any (name, dosage and date received)"),
    "TreatmentDetails": getLocale(
        "Treatment details if any (description, and  dates received)"),
    "AttendingDoctor": getLocale(
        "Attending doctor details if any (name, specialty, address, and dates consulted)"),
    "DoctorFrequent": getLocale(
        "Name, specialty and address of your personal/usual doctor that you frequent most."),
    "DateLastConsult": getLocale(
        "Date last consulted any doctor and reason. If doctor consulted was not the above named doctor, please also give details of this doctor (name, specialty, address)."),
    "SpecialistLastFiveYear": getLocale(
        "Have you consulted a specialist in the last 5 years? If yes, please give specialist name, specialty, reason for consultation, outcome of visit."),
// "FamilyMember":"Family Member",
    "DiagnosisF": getLocale("Diagnosis"),
    "AgeOnset": getLocale("Age of onset"),
    "CurrAge": getLocale("Current age of living, or age deceased"),
    "Sticks": getLocale(
        "If you smoke (or have smoked) cigarettes or cigars, number of sticks per day consumed, on average. (Sticks)"),
    "Years": getLocale(
        "Number of years smoking or using tobacco or nicotine based products"),
    "Hours": getLocale(
        "If you smoke (or have smoked) tabacco products other than cigarettes or cigars, number of hours per day smoking, on average. (Hours per day)"),
    "Type": getLocale("Type of alcohol"),
    "AverageQuantity": getLocale("Average quantity consumed per week (in ml)"),
    "Details": getLocale("Details"),
    "Company": getLocale("Company"),
    "IssueDate": getLocale("Issue Date"),
    "Plan": getLocale("Plan"),
    "Amount": getLocale("Amount of Insurance / Takaful Coverage"),
    "none": {}
  };

  var familyMember = {
    "type": "option1",
    "label": getLocale("Family Member"),
    "value": "",
    "options": [
      {"label": "Brother", "active": true, "value": "Brother"},
      {"label": "Father", "active": true, "value": "Father"},
      {"label": "Mother", "active": true, "value": "Mother"},
      {"label": "Sister", "active": true, "value": "Sister"}
    ],
    "required": true,
    "column": true
  };

  for (var key in subQList.keys) {
    var standardObj = {
      "type": "text",
      "label": "",
      "value": "",
      "regex": "^(?!.*?</).*",
      "required": true,
      "size": {},
      "column": true,
      "regexError": "Those character is not allow. </",
      "sentence": true
    };
    if (subQList[key] is! String) continue;
    if (key == "AgeOnset" ||
        key == "CurrAge" ||
        key == "Years" ||
        key == "Sticks" ||
        key == "Hours") {
      if (key == "Sticks" || key == "Hours") {
        standardObj["required"] = false;
      }
      standardObj["type"] = "number";
    } else if (key == "Amount") {
      standardObj["type"] = "currency";
    } else if (key == "IssueDate") {
      standardObj["type"] = "date";
    }

    standardObj["label"] = subQList[key];
    subQList[key] = standardObj;
  }

  var weigthChange = {
    "AmountOfWeight": subQList["AmountOfWeight"],
    "multiple": false
  };

  var condition = {
    "Symptoms": subQList["Symptoms"],
    "CurrCondition": subQList["CurrCondition"],
    "Diagnosis": subQList["Diagnosis"],
    "MedInvestigation": subQList["MedInvestigation"],
    "MedDetails": subQList["MedDetails"],
    "TreatmentDetails": subQList["TreatmentDetails"],
    "AttendingDoctor": subQList["AttendingDoctor"],
    "multiple": true
  };

  var doctor = {
    "DoctorFrequent": subQList["DoctorFrequent"],
    "DateLastConsult": subQList["DateLastConsult"],
    "SpecialistLastFiveYear": subQList["SpecialistLastFiveYear"],
    "multiple": true
  };

  var family = {
    "FamilyMember": familyMember,
    "Diagnosis": subQList["DiagnosisF"],
    "AgeOnset": subQList["AgeOnset"],
    "CurrAge": subQList["CurrAge"],
    "multiple": true
  };

  var smoke = {
    "Years": subQList["Years"],
    "Sticks": subQList["Sticks"],
    "Hours": subQList["Hours"],
    "multiple": false
  };

  var alcohol = {
    "Type": subQList["Type"],
    "AverageQuantity": subQList["AverageQuantity"],
    "multiple": true
  };
  var details = {"Details": subQList["Details"], "multiple": true};

  var company = {
    "Company": subQList["Company"],
    "IssueDate": subQList["IssueDate"],
    "Plan": subQList["Plan"],
    "Amount": subQList["Amount"],
    "multiple": true
  };

  var q1078h = {
    "type": "question",
    "vtype": "int",
    "label": getLocale("Height"),
    "value": 0,
    "suffix": "cm",
    "min": heightMin,
    "max": heightMax,
    "required": true,
    "questionCode": "1078h",
    "plaintext": getLocale("Height")
  };
  var q1078w = {
    "type": "question",
    "vtype": "int",
    "label": getLocale("Weight"),
    "value": 0,
    "suffix": "kg",
    "min": weightMin,
    "max": weightMax,
    "required": true,
    "questionCode": "1078w",
    "plaintext": getLocale("Weight")
  };
  var q1032 = {
    "type": "question",
    "label":
        "<h5>${getLocale("Has your weight changed by more than 5kg in the past six months")}?</h5>",
    "value": "",
    "options": [
      {
        "label": getLocale("YES"),
        "active": true,
        "value": true,
        "option_fields": weigthChange
      },
      {"label": getLocale("NO"), "active": true, "value": false}
    ],
    "paddingLeft": 0,
    "checkBack": true,
    "required": true,
    "questionCode": "1032",
    "plaintext":
        "${getLocale("Has your weight changed by more than 5kg in the past six months")}?"
  };

  for (var key in questionList.keys) {
    String? qno;
    if (questionList[key] is! String) continue;
    var label = questionList[key].indexOf("<table>") > -1
        ? questionList[key]
        : questionTable.replaceAll("{{question}}", questionList[key]);

    if (key == "1288") label = life1;
    if (key == "1034") {
      label = questionTable
          .replaceAll("{{number}}", "2.")
          .replaceAll("{{question}}", questionList[key]);
    }
    if (key == "1036") label = life3;
    if (key == "1038") label = life4;
    if (key == "1040") {
      label = questionTable
          .replaceAll("{{number}}", "1.")
          .replaceAll("{{question}}", questionList[key]);
    }
    if (key == "1042") {
      label = questionTable
          .replaceAll("{{number}}", "2.")
          .replaceAll("{{question}}", questionList[key]);
    }
    if (key == "1333") {
      label = questionTable
          .replaceAll("{{number}}", "1.")
          .replaceAll("{{question}}", questionList[key]);
    }
    if (key == "1334") {
      label = questionTable
          .replaceAll("{{number}}", "2.")
          .replaceAll("{{question}}", questionList[key]);
    }
    if (key == "1335") {
      label = questionTable
          .replaceAll("{{number}}", "3.")
          .replaceAll("{{question}}", questionList[key]);
    }
    if (key == "1040" || key == "1288" || key == "1333") {
      qno = "1";
    }
    if (key == "1034" || key == "1042" || key == "1334") {
      qno = "2";
    }
    if (key == "1036" || key == "1335") {
      qno = "3";
    }
    if (key == "1038") {
      qno = "4";
    }
    dynamic optionFields;
    if (key == "1068") {
      optionFields = doctor;
    } else if (key == "1070") {
      optionFields = family;
    } else if (key == "1288") {
      optionFields = smoke;
    } else if (key == "1333" || key == "1334" || key == "1335") {
    } else if (key == "1042") {
      optionFields = company;
    } else if (key == "1036" || key == "1038" || key == "1040") {
      optionFields = details;
    } else if (key == "1034") {
      optionFields = alcohol;
    } else {
      optionFields = condition;
    }

    if (optionFields != null) {
      optionFields["title"] = label;
    }
    questionList[key] = {
      "type": "question",
      "label": label,
      "value": "",
      "options": [
        {
          "label": getLocale("YES"),
          "active": true,
          "value": true,
          "option_fields": optionFields
        },
        {"label": getLocale("NO"), "active": true, "value": false}
      ],
      "paddingLeft": 0,
      "checkBack": true,
      "required": true,
      "questionCode": key,
      "qno": qno,
      "plaintext": questionList[key],
      "subtext": questionList["s$key"],
    };
  }

  var questions = {
    "health1": health1,
    "health2": health2,
    "health3": health3,
    "health4": health4,
    "life1": life1,
    "life2": life2,
    "life3": life3,
    "life4": life4,
    "coverage1": coverage1,
    "coverage2": coverage2,
    "replace1": replace1,
    "replace2": replace2,
    "1078h": q1078h,
    "1078w": q1078w,
    "1032": q1032,
    ...questionList
  };

  if (keys != null) {
    if (keys is String) {
      return questions[keys];
    } else if (keys is List) {
      var map = {};
      for (var i = 0; i < keys.length; i++) {
        map[keys[i]] = questions[keys[i]];
        // array.add(questions[keys[i]]);
      }
      return map;
    }
  }

  return questions;
}

var questionSetup = [
  {
    "ProdCode": "PCWI01",
    "Type": [
      {
        "gpQuest": "4",
        "riderQuest": "4",
        "isROP": false,
      }
    ],
    "validateRules": "1334*1335"
  },
  {
    "ProdCode": "PTWI01",
    "Type": [
      {
        "gpQuest": "4",
        "riderQuest": "4",
        "isROP": false,
      }
    ],
    "validateRules": "1334*1335"
  },
  {
    "ProdCode": "PTWI03",
    "Type": [
      {
        "gpQuest": "4",
        "riderQuest": "4",
        "isROP": false,
      }
    ],
    "validateRules": "1334*1335"
  },
  {
    "ProdCode": "WANA",
    "Type": [
      {
        "gpQuest": "4",
        "riderQuest": "4",
        "isROP": false,
      }
    ],
    "validateRules": "1334*1335"
  },
  {
    "ProdCode": "WANB",
    "Type": [
      {
        "gpQuest": "4",
        "riderQuest": "4",
        "isROP": false,
      }
    ],
    "validateRules": "1334*1335"
  },
  {
    "ProdCode": "PTWE03",
    "Type": [
      {
        "gpQuest": "4",
        "riderQuest": "4",
        "isROP": false,
      }
    ],
    "validateRules": "1334*1335"
  },
  {
    "ProdCode": "PTWE02",
    "Type": [
      {
        "gpQuest": "4",
        "riderQuest": "4",
        "isROP": false,
      }
    ],
    "validateRules": "1334*1335"
  },
  {
    "ProdCode": "PTWA01",
    "Type": [
      {
        "gpQuest": "4",
        "riderQuest": "4",
        "isROP": false,
      }
    ],
    "validateRules": "1334*1335"
  },
  {
    "ProdCode": "PTWA02",
    "Type": [
      {
        "gpQuest": "4",
        "riderQuest": "4",
        "isROP": false,
      }
    ],
    "validateRules": "1334*1335"
  },
  {
    "ProdCode": "PTWA03",
    "Type": [
      {
        "gpQuest": "4", //harmoni
        "riderQuest": "4",
        "isROP": false,
      }
    ],
    "validateRules": "1334*1335"
  },
  {
    "ProdCode": "PTWA04",
    "Type": [
      {
        "gpQuest": "4",
        "riderQuest": "4",
        "isROP": true,
      }
    ],
    "validateRules": "1334*1335"
  },
  {
    "ProdCode": "PCWA01", //Enrich Life Plan
    "Type": [
      {
        "gpQuest": "4",
        "riderQuest": "4",
        "isROP": false,
      }
    ],
    "validateRules": "1334*1335"
  },
  {
    "ProdCode": "PCEE01",
    "Type": [
      {
        "gpQuest": "4",
        "riderQuest": "4",
        "isROP": false,
      }
    ],
    "validateRules": "1334*1335"
  },
  {
    "ProdCode": "PCEL01",
    "Type": [
      {
        "gpQuest": "4",
        "riderQuest": "4",
        "isROP": false,
      }
    ],
    "validateRules": "1334*1335"
  },
  {
    "ProdCode": "PCTA01", //Etiqa Life Secure
    "Type": [
      {
        "gpQuest": "4",
        "riderQuest": "4",
        "isROP": false,
      }
    ],
    "validateRules": "1334*1335"
  },
  {
    "ProdCode": "PCHI01",
    "Type": [
      {
        "gpQuest": "3",
        "riderQuest": "3",
        "isROP": true,
      }
    ],
    "validateRules": "1334*1335"
  },
  {
    "ProdCode": "PCHI03",
    "Type": [
      {
        "gpQuest": "3",
        "riderQuest": "3",
        "isROP": true,
      }
    ],
    "validateRules": "1334*1335"
  },
  {
    "ProdCode": "PTHI01",
    "Type": [
      {
        "gpQuest": "3",
        "riderQuest": "3",
        "isROP": true,
      }
    ],
    "validateRules": "1334*1335"
  },
  {
    "ProdCode": "PCHI02",
    "Type": [
      {
        "gpQuest": "4",
        "riderQuest": "4",
        "isROP": true,
      }
    ],
    "validateRules": "1334*1335"
  },
  {
    "ProdCode": "PCHI04",
    "Type": [
      {
        "gpQuest": "4",
        "riderQuest": "4",
        "isROP": false,
      }
    ],
    "validateRules": "1334*1335"
  },
  {
    "ProdCode": "PTHI02", //Hadiyyah Takafulink
    "Type": [
      {
        "gpQuest": "4",
        "riderQuest": "4",
        "isROP": true,
      }
    ],
    "validateRules": "1334*1335"
  },
  {
    "ProdCode": "PCJI01", //megalink
    "Type": [
      {
        "gpQuest": "4",
        "riderQuest": "4",
        "isROP": false,
      }
    ],
    "validateRules": "1334*1335"
  },
  {
    "ProdCode": "PCJI02", //megaplus
    "Type": [
      {
        "gpQuest": "4",
        "riderQuest": "4",
        "isROP": false,
      }
    ],
    "validateRules": "1334*1335"
  },
  {
    "ProdCode": "PTJI01", //Mahabbah
    "Type": [
      {
        "gpQuest": "4",
        "riderQuest": "4",
        "isROP": false,
      }
    ],
    "validateRules": "1334*1335"
  },
  {
    "ProdCode": "PCWI03", //securelink
    "Type": [
      {
        "gpQuest": "4",
        "riderQuest": "4",
        "isROP": false,
      }
    ],
    "validateRules": "1334*1335"
  },
  {
    "ProdCode": "PTWE04", //mawaddah
    "Type": [
      {
        "gpQuest": "3",
        "riderQuest": "3",
        "isROP": true,
      }
    ],
    "validateRules": "1334*1335"
  },
  {
    "ProdCode": "PTWE05", //mawaddah II
    "Type": [
      {
        "gpQuest": "7",
        "riderQuest": "7",
        "isROP": true,
      }
    ],
    "validateRules": ""
  },
  {
    "ProdCode": "PTCA02", //aafiahcare
    "Type": [
      {
        "gpQuest": "4",
        "riderQuest": "4",
        "isROP": true,
      }
    ],
    "validateRules": "1334*1335"
  },
  {
    "ProdCode": "PCWA02", //protect88
    "Type": [
      {
        "gpQuest": "5",
        "riderQuest": "6",
        "isROP": false,
      }
    ],
    "validateRules": ""
  },
];

var questionType = {
  "IsGuaranteedAcceptance": 1,
  "IsSimplified": 2,
  "IsROPSimplified": 3,
  "IsFullQuest": 4,
  "IsPro88": 5,
  "IsPro88WithRider": 6,
  "IsROC": 7,
  "None": 99
};

dynamic getQuestionIndex() {
  return {
    "IsGuaranteedAcceptance": ["1273"],
    "IsSimplified": [
      "1078h",
      "1078w",
      "1122",
      "1171",
      "1042",
      "1333",
      "1334",
      "1335"
    ],
    "IsROPSimplified": ["1333", "1334", "1335"],
    "IsFullQuest": [
      "1078h",
      "1078w",
      "1032",
      "1030",
      "1044",
      "1046",
      "1048",
      "1050",
      "1052",
      "1054",
      "1056",
      "1072",
      "1058",
      "1060",
      "1062",
      "1074",
      "1064",
      "1066",
      "1266",
      "1262",
      "1260",
      "1264",
      "1076",
      "1068",
      "1070",
      "1288",
      "1034",
      "1036",
      "1038",
      "1040",
      "1042",
      "1333",
      "1334",
      "1335"
    ],
    "IsPro88": ["2977", "1333", "1334", "1335"],
    "IsPro88WithRider": [
      "2977",
      "1078h",
      "1078w",
      "2997",
      "2998",
      "2999",
      "1333",
      "1334",
      "1335"
    ],
    "IsROC": ["3037", "3038", "3040", "3040a"],
    "None": []
  };
}

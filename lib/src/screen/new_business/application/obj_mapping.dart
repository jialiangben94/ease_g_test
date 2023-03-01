import 'package:ease/src/util/function.dart';

var objMapping = {
  //salutation
  "mr": getLocale("Mr"),
  "ms": getLocale("Ms"),

  //identity
  "nric": getLocale("New IC (myKad / myKid)"),
  "guardiannric": getLocale("New IC (myKad / myKid)"),
  "passport": getLocale("Passport"),
  "oldic": getLocale("Old IC"),
  "birthcert": getLocale("Birth Certificate"),
  "mypr": "MyPR",
  "policeic": getLocale("Police IC"),
  "armyic": getLocale("Army IC"),
  "othersid": getLocale("Others"),

  //gender
  "male": getLocale("Male"),
  "female": getLocale("Female"),

  //races
  "malay": getLocale("Malay"),
  "chinese": getLocale("Chinese"),
  "indian": getLocale("Indian"),
  "othersrace": getLocale("Others"),

  //true/false
  "yes": getLocale("Yes"),
  "no": getLocale("No"),
  "yesU": getLocale("YES"),
  "noU": getLocale("NO"),

  //marital
  "married": getLocale("Married"),
  "single": getLocale("Single"),
  "divorced": getLocale("Divorced"),
  "widowed": getLocale("Widowed"),

  //Job status
  "selfemployed": getLocale("Self Employed"),
  "employed": getLocale("Employed"),
  "busniessowner": getLocale("A Business Owner"),
  "notworking": getLocale("Not Working"),

  //Bank account type
  "savingaccount": getLocale("Saving Account"),
  "currentaccount": getLocale("Current Account"),
  "jointaccount": getLocale("Joint Account"),

  //source of income
  "savings": getLocale("Savings"),
  "investment": getLocale("Investment/Fixed Deposit"),
  "salary": getLocale("Salary/Commission"),
  "inheritance": getLocale("Inheritance"),
  "companyprofit": getLocale("Company's Profit"),
  "sellofshare": getLocale("Sell of Shares"),
  "loan": getLocale("Loan"),
  "allowance": getLocale("Allowance from Parent/Family Member"),
  "othersrc": getLocale("Others"),

  //education lv
  "kindergarten": getLocale("Kindergarten"),
  "primaryschool": getLocale("Primary School"),
  "highschool": getLocale("High School"),
  "diplomaAbove": getLocale("Diploma & Above"),
  "bachelord": getLocale("Bachelor Degree"),
  "professional": getLocale("Professional Qualification"),

  //educactionstatus
  "belowsecondary": getLocale("Below Secondary"),
  "secondary": getLocale("Secondary"),
  "diploma": getLocale("Diploma"),
  "bachelor": getLocale("Bachelor"),
  "master": getLocale("Master"),
  "doctorate": getLocale("Doctorate"),
  "profqualification": getLocale("Prof Qualification"),
  "notapplicable": getLocale("Not Applicable"),

  //relation
  "spouse": getLocale("Spouse"),
  "own": getLocale("Own"),
  "children": getLocale("Children"),
  "child": getLocale("Child"),
  "parent": getLocale("Parent"),
  "agent": getLocale("Agent"),
  "othersrelation": getLocale("Others"),
  "self": getLocale("Self"),
  "family": getLocale("Family"),

  "brother": getLocale("Brother"),
  "sister": getLocale("Sister"),
  "father": getLocale("Father"),
  "mother": getLocale("Mother"),
  "husband": getLocale("Husband"),
  "wife": getLocale("Wife"),
  "son": getLocale("Son"),
  "daughter": getLocale("Daughter"),
  "soninlaw": getLocale("Son In Law"),
  "daughterinlaw": getLocale("Daughter In Law"),
  "brotherinlaw": getLocale("Brother In Law"),
  "sisterinlaw": getLocale("Sister In Law"),
  "fatherinlaw": getLocale("Father In Law"),
  "motherinlaw": getLocale("Mother In Law"),
  "uncle": getLocale("Uncle"),
  "auntie": getLocale("Auntie"),
  "niece": getLocale("Niece"),
  "nephew": getLocale("Nephew"),
  "grandfather": getLocale("Grandfather"),
  "grandmother": getLocale("Grandmother"),
  "employer": getLocale("Employer"),
  "financial": getLocale("Financial"),
  "friend": getLocale("Friend"),
  "grandchild": getLocale("Grandchild"),
  "stepmother": getLocale("Stepmother"),
  "stepfather": getLocale("Stepfather"),
  "stepbrother": getLocale("Stepbrother"),
  "partner": getLocale("Partner"),
  "stepdaughter": getLocale("Stepdaughter"),
  "stepson": getLocale("Stepson"),
  "adopteddaughter": getLocale("Adopted Daughter"),
  "adoptedson": getLocale("Adopted Son"),
  "granddaughter": getLocale("Granddaughter"),
  "grandson": getLocale("Grandson"),
  "goddaughter": getLocale("Goddaughter"),
  "godson": getLocale("Godson"),
  "godfather": getLocale("Godfather"),
  "godmother": getLocale("Godmother"),
  "fosterfather": getLocale("Foster Father"),
  "fostermother": getLocale("Foster Mother"),
  "cousinbrother": getLocale("Cousin Brother"),
  "cousinsister": getLocale("Cousin Sister"),
  "fiance": getLocale("Fiance"),
  "legalguardian": getLocale("Legal Guardian"),
  "relative": getLocale("Relative"),
  "others": getLocale("Others"),
  "affinitygroup": getLocale("Affinity Group"),
  "employergroup": getLocale("Employer Group"),
  "otherfamily": getLocale("Other Family"),

  //risk
  "secure": getLocale("Secure"),
  "stable": getLocale("Stable"),
  "neutral": getLocale("Neutral"),
  "growth": getLocale("Growth"),
  "highgrowth": getLocale("High Growth"),

  //payment
  "recurring": getLocale("Initial + Recurring Payment"),
  "oneoff": getLocale("Initial Payment"),
  "creditdebit": getLocale("Debit/Credit Card Auto Pay"),
  "mpay": "MPay",
  "autodebit": getLocale("Auto Debit"),
  "salarydeduction": getLocale("Salary Deduction"),
  // "ezypay": "Maybank EzyPay",
  "directpayment": getLocale("Direct Payment Method"),
  "fpx": "FPX / E-Wallet",
  "othersautodebit": getLocale("Auto debit for other bank"),

  "priorityprotection": getLocale(
      "Protecting your family against Death, Emergency and Yourself against Disability and Critical Illness"),
  "priorityretirement": getLocale("Retirement Plan"),
  "priorityeducation": getLocale("Provision for your children’s education"),
  "prioritysaving": getLocale("Regular Savings for the Future"),
  "priorityinvestment": getLocale("Lump Sum Investment"),
  "prioritymedical": getLocale("Medical Plan"),

  "investmentPref1": getLocale("Secure"),
  "investmentPref2": getLocale("Stable"),
  "investmentPref3": getLocale("Neutral"),
  "investmentPref4": getLocale("Growth"),
  "investmentPref5": getLocale("High Growth"),

  "existingsaving": getLocale("Existing Savings and Investment Plans"),
  "existingretirement": getLocale("Existing Retirement Plans"),
  "existingchildreneducation": getLocale("Existing Children's Education Plans"),
  "existingprotection": getLocale("Existing Protection Plans"),
  "existingmedical": getLocale("Existing Medical Plans"),

  "discussionsaving": getLocale("Savings and Investment Plan"),
  "discussionretirement": getLocale("Retirement Plan"),
  "discussionchildreneducation": getLocale("Children's Education Plan"),
  "discussionprotection": getLocale("Protection Plan"),
  "discussionmedical": getLocale("Medical Plan"),

  "discussionyear": getLocale(
      "In how many years from now would you want the plan to mature in order to receive your saving/investment?"),
  "discussionamount": getLocale(
      "How much money do you target to allocate every month for your saving and investment plan?"),
  "discussionremarks": getLocale("Discussion remarks"),
  "discussioncharge": getLocale(
      "How much of the hospital daily room & board charge do you think is sufficient for you?"),
  "discussioncoverage": getLocale(
      "Do you need any medical, critical illness or accidental coverage to be added to this protection plan?"),
  "standard": getLocale(
      "This is a standard case. Kindly complete the declaration and make payment by today to secure the current premium and benefits."),
  "substandard": getLocale(
      "Your application requires further assessment. You will be contacted by your sales representative soon."),
  "gio": getLocale("The case is GIO"),
  "nongio": getLocale("The case is NONGIO")
};

var clientLabel = {
  "1": getLocale("Policy Owner", entity: true),
  "2": getLocale("Life Insured", entity: true),
  "3":
      "${getLocale("Policy Owner", entity: true)}/${getLocale("Life Insured", entity: true)}",
  "4": getLocale("Nominee"),
  "5": getLocale("Assignee"),
  "6": getLocale("Trustee"),
  "7": getLocale("Payor"),
  "8": getLocale("Witness"),
  "9": getLocale("Initial Payor"),
  "10": getLocale("Agent"),
  "11": getLocale("Parent/LegalGuardian"),
  "99": getLocale("Benefit Owner")
};

String lookupProductType(prodCode) {
  if (prodCode == "PCWI03") {
    return "${getLocale("Saving")}, ${getLocale("Education")}, ${getLocale("Protection")}, ${getLocale("Medical")}";
  } else if (prodCode == "PCJI01" || prodCode == "PCJI02") {
    return "${getLocale("Retirement")}, ${getLocale("Education")}, ${getLocale("Protection")}";
  } else if (prodCode == "PCHI03" || prodCode == "PCHI04") {
    return "${getLocale("Saving")}, ${getLocale("Education")}";
  } else if (prodCode == "PCTA01") {
    return getLocale("Protection");
  }
  return "";
}

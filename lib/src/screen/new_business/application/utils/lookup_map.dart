var identityTypeMap = {
  "passport": "1",
  "nric": "2",
  "oldic": "3",
  "armyic": "4",
  "policeic": "5",
  "birthcert": "6",
  "mypr": "11",
  "othersid": "99"
};

var lookupClientType = {
  "policyOwner": "1",
  "lifeInsured": "2",
  "poli": "3",
  "nominee": "4",
  "assignee": "5",
  "trustee": "6",
  "payor": "7",
  "witness": "8",
  "initialpayor": "9",
  "agent": "10",
  "guardian": "11",
  "benefitowner": "99"
};

var lookupMaritalStatus = {
  "married": "1",
  "single": "2",
  "widowed": "3",
  "divorced": "4",
  "others": "99"
};
var lookupRace = {
  "chinese": "CCC1",
  "native": "CCC4",
  "indian": "CCI1",
  "malay": "CCM1",
  "othersrace": "CCO1"
};
var lookupGender = {"Female": "F", "Male": "M"};
var lookupReligion = {
  "buddhism": "B",
  "christian": "C",
  "hinduism": "H",
  "islam": "I",
  "others": "O",
  "sikhism": "S"
};
var lookupLang = {
  "bahasamalaysia": "BMY",
  "chinese": "CHN",
  "english": "ENG",
  "others": "OTH",
  "tamil": "TAM"
};
var lookupState = {
  "Johor": "1",
  "Terengganu": "10",
  "Pahang": "11",
  "Sabah": "12",
  "Sarawak": "13",
  "Wp Kuala Lumpur": "14",
  "Melaka": "2",
  "Negeri Sembilan": "3",
  "Selangor": "4",
  "Perak": "5",
  "Kedah": "6",
  "Perlis": "7",
  "Penang": "8",
  "Kelantan": "9",
  "Wp Labuan": "14"
};
var lookupRelationship = {
  "brother": "1",
  "daughterinlaw": "10",
  "brotherinlaw": "11",
  "sisterinlaw": "12",
  "fatherinlaw": "13",
  "motherinlaw": "14",
  "uncle": "15",
  "auntie": "16",
  "niece": "17",
  "nephew": "18",
  "grandfather": "19",
  "sister": "2",
  "grandmother": "20",
  "employer": "22",
  "spouse": "23",
  "self": "24",
  "child": "25",
  "financial": "26",
  "friend": "27",
  "grandchild": "28",
  "stepmother": "29",
  "father": "3",
  "stepfather": "30",
  "stepbrother": "31",
  "partner": "33",
  "stepdaughter": "34",
  "stepson": "35",
  "adopteddaughter": "36",
  "adoptedson": "37",
  "granddaughter": "38",
  "grandson": "39",
  "mother": "4",
  "goddaughter": "40",
  "godson": "41",
  "godfather": "42",
  "godmother": "43",
  "fosterfather": "44",
  "fostermother": "45",
  "cousinbrother": "46",
  "cousinsister": "47",
  "fiance": "48",
  "legalguardian": "49",
  "husband": "5",
  "relative": "50",
  "others": "51",
  "affinitygroup": "52",
  "employergroup": "53",
  "otherfamily": "54",
  "wife": "6",
  "son": "7",
  "daughter": "8",
  "soninlaw": "9"
};

var lookupPayMode = {
  "12": "CC1",
  "6": "CC2",
  "3": "CC4",
  "1": "CC12",
  "Yearly": "CC1",
  "Half Yearly": "CC2",
  "Quarterly": "CC4",
  "Monthly": "CC12",
};

var lookupPayMethod = {
  "directpayment": "C001",
  "fpx": "C001",
  "autodebit": "C003",
  "standinginstruction": "C004",
  "salarydeduction": "C005",
  "bpa": "C006",
  "interbankfundtransfer": "C008",
  "creditcard": "C105",
};

var lookupClientChoice = {"Option 1": 1, "Option 2": 2, "Option 3": 3};

var lookupPurposeTrans = {
  "saving": 1,
  "protection": 2,
  "investment": 3,
  "education": 4,
  "retirement": 5,
  "inheritance": 6,
  "others": 99,
  "simpanan": 1,
  "perlindungan": 2,
  "pelaburan": 3,
  "tahap pendidikan": 4,
  "persaraan": 5,
  "warisan": 6,
  "lain": 99
};

var lookupMedDeductible = {
  "Full Coverage": "0",
  "10000": "1",
  "20000": "2",
  "40000": "3",
  "60000": "4",
  "2000": "8",
  "No Cover - Activation at age 60": "99"
};

var uwPropKIVStatus = {
  "Declined": "1",
  "Postponed": "2",
  "PCO": "3", // Pending Counter Offer
  "PR": "4", // Pending Requirements
  "PA": "5", // Pending Assessment
  "PSP": "6", // Pending for Short Payment
  "Standard": "7",
  "Inforce": "8",
  "Cancel": "9"
};

var lookupProductLOB = {
  "Traditional": "1",
  "Investment Link": "2",
  "Takaful Traditional": "15",
  "Takaful Investment Link": "16"
};

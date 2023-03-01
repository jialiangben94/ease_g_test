// const isDebug = true;
// const isByPassLogin = false;

// const apiTimeOut = 300;
const apiHeader = {
  "Content-type": "text/plain",
  "Content-SHA256": "",
  "Accept-Language": "",
  "Authorization": ""
};

// const String appID = "my.com.etiqa.ease";
// const String MALAY = "ms-MY";
// const String ENGLISH = "en-GB";

const String apiHeaderHash = "Content-SHA256";
const String apiHeaderLang = "Accept-Language";
const String apiHeaderAuth = "Authorization";
const String apiHeaderContentType = "Content-type";

// Shared Preference Key
const String spkEntity = "entity";
const String spkAgent = "agent";
const String spkToken = "token";
const String spkRefreshToken = "refreshToken";
const String spkRead = "read";
const String spkTNC = "tnc";
// const String SPK_WALKTHROUGH = "walkthrough";

// Flutter Secure Storage
const String fssLoginDetail = "login";
const String fssFailedLoginCount = "failCounter";
const String fssFailedLoginDT = "lastDTFail";

// const screenWidth = 1024;
// const screenHeight = 768;

//To add into byte image so cannot be open outside of this app
const List<int> byteFront = [12, 10, 15, 19, 22];
const List<int> byteBack = [88, 55, 99, 77, 19, 55];
const List<int> byteMiddle = [108, 33, 18, 11];
const int middleIndex = 33;

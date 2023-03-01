import 'package:flutter/services.dart';

String feraUrl =
    // 'https://www.etiqapartner.com.my/identity/authorize?appid=EaSEMobile'; //PROD
    'https://blueberry.etiqapartner.com.my/identity/authorize?appid=345678'; //UAT

String eppUrl =
    // 'https://www.etiqapartner.com.my/identity/authorize?appid=EaSEMobile'; //PROD
    'https://blueberry.etiqapartner.com.my/AgencyLifeUAT/Login.aspx'; //UAT

//THIS IS TO INVOKE VPMS METHOD (APPDELETE.M) FROM XCODE
const vpmsPlatform = MethodChannel('com.etiqapartner.stp.native/vpms');

const domain = "https://blueberry.etiqapartner.com.my"; //UAT
// const domain = "https://www.etiqapartner.com.my"; // PRODUCTION

const adh2Url = "$domain/AgentDataHub2/api/session"; //UAT
// const adh2Url = "$domain/AgentDataHub3/api/session"; //PRODUCTION

const nbLogin = "$domain/STP_NBOutbound/api/Outbound/Authenticate";

const adhConvert = "$adh2Url/convert";
const adhValidate = "$adh2Url/v2/validate";
const adhLogin = "$adh2Url/v3/login";
const adhChangePassword = "$adh2Url/v2/ChangePassword";
const adhResetPassword = "$adh2Url/v2/ResetPassword";
const adhUploadPhoto = "$adh2Url/v3/UploadPhoto";
const adhAccount = "$adh2Url/v3/account";
const adhLogout = "$adh2Url/v2/logout";
const adhTokenRenewal = "$adh2Url/v1/TokenRenewal";

const accountServices = "$domain/AccountServices/api";
const accountUpdateAddress = "$accountServices/UserDetail/UpdateAddress";
const accountUpdateMobile = "$accountServices/UserDetail/UpdateMobile";

// Medical Exam
const apiRegisterPushNotification =
    "$domain/EPSAgencynotification/api/PushNotification/Register";

const epsAgencyMedical = "$domain/EPSAgencyMedical/api";
const apiAppointment = "$epsAgencyMedical/AppointmentAPI";
const apiAppointmentStatus = "$epsAgencyMedical/AppointmentStatusAPI";
const apiPanelDetail = "$epsAgencyMedical/PanelDetailAPI";
const apiNotification = "$epsAgencyMedical/NotificationAPI";
const apiStatusJourney = "$epsAgencyMedical/StatusJourneyAPI";

const apiMedicalSubmitAppointment = "$apiAppointment/SubmitAppointment";
const apiMedicalEditAppointment = "$apiAppointment/EditAppointment";
const apiMedicalCancelAppointment = "$apiAppointment/CancelAppointment";
const apiMedicalRescheduleAppointment = "$apiAppointment/RescheduleAppointment";

const apiMedicalGetAllDoc =
    "$apiAppointmentStatus/RetrieveAllMedicalDocument?proposalMEId=";
const apiMedicalGetAppointmentListByStatus =
    "$apiAppointmentStatus/GetAppointmentListByStatus";

const apiMedicalGetPanelList = "$apiPanelDetail/RetrievePanelList";

const apiMedicalGetNotificationList = "$apiNotification/GetNotificationList";
const apiMedicalUpdateNotification = "$apiNotification/UpdateNotification";
const apiMedicalEmailECRM = "$apiNotification/EmailECRM";

const apiMedicalGetStatusJourney = "$apiStatusJourney/GetStatusJourney";

// New Business
//const stpNB = "$domain/STPNB/api";
// const stpNB = "$domain/STPNBBM/api";
const stpNB = "$domain/STPNBEPT/api";
//const stpNB = "$domain/STPNBMahabbah/api";
// const stpNB = "$domain/STPNBENRICH/api";
// const stpNB = "$domain/STPNBASPIRE/api";
// const stpNB = "$domain/STPNBTripleGrowth/api";

const stpNBELS = "$domain/STPNBELS/api";
const stpNBOutbound = "$domain/STP_NBOutbound/api";

const apiNBOutboundPayment = "$stpNBOutbound/Payment";

const apiNBQuotation = "$stpNB/Quotation";

const apiNBAccessControl = "$stpNB/User/AccesControl";
const submitFeedbackUrl = "$stpNBELS/User/Feedback";
const apiNBValidation = "$stpNB/Validation";
const apiNBVPMS = "$apiNBValidation/VPMS";
const apiNBMasterData = "$stpNB/MasterData";

const apiNBLead = "$stpNB/Lead";
const apiNBSearchLeadFFF = "$apiNBLead/SearchLeadFFF";
const apiNBGetExistingCoverage = "$apiNBLead/GetExistingCoverage";

const apiNBGetConfig = "$stpNB/Setting/GetConfig";

const apiNBRemoteSubmission = "$stpNB/RemoteSubmission";

const apiNBSubmitApplication = "$stpNB/Application/SubmitApplication";
const apiNBGetApplicationStatus = "$stpNB/Application/Application";

// //FERA URL
// const apiFERA = domain + "/api/auth/authorize?appid=345678";

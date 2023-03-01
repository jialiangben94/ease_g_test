#include "AppDelegate.h"
#import "FlutterVpms.h"
#include "GeneratedPluginRegistrant.h"
#import <FlutterLocalNotificationsPlugin.h>

@interface AppDelegate ()
@property(strong, nonatomic) UIVisualEffectView *visualEffectView;
@end

@implementation AppDelegate

FlutterVpmsBuffer *vpmsBuffer;
FlutterVpmsSession *vpmsSession;
FlutterVpmsChoiceBuffer *vpmsChoiceBuffer;
NSString *premiumText;

// SI
NSString *P_Total_Prem, *P_Prem_Monthly, *P_Prem_Quarterly, *P_Prem_HalfYearly,
    *P_Prem_Annually, *P_Basic_SA, *P_Basic_PolTerm, *P_Basic_PremTerm,
    *P_Basic_Prem, *P_LTR_SA, *P_LTR_PolTerm, *P_LTR_PremTerm, *P_LTR_Prem,
    *P_FIBR_SA, *P_FIBR_PolTerm, *P_FIBR_PremTerm, *P_FIBR_Prem, *P_PWJ_SA,
    *P_PWJ_PolTerm, *P_PWJ_PremTerm, *P_PWJ_Prem, *P_PWS_SA, *P_PWS_PolTerm,
    *P_PWS_PremTerm, *P_PWS_Prem,
    // SI Document
    *P_Version, *P_ANB, *P_OccClass, *P_PolTerm, *P_PremPaymentTerm,
    *P_MaturityAge, *P_PremPayableMode, *P_PO_ANB, *P_PO_OccClass, *P_Occ_Load,
    *P_PlanName, *P_PlanType, *P_O_LI_EoPolYr, *P_O_LI_AnnPrem,
    *P_O_LI_AccAnnPrem, *P_O_LI_DTPD_NA, *P_O_LI_DTPD_A, *P_O_LI_MaturityBen,
    *P_O_LI_SurrVal, *P_O_LI_AccBonus, *P_O_LI_SurrValonAcc,
    *P_O_LI_TotalPolVal, *P_O_LI_AttainedAge, *P_O_PO_EoPolYr, *P_O_PO_AnnPrem,
    *P_O_PO_AccAnnPrem, *P_O_PO_PW_DTPD, *P_O_PO_FIBR, *P_O_PO_AttainedAge,
    // v1.5 add-on (SI & SI Document)
    *P_PremMode_BasicPlan, *P_PremMode_TotalPrem, *P_1EndofYear_Wording,
    *P_2EndofYear_Wording, *P_3EndofYear_Wording, *P_4EndofYear_Wording,
    *P_O_PerDiscount, *P_O_PremAfterDisc, *P_EligibleRiders, *P_IOS_OCC_Load,
    *P_TotalPremium_withOcc_IOS, *P_IOS_PWS_SA, *P_IOS_PWJ_SA,
    // v1.12 add-on (P_TotalPremium_IOS)- Total Premium after staff
    // discount(without occupational loading)
    *P_TotalPremium_IOS,
    // v1.14 add-on
    // P_IOS_Basic_OccExtra_MRate
    // P_IOS_LTR_OccExtra_MRate
    // P_IOS_FIB_OccExtra_MRate
    // P_IOS_PWJ_OccExtra_MRate
    // P_IOS_PWS_OccExtra_MRate
    *P_IOS_Basic_OccExtra_MRate, *P_IOS_LTR_OccExtra_MRate,
    *P_IOS_FIB_OccExtra_MRate, *P_IOS_PWJ_OccExtra_MRate,
    *P_IOS_PWS_OccExtra_MRate;

// Error Messages of Input Parameter
NSString *A_Quotation_Date, *A_Gender, *A_DOB, *A_Occupation,
    *A_MaybankAccHolder, *A_Staff, *A_Smoker, *A_PremFrequency, *A_PO_IND,
    *A_PO_Gender, *A_PO_DOB, *A_PO_Occupation, *A_PO_Smoker, *A_Basic_Plan_Name,
    *A_Basic_SA, *A_Basic_Plan, *A_FIBR_IND, *A_LTR_IND, *A_LTR_SA, *A_PWS_IND,
    *A_PWJ_IND;

NSMutableArray *premiumArray;
NSMutableArray *errorArray;
NSDictionary *vpmsInfo;
NSData *jsonData;

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  FlutterViewController *controller =
      (FlutterViewController *)self.window.rootViewController;

  vpmsBuffer = [[FlutterVpmsBuffer alloc] initWithCapacity:1024];
  vpmsSession = [[FlutterVpmsSession alloc] init];

  FlutterMethodChannel *vpmsChannel = [FlutterMethodChannel
      methodChannelWithName:@"com.etiqapartner.stp.native/vpms"
            binaryMessenger:controller];

  __weak typeof(self) weakSelf = self;
  [vpmsChannel setMethodCallHandler:^(FlutterMethodCall *call,
                                      FlutterResult result) {
    if ([@"getVPMSVersion" isEqualToString:call.method]) {
      NSLog(@"Version: %@", call.method);

      @try {
        NSDictionary *params = call.arguments;

        if (call.arguments == nil) {
          result(@"No parameters in method: (calculatePremium)");
        } else if (params != nil) {
          NSString *vpmsFileName =
              [NSString stringWithFormat:@"vpms/%@", params[@"vpmsFileName"]];
          // Load VPMS - .vpm file
          [vpmsSession closesession];
          [vpmsSession loadsession:vpmsFileName];

          NSString *vpmsData = [weakSelf getVPMSVersion];
          NSLog(@"Version: %@", vpmsData);

          result(vpmsData);

        } else {
          result(@"Could not extract parameters in method: (getVPMSVersion)");
        }
      } @catch (NSException *exception) {
        NSLog(@"getVPMSVersion :%@", exception.reason);
      } @finally {
        NSLog(@"Final getVPMSVersion");
      }
    } else if ([@"setInput" isEqualToString:call.method]) {
      @try {
        NSDictionary *params = call.arguments;

        if (call.arguments == nil) {
          result(@"No parameters in method: (setInput)");
        } else if (params != nil) {
          for (NSString *key in params.allKeys) {
            NSString *value = [params objectForKey:key];
            NSMutableArray *vpmsData = [weakSelf setInput:key inputValue:value];
            result(vpmsData);
          }
        } else {
          result(@"Could not extract parameters in method: (calculatePremium)");
        }
      } @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
      } @finally {
        NSLog(@"Final");
      }
    } else if ([@"setAnyway" isEqualToString:call.method]) {
      @try {
        NSString *key = call.arguments;
        if (call.arguments == nil) {
          result(@"No parameters in method: (setAnyway)");
        } else if (key != nil) {
          NSMutableArray *vpmsData = [weakSelf setAnyway:key];
          result(vpmsData);
        } else {
          result(@"Could not extract parameters in method: (setAnyway)");
        }
      } @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
      } @finally {
        NSLog(@"Final setAnyway");
      }
    } else if ([@"calculatePremium" isEqualToString:call.method]) {
      @try {
        NSDictionary *params = call.arguments;

        if (call.arguments == nil) {
          result(@"No parameters in method: (calculatePremium)");
        } else if (params != nil) {
          NSString *vpmsFileName =
              [NSString stringWithFormat:@"vpms/%@", params[@"vpmsFileName"]];
          // Load VPMS - .vpm file
          [vpmsSession loadsession:vpmsFileName];

          NSMutableArray *vpmsData =
              [weakSelf calculateAllPremium:params[@"quotationDate"]
                                   liGender:params[@"liGender"]
                                      liDob:params[@"liDob"]
                               liOccupation:params[@"liOccupation"]
                           isLiMbbAccHolder:params[@"isLiMbbAccHolder"]
                                  isLiStaff:params[@"isLiStaff"]
                                 isLiSmoker:params[@"isLiSmoker"]
                           premiumFrequency:params[@"premiumFrequency"]
                                     isLiPo:params[@"isLiPo"]
                                   poGender:params[@"poGender"]
                                      poDob:params[@"poDob"]
                               poOccupation:params[@"poOccupation"]
                                 isPoSmoker:params[@"isPoSmoker"]
                              basicPlanName:params[@"basicPlanName"]
                                    basicSA:params[@"basicSA"]
                                  basicPlan:params[@"basicPlan"]
                                    fibrIND:params[@"fibrIND"]
                                     ltrIND:params[@"ltrIND"]
                                      ltrSA:params[@"ltrSA"]
                                     pwsIND:params[@"pwsIND"]
                                     pwjIND:params[@"pwjIND"]];

          if (vpmsData[0] == nil) {
            result(vpmsData[0]);
          } else {
            result(vpmsData);
          }
        } else {
          result(@"Could not extract parameters in method: (calculatePremium)");
        }
      } @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
      } @finally {
        NSLog(@"Final");
      }
    } else if ([@"getInputError" isEqualToString:call.method]) {
      @try {
        NSDictionary *params = call.arguments;

        if (call.arguments == nil) {
          result(@"No parameters in method: (getInputError)");
        } else if (params != nil) {
          NSString *vpmsFileName =
              [NSString stringWithFormat:@"vpms/%@", params[@"vpmsFileName"]];
          // Load VPMS - .vpm file
          [vpmsSession loadsession:vpmsFileName];

          NSMutableArray *vpmsData =
              [weakSelf getInputError:params[@"quotationDate"]
                             liGender:params[@"liGender"]
                                liDob:params[@"liDob"]
                         liOccupation:params[@"liOccupation"]
                     isLiMbbAccHolder:params[@"isLiMbbAccHolder"]
                            isLiStaff:params[@"isLiStaff"]
                           isLiSmoker:params[@"isLiSmoker"]
                     premiumFrequency:params[@"premiumFrequency"]
                               isLiPo:params[@"isLiPo"]
                             poGender:params[@"poGender"]
                                poDob:params[@"poDob"]
                         poOccupation:params[@"poOccupation"]
                           isPoSmoker:params[@"isPoSmoker"]
                        basicPlanName:params[@"basicPlanName"]
                              basicSA:params[@"basicSA"]
                            basicPlan:params[@"basicPlan"]
                              fibrIND:params[@"fibrIND"]
                               ltrIND:params[@"ltrIND"]
                                ltrSA:params[@"ltrSA"]
                               pwsIND:params[@"pwsIND"]
                               pwjIND:params[@"pwjIND"]];

          if (vpmsData[0] == nil) {
            result(vpmsData[0]);
          } else {
            result(vpmsData);
          }
        } else {
          result(@"Could not extract parameters in method: (getInputError)");
        }
      } @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
      } @finally {
        NSLog(@"Final");
      }
    } else {
      result(FlutterMethodNotImplemented);
    }
  }];

  [FlutterLocalNotificationsPlugin setPluginRegistrantCallback:registerPlugins];

  if (@available(iOS 10.0, *)) {
    [UNUserNotificationCenter currentNotificationCenter].delegate = (id<UNUserNotificationCenterDelegate>) self;
  }

  [GeneratedPluginRegistrant registerWithRegistry:self];
  return [super application:application
      didFinishLaunchingWithOptions:launchOptions];
}

// Using applicationDidEnterBackground to cover app content because iOS will
// capture snapshot of the app this snapshot is used to represent your
// application in the task switcher. By altering its view hierarchy prior to
// being suspended, an application can control how it appears in the task
// switcher.

// applicationWillResignActive is too sensitive and will be trigger even when
// user authenticate using biometric therefore hiding the login screen

- (UIVisualEffectView *)visualEffectView {
  if (!_visualEffectView) {
    UIBlurEffect *blurEffect =
        [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    _visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    _visualEffectView.frame = [UIScreen mainScreen].bounds;
  }
  return _visualEffectView;
}

void registerPlugins(NSObject<FlutterPluginRegistry>* registry) {
    [GeneratedPluginRegistrant registerWithRegistry:registry];
}

- (void)applicationWillResignActive:(UIApplication *)application {
  [[UIApplication sharedApplication].keyWindow
      addSubview:self.visualEffectView];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  if (self.visualEffectView) {
    [self.visualEffectView removeFromSuperview];
  }
}

// - (void)applicationDidEnterBackground:(UIApplication *)application
// {
//   UIImageView *imageView = [[UIImageView alloc]
//   initWithFrame:self.window.bounds];

//   imageView.tag = 101;
//   [imageView setImage:[UIImage imageNamed:@"background"]];

//   [UIApplication.sharedApplication.keyWindow.subviews.lastObject
//   addSubview:imageView];
// }

// - (void)applicationDidBecomeActive:(UIApplication *)application
// {
//   UIImageView *imageView = (UIImageView
//   *)[UIApplication.sharedApplication.keyWindow.subviews.lastObject
//   viewWithTag:101]; [imageView removeFromSuperview];
// }

// Michael Yau 2019-06-22
- (NSMutableArray *)calculateAllPremium:(NSString *)quotationDate
                               liGender:(NSString *)liGender
                                  liDob:(NSString *)liDob
                           liOccupation:(NSString *)liOccupation
                       isLiMbbAccHolder:(NSString *)isLiMbbAccHolder
                              isLiStaff:(NSString *)isLiStaff
                             isLiSmoker:(NSString *)isLiSmoker
                       premiumFrequency:(NSString *)premiumFrequency
                                 isLiPo:(NSString *)isLiPo
                               poGender:(NSString *)poGender
                                  poDob:(NSString *)poDob
                           poOccupation:(NSString *)poOccupation
                             isPoSmoker:(NSString *)isPoSmoker
                          basicPlanName:(NSString *)basicPlanName
                                basicSA:(NSString *)basicSA
                              basicPlan:(NSString *)basicPlan
                                fibrIND:(NSString *)fibrIND
                                 ltrIND:(NSString *)ltrIND
                                  ltrSA:(NSString *)ltrSA
                                 pwsIND:(NSString *)pwsIND
                                 pwjIND:(NSString *)pwjIND {
  @try {
    [vpmsSession setvar:@"A_Quotation_Date" value:quotationDate];
    [vpmsSession setvar:@"A_Gender" value:liGender];
    [vpmsSession setvar:@"A_DOB" value:liDob];  //
    [vpmsSession setvar:@"A_Occupation" value:liOccupation];
    [vpmsSession setvar:@"A_MaybankAccHolder" value:isLiMbbAccHolder];
    [vpmsSession setvar:@"A_Staff" value:isLiStaff];
    [vpmsSession setvar:@"A_Smoker" value:isLiSmoker];
    [vpmsSession setvar:@"A_PremFrequency" value:premiumFrequency];
    [vpmsSession setvar:@"A_PO_IND" value:isLiPo];
    [vpmsSession setvar:@"A_PO_Gender" value:poGender];
    [vpmsSession setvar:@"A_PO_DOB" value:poDob];
    [vpmsSession setvar:@"A_PO_Occupation" value:poOccupation];
    [vpmsSession setvar:@"A_PO_Smoker" value:isPoSmoker];
    [vpmsSession setvar:@"A_Basic_Plan_Name" value:basicPlanName];
    [vpmsSession setvar:@"A_Basic_SA" value:basicSA];
    [vpmsSession setvar:@"A_Basic_Plan" value:basicPlan];
    [vpmsSession setvar:@"A_FIBR_IND" value:fibrIND];
    [vpmsSession setvar:@"A_LTR_IND" value:ltrIND];
    [vpmsSession setvar:@"A_LTR_SA"
                  value:ltrSA];  // LRT_SA have to pass in as input, but
                                 // actually is basicSA.
    [vpmsSession setvar:@"A_PWS_IND" value:pwsIND];
    [vpmsSession setvar:@"A_PWJ_IND" value:pwjIND];

    [vpmsSession compute:@"P_Total_Prem" buf:vpmsBuffer];
    P_Total_Prem = vpmsBuffer.result;

    [vpmsSession compute:@"P_Prem_Monthly" buf:vpmsBuffer];
    P_Prem_Monthly = vpmsBuffer.result;

    [vpmsSession compute:@"P_Prem_Quarterly" buf:vpmsBuffer];
    P_Prem_Quarterly = vpmsBuffer.result;

    [vpmsSession compute:@"P_Prem_HalfYearly" buf:vpmsBuffer];
    P_Prem_HalfYearly = vpmsBuffer.result;

    [vpmsSession compute:@"P_Prem_Annually" buf:vpmsBuffer];
    P_Prem_Annually = vpmsBuffer.result;

    [vpmsSession compute:@"P_Basic_SA" buf:vpmsBuffer];
    P_Basic_SA = vpmsBuffer.result;

    [vpmsSession compute:@"P_Basic_PolTerm" buf:vpmsBuffer];
    P_Basic_PolTerm = vpmsBuffer.result;

    [vpmsSession compute:@"P_Basic_PremTerm" buf:vpmsBuffer];
    P_Basic_PremTerm = vpmsBuffer.result;

    [vpmsSession compute:@"P_Basic_Prem" buf:vpmsBuffer];
    P_Basic_Prem = vpmsBuffer.result;

    [vpmsSession compute:@"P_LTR_SA" buf:vpmsBuffer];
    P_LTR_SA = vpmsBuffer.result;

    [vpmsSession compute:@"P_LTR_PolTerm" buf:vpmsBuffer];
    P_LTR_PolTerm = vpmsBuffer.result;

    [vpmsSession compute:@"P_LTR_PremTerm" buf:vpmsBuffer];
    P_LTR_PremTerm = vpmsBuffer.result;

    [vpmsSession compute:@"P_LTR_Prem" buf:vpmsBuffer];
    P_LTR_Prem = vpmsBuffer.result;

    [vpmsSession compute:@"P_FIBR_SA" buf:vpmsBuffer];
    P_FIBR_SA = vpmsBuffer.result;

    [vpmsSession compute:@"P_FIBR_PolTerm" buf:vpmsBuffer];
    P_FIBR_PolTerm = vpmsBuffer.result;

    [vpmsSession compute:@"P_FIBR_PremTerm" buf:vpmsBuffer];
    P_FIBR_PremTerm = vpmsBuffer.result;

    [vpmsSession compute:@"P_FIBR_Prem" buf:vpmsBuffer];
    P_FIBR_Prem = vpmsBuffer.result;

    [vpmsSession compute:@"P_PWJ_SA" buf:vpmsBuffer];
    P_PWJ_SA = vpmsBuffer.result;

    [vpmsSession compute:@"P_PWJ_PolTerm" buf:vpmsBuffer];
    P_PWJ_PolTerm = vpmsBuffer.result;

    [vpmsSession compute:@"P_PWJ_PremTerm" buf:vpmsBuffer];
    P_PWJ_PremTerm = vpmsBuffer.result;

    [vpmsSession compute:@"P_PWJ_Prem" buf:vpmsBuffer];
    P_PWJ_Prem = vpmsBuffer.result;

    [vpmsSession compute:@"P_PWS_SA" buf:vpmsBuffer];
    P_PWS_SA = vpmsBuffer.result;

    [vpmsSession compute:@"P_PWS_PolTerm" buf:vpmsBuffer];
    P_PWS_PolTerm = vpmsBuffer.result;

    [vpmsSession compute:@"P_PWS_PremTerm" buf:vpmsBuffer];
    P_PWS_PremTerm = vpmsBuffer.result;

    [vpmsSession compute:@"P_PWS_Prem" buf:vpmsBuffer];
    P_PWS_Prem = vpmsBuffer.result;

    [vpmsSession compute:@"P_Version" buf:vpmsBuffer];
    P_Version = vpmsBuffer.result;

    [vpmsSession compute:@"P_ANB" buf:vpmsBuffer];
    P_ANB = vpmsBuffer.result;

    [vpmsSession compute:@"P_OccClass" buf:vpmsBuffer];
    P_OccClass = vpmsBuffer.result;

    [vpmsSession compute:@"P_PolTerm" buf:vpmsBuffer];
    P_PolTerm = vpmsBuffer.result;

    [vpmsSession compute:@"P_PremPaymentTerm" buf:vpmsBuffer];
    P_PremPaymentTerm = vpmsBuffer.result;

    [vpmsSession compute:@"P_MaturityAge" buf:vpmsBuffer];
    P_MaturityAge = vpmsBuffer.result;

    [vpmsSession compute:@"P_PremPayableMode" buf:vpmsBuffer];
    P_PremPayableMode = vpmsBuffer.result;

    [vpmsSession compute:@"P_PO_ANB" buf:vpmsBuffer];
    P_PO_ANB = vpmsBuffer.result;

    [vpmsSession compute:@"P_PO_OccClass" buf:vpmsBuffer];
    P_PO_OccClass = vpmsBuffer.result;

    [vpmsSession compute:@"P_Occ_Load" buf:vpmsBuffer];
    P_Occ_Load = vpmsBuffer.result;

    [vpmsSession compute:@"P_PlanName" buf:vpmsBuffer];
    P_PlanName = vpmsBuffer.result;

    [vpmsSession compute:@"P_PlanType" buf:vpmsBuffer];
    P_PlanType = vpmsBuffer.result;

    [vpmsSession compute:@"P_O_LI_EoPolYr" buf:vpmsBuffer];
    P_O_LI_EoPolYr = vpmsBuffer.result;

    [vpmsSession compute:@"P_O_LI_AnnPrem" buf:vpmsBuffer];
    P_O_LI_AnnPrem = vpmsBuffer.result;

    [vpmsSession compute:@"P_O_LI_AccAnnPrem" buf:vpmsBuffer];
    P_O_LI_AccAnnPrem = vpmsBuffer.result;

    [vpmsSession compute:@"P_O_LI_DTPD_NA" buf:vpmsBuffer];
    P_O_LI_DTPD_NA = vpmsBuffer.result;

    [vpmsSession compute:@"P_O_LI_DTPD_A" buf:vpmsBuffer];
    P_O_LI_DTPD_A = vpmsBuffer.result;

    [vpmsSession compute:@"P_O_LI_MaturityBen" buf:vpmsBuffer];
    P_O_LI_MaturityBen = vpmsBuffer.result;

    [vpmsSession compute:@"P_O_LI_SurrVal" buf:vpmsBuffer];
    P_O_LI_SurrVal = vpmsBuffer.result;

    [vpmsSession compute:@"P_O_LI_AccBonus" buf:vpmsBuffer];
    P_O_LI_AccBonus = vpmsBuffer.result;

    [vpmsSession compute:@"P_O_LI_SurrValonAcc" buf:vpmsBuffer];
    P_O_LI_SurrValonAcc = vpmsBuffer.result;

    [vpmsSession compute:@"P_O_LI_TotalPolVal" buf:vpmsBuffer];
    P_O_LI_TotalPolVal = vpmsBuffer.result;

    [vpmsSession compute:@"P_O_LI_AttainedAge" buf:vpmsBuffer];
    P_O_LI_AttainedAge = vpmsBuffer.result;

    [vpmsSession compute:@"P_O_PO_EoPolYr" buf:vpmsBuffer];
    P_O_PO_EoPolYr = vpmsBuffer.result;

    [vpmsSession compute:@"P_O_PO_AnnPrem" buf:vpmsBuffer];
    P_O_PO_AnnPrem = vpmsBuffer.result;

    [vpmsSession compute:@"P_O_PO_AccAnnPrem" buf:vpmsBuffer];
    P_O_PO_AccAnnPrem = vpmsBuffer.result;

    [vpmsSession compute:@"P_O_PO_PW_DTPD" buf:vpmsBuffer];
    P_O_PO_PW_DTPD = vpmsBuffer.result;

    [vpmsSession compute:@"P_O_PO_FIBR" buf:vpmsBuffer];
    P_O_PO_FIBR = vpmsBuffer.result;

    [vpmsSession compute:@"P_O_PO_AttainedAge" buf:vpmsBuffer];
    P_O_PO_AttainedAge = vpmsBuffer.result;
    // v1.5 add-on
    [vpmsSession compute:@"P_PremMode_BasicPlan" buf:vpmsBuffer];
    P_PremMode_BasicPlan = vpmsBuffer.result;

    [vpmsSession compute:@"P_PremMode_TotalPrem" buf:vpmsBuffer];
    P_PremMode_TotalPrem = vpmsBuffer.result;

    [vpmsSession compute:@"P_1EndofYear_Wording" buf:vpmsBuffer];
    P_1EndofYear_Wording = vpmsBuffer.result;

    [vpmsSession compute:@"P_2EndofYear_Wording" buf:vpmsBuffer];
    P_2EndofYear_Wording = vpmsBuffer.result;

    [vpmsSession compute:@"P_3EndofYear_Wording" buf:vpmsBuffer];
    P_3EndofYear_Wording = vpmsBuffer.result;

    [vpmsSession compute:@"P_4EndofYear_Wording" buf:vpmsBuffer];
    P_4EndofYear_Wording = vpmsBuffer.result;

    [vpmsSession compute:@"P_O_PerDiscount" buf:vpmsBuffer];
    P_O_PerDiscount = vpmsBuffer.result;

    [vpmsSession compute:@"P_O_PremAfterDisc" buf:vpmsBuffer];
    P_O_PremAfterDisc = vpmsBuffer.result;

    [vpmsSession compute:@"P_EligibleRiders" buf:vpmsBuffer];
    P_EligibleRiders = vpmsBuffer.result;

    [vpmsSession compute:@"P_IOS_OCC_Load" buf:vpmsBuffer];
    P_IOS_OCC_Load = vpmsBuffer.result;

    [vpmsSession compute:@"P_TotalPremium_IOS" buf:vpmsBuffer];
    P_TotalPremium_IOS = vpmsBuffer.result;

    [vpmsSession compute:@"P_TotalPremium_withOcc_IOS" buf:vpmsBuffer];
    P_TotalPremium_withOcc_IOS = vpmsBuffer.result;

    [vpmsSession compute:@"P_IOS_PWS_SA" buf:vpmsBuffer];
    P_IOS_PWS_SA = vpmsBuffer.result;

    [vpmsSession compute:@"P_IOS_PWJ_SA" buf:vpmsBuffer];
    P_IOS_PWJ_SA = vpmsBuffer.result;

    [vpmsSession compute:@"P_IOS_Basic_OccExtra_MRate" buf:vpmsBuffer];
    P_IOS_Basic_OccExtra_MRate = vpmsBuffer.result;

    [vpmsSession compute:@"P_IOS_LTR_OccExtra_MRate" buf:vpmsBuffer];
    P_IOS_LTR_OccExtra_MRate = vpmsBuffer.result;

    [vpmsSession compute:@"P_IOS_FIB_OccExtra_MRate" buf:vpmsBuffer];
    P_IOS_FIB_OccExtra_MRate = vpmsBuffer.result;

    [vpmsSession compute:@"P_IOS_PWJ_OccExtra_MRate" buf:vpmsBuffer];
    P_IOS_PWJ_OccExtra_MRate = vpmsBuffer.result;

    [vpmsSession compute:@"P_IOS_PWS_OccExtra_MRate" buf:vpmsBuffer];
    P_IOS_PWS_OccExtra_MRate = vpmsBuffer.result;

    vpmsInfo = [NSDictionary
        dictionaryWithObjectsAndKeys:
            @"P_Total_Prem", P_Total_Prem, @"P_Prem_Monthly", P_Prem_Monthly,
            @"P_Prem_Quarterly", P_Prem_Quarterly, @"P_Prem_HalfYearly",
            P_Prem_HalfYearly, @"P_Prem_Annually", P_Prem_Annually,

            @"P_Basic_SA", P_Basic_SA, @"P_Basic_PolTerm", P_Basic_PolTerm,
            @"P_Basic_PremTerm", P_Basic_PremTerm, @"P_Basic_Prem",
            P_Basic_Prem,

            @"P_LTR_SA", P_LTR_SA, @"P_LTR_PolTerm", P_LTR_PolTerm,
            @"P_LTR_PremTerm", P_LTR_PremTerm, @"P_LTR_Prem", P_LTR_Prem,

            @"P_FIBR_SA", P_FIBR_SA, @"P_FIBR_PolTerm", P_FIBR_PolTerm,
            @"P_FIBR_PremTerm", P_FIBR_PremTerm, @"P_FIBR_Prem", P_FIBR_Prem,

            @"P_PWJ_SA", P_PWJ_SA, @"P_PWJ_PolTerm", P_PWJ_PolTerm,
            @"P_PWJ_PremTerm", P_PWJ_PremTerm, @"P_PWJ_Prem", P_PWJ_Prem,

            @"P_PWS_SA", P_PWS_SA, @"P_PWS_PolTerm", P_PWS_PolTerm,
            @"P_PWS_PremTerm", P_PWS_PremTerm, @"P_PWS_Prem", P_PWS_Prem,

            @"P_Version", P_Version, @"P_ANB", P_ANB, @"P_OccClass", P_OccClass,
            @"P_PolTerm", P_PolTerm, @"P_PremPaymentTerm", P_PremPaymentTerm,
            @"P_MaturityAge", P_MaturityAge, @"P_PremPayableMode",
            P_PremPayableMode,

            @"P_PO_ANB", P_PO_ANB, @"P_PO_OccClass", P_PO_OccClass,
            @"P_Occ_Load", P_Occ_Load,

            @"P_PlanName", P_PlanName, @"P_PlanType", P_PlanType,

            @"P_O_LI_EoPolYr", P_O_LI_EoPolYr, @"P_O_LI_AnnPrem",
            P_O_LI_AnnPrem, @"P_O_LI_AccAnnPrem", P_O_LI_AccAnnPrem,
            @"P_O_LI_DTPD_NA", P_O_LI_DTPD_NA, @"P_O_LI_DTPD_A", P_O_LI_DTPD_A,
            @"P_O_LI_MaturityBen", P_O_LI_MaturityBen, @"P_O_LI_SurrVal",
            P_O_LI_SurrVal, @"P_O_LI_AccBonus", P_O_LI_AccBonus,
            @"P_O_LI_SurrValonAcc", P_O_LI_SurrValonAcc, @"P_O_LI_TotalPolVal",
            P_O_LI_TotalPolVal, @"P_O_LI_AttainedAge", P_O_LI_AttainedAge,

            @"P_O_PO_EoPolYr", P_O_PO_EoPolYr, @"P_O_PO_AnnPrem",
            P_O_PO_AnnPrem, @"P_O_PO_AccAnnPrem", P_O_PO_AccAnnPrem,
            @"P_O_PO_PW_DTPD", P_O_PO_PW_DTPD, @"P_O_PO_FIBR", P_O_PO_FIBR,
            @"P_O_PO_AttainedAge", P_O_PO_AttainedAge,

            // v1.5 add-on
            @"P_PremMode_BasicPlan", P_PremMode_BasicPlan,
            @"P_PremMode_TotalPrem", P_PremMode_TotalPrem,
            @"P_1EndofYear_Wording", P_1EndofYear_Wording,
            @"P_2EndofYear_Wording", P_2EndofYear_Wording,
            @"P_3EndofYear_Wording", P_3EndofYear_Wording,
            @"P_4EndofYear_Wording", P_4EndofYear_Wording, @"P_O_PerDiscount",
            P_O_PerDiscount, @"P_O_PremAfterDisc", P_O_PremAfterDisc,
            @"P_EligibleRiders", P_EligibleRiders, @"P_IOS_OCC_Load",
            P_IOS_OCC_Load, @"P_TotalPremium_IOS",
            P_TotalPremium_IOS,  // v1.12 add-on
            @"P_TotalPremium_withOcc_IOS", P_TotalPremium_withOcc_IOS,
            @"P_IOS_PWS_SA", P_IOS_PWS_SA, @"P_IOS_PWJ_SA", P_IOS_PWJ_SA,

            // v1.14 add-on
            @"P_IOS_Basic_OccExtra_MRate", P_IOS_Basic_OccExtra_MRate,
            @"P_IOS_LTR_OccExtra_MRate", P_IOS_LTR_OccExtra_MRate,
            @"P_IOS_FIB_OccExtra_MRate", P_IOS_FIB_OccExtra_MRate,
            @"P_IOS_PWJ_OccExtra_MRate", P_IOS_PWJ_OccExtra_MRate,
            @"P_IOS_PWS_OccExtra_MRate", P_IOS_PWS_OccExtra_MRate, nil];

    jsonData =
        [NSJSONSerialization dataWithJSONObject:vpmsInfo
                                        options:NSJSONWritingPrettyPrinted
                                          error:nil];

    premiumArray = [NSMutableArray
        arrayWithObjects:
            // 0
            P_Total_Prem, P_Prem_Monthly, P_Prem_Quarterly, P_Prem_HalfYearly,
            P_Prem_Annually,
            // 5
            P_Basic_SA, P_Basic_PolTerm, P_Basic_PremTerm, P_Basic_Prem,
            // 9
            P_LTR_SA, P_LTR_PolTerm, P_LTR_PremTerm, P_LTR_Prem,
            // 13
            P_FIBR_SA, P_FIBR_PolTerm, P_FIBR_PremTerm, P_FIBR_Prem,
            // 17
            P_PWJ_SA, P_PWJ_PolTerm, P_PWJ_PremTerm, P_PWJ_Prem,
            // 21
            P_PWS_SA, P_PWS_PolTerm, P_PWS_PremTerm, P_PWS_Prem,
            // 25
            P_Version, P_ANB, P_OccClass, P_PolTerm, P_PremPaymentTerm,
            // 30
            P_MaturityAge, P_PremPayableMode, P_PO_ANB, P_PO_OccClass,
            P_Occ_Load,
            // 35
            P_PlanName, P_PlanType, P_O_LI_EoPolYr, P_O_LI_AnnPrem,
            P_O_LI_AccAnnPrem,
            // 40
            P_O_LI_DTPD_NA, P_O_LI_DTPD_A, P_O_LI_MaturityBen, P_O_LI_SurrVal,
            P_O_LI_SurrValonAcc,
            // 45
            P_O_LI_TotalPolVal, P_O_LI_AttainedAge, P_O_PO_EoPolYr,
            P_O_PO_AnnPrem, P_O_PO_AccAnnPrem,
            // 50
            P_O_PO_PW_DTPD, P_O_PO_FIBR, P_O_PO_AttainedAge,
            // v1.5 add-on
            P_PremMode_BasicPlan, P_PremMode_TotalPrem,
            // 55
            P_1EndofYear_Wording, P_2EndofYear_Wording, P_3EndofYear_Wording,
            P_4EndofYear_Wording, P_O_PerDiscount,
            // 60
            P_O_PremAfterDisc, P_EligibleRiders, P_IOS_OCC_Load,
            P_TotalPremium_IOS, P_TotalPremium_withOcc_IOS,
            // 65
            P_IOS_PWS_SA, P_IOS_PWJ_SA, P_IOS_Basic_OccExtra_MRate,
            P_IOS_LTR_OccExtra_MRate, P_IOS_FIB_OccExtra_MRate,
            // 70
            P_IOS_PWJ_OccExtra_MRate, P_IOS_PWS_OccExtra_MRate, P_O_LI_AccBonus,
            nil];

  } @catch (NSException *exception) {
    NSLog(@"Calculate Premium Error: %@ , length: %lu", exception.reason,
          sizeof premiumArray);
  } @finally {
    NSLog(@"Final Calculate Premium");
  }

  return premiumArray;
}

- (NSMutableArray *)getInputError:(NSString *)quotationDate
                         liGender:(NSString *)liGender
                            liDob:(NSString *)liDob
                     liOccupation:(NSString *)liOccupation
                 isLiMbbAccHolder:(NSString *)isLiMbbAccHolder
                        isLiStaff:(NSString *)isLiStaff
                       isLiSmoker:(NSString *)isLiSmoker
                 premiumFrequency:(NSString *)premiumFrequency
                           isLiPo:(NSString *)isLiPo
                         poGender:(NSString *)poGender
                            poDob:(NSString *)poDob
                     poOccupation:(NSString *)poOccupation
                       isPoSmoker:(NSString *)isPoSmoker
                    basicPlanName:(NSString *)basicPlanName
                          basicSA:(NSString *)basicSA
                        basicPlan:(NSString *)basicPlan
                          fibrIND:(NSString *)fibrIND
                           ltrIND:(NSString *)ltrIND
                            ltrSA:(NSString *)ltrSA
                           pwsIND:(NSString *)pwsIND
                           pwjIND:(NSString *)pwjIND {
  @try {
    [vpmsSession setvar:@"A_Quotation_Date" value:quotationDate];
    [vpmsSession setvar:@"A_Gender" value:liGender];
    [vpmsSession setvar:@"A_DOB" value:liDob];
    [vpmsSession setvar:@"A_Occupation" value:liOccupation];
    [vpmsSession setvar:@"A_MaybankAccHolder" value:isLiMbbAccHolder];
    [vpmsSession setvar:@"A_Staff" value:isLiStaff];
    [vpmsSession setvar:@"A_Smoker" value:isLiSmoker];
    [vpmsSession setvar:@"A_PremFrequency" value:premiumFrequency];
    [vpmsSession setvar:@"A_PO_IND" value:isLiPo];
    [vpmsSession setvar:@"A_PO_Gender" value:poGender];
    [vpmsSession setvar:@"A_PO_DOB" value:poDob];
    [vpmsSession setvar:@"A_PO_Occupation" value:poOccupation];
    [vpmsSession setvar:@"A_PO_Smoker" value:isPoSmoker];
    [vpmsSession setvar:@"A_Basic_Plan_Name" value:basicPlanName];
    [vpmsSession setvar:@"A_Basic_SA" value:basicSA];
    [vpmsSession setvar:@"A_Basic_Plan" value:basicPlan];
    [vpmsSession setvar:@"A_FIBR_IND" value:fibrIND];
    [vpmsSession setvar:@"A_LTR_IND" value:ltrIND];
    [vpmsSession setvar:@"A_LTR_SA"
                  value:ltrSA];  // LRT_SA have to pass in as input, but
                                 // actually is basicSA.
    [vpmsSession setvar:@"A_PWS_IND" value:pwsIND];
    [vpmsSession setvar:@"A_PWJ_IND" value:pwjIND];

    [vpmsSession compute:@"A_Quotation_Date" buf:vpmsBuffer];
    A_Quotation_Date = vpmsBuffer.message;

    [vpmsSession compute:@"A_Gender" buf:vpmsBuffer];
    A_Gender = vpmsBuffer.message;

    [vpmsSession compute:@"A_DOB" buf:vpmsBuffer];
    A_DOB = vpmsBuffer.message;

    [vpmsSession compute:@"A_Occupation" buf:vpmsBuffer];
    A_Occupation = vpmsBuffer.message;

    [vpmsSession compute:@"A_MaybankAccHolder" buf:vpmsBuffer];
    A_MaybankAccHolder = vpmsBuffer.message;

    [vpmsSession compute:@"A_Staff" buf:vpmsBuffer];
    A_Staff = vpmsBuffer.message;

    [vpmsSession compute:@"A_Smoker" buf:vpmsBuffer];
    A_Smoker = vpmsBuffer.message;

    [vpmsSession compute:@"A_PremFrequency" buf:vpmsBuffer];
    A_PremFrequency = vpmsBuffer.message;

    [vpmsSession compute:@"A_PO_IND" buf:vpmsBuffer];
    A_PO_IND = vpmsBuffer.message;

    [vpmsSession compute:@"A_PO_Gender" buf:vpmsBuffer];
    A_PO_Gender = vpmsBuffer.message;

    [vpmsSession compute:@"A_PO_DOB" buf:vpmsBuffer];
    A_PO_DOB = vpmsBuffer.message;

    [vpmsSession compute:@"A_PO_Occupation" buf:vpmsBuffer];
    A_PO_Occupation = vpmsBuffer.message;

    [vpmsSession compute:@"A_PO_Smoker" buf:vpmsBuffer];
    A_PO_Smoker = vpmsBuffer.message;

    [vpmsSession compute:@"A_Basic_Plan_Name" buf:vpmsBuffer];
    A_Basic_Plan_Name = vpmsBuffer.message;

    [vpmsSession compute:@"A_Basic_SA" buf:vpmsBuffer];
    A_Basic_SA = vpmsBuffer.message;

    [vpmsSession compute:@"A_Basic_Plan" buf:vpmsBuffer];
    A_Basic_Plan = vpmsBuffer.message;

    [vpmsSession compute:@"A_FIBR_IND" buf:vpmsBuffer];
    A_FIBR_IND = vpmsBuffer.message;

    [vpmsSession compute:@"A_LTR_IND" buf:vpmsBuffer];
    A_LTR_IND = vpmsBuffer.message;

    [vpmsSession compute:@"A_LTR_SA" buf:vpmsBuffer];
    A_LTR_SA = vpmsBuffer.message;

    [vpmsSession compute:@"A_PWS_IND" buf:vpmsBuffer];
    A_PWS_IND = vpmsBuffer.message;

    [vpmsSession compute:@"A_PWJ_IND" buf:vpmsBuffer];
    A_PWJ_IND = vpmsBuffer.message;

    errorArray = [NSMutableArray arrayWithObjects:
                                     // 0
                                     A_Quotation_Date,
                                     // 1
                                     A_Gender,
                                     // 2
                                     A_DOB,
                                     // 3
                                     A_Occupation,
                                     // 4
                                     A_MaybankAccHolder,
                                     // 5
                                     A_Staff,
                                     // 6
                                     A_Smoker,
                                     // 7
                                     A_PremFrequency,
                                     // 8
                                     A_PO_IND,
                                     // 9
                                     A_PO_Gender,
                                     // 10
                                     A_PO_DOB,
                                     // 11
                                     A_PO_Occupation,
                                     // 12
                                     A_PO_Smoker,
                                     // 13
                                     A_Basic_Plan_Name,
                                     // 14
                                     A_Basic_SA,
                                     // 15
                                     A_Basic_Plan,
                                     // 16
                                     A_FIBR_IND,
                                     // 17
                                     A_LTR_IND,
                                     // 18
                                     A_LTR_SA,
                                     // 19
                                     A_PWS_IND,
                                     // 20
                                     A_PWJ_IND, nil];

  } @catch (NSException *exception) {
    NSLog(@"getInputError Exception: %@ , length: %lu", exception.reason,
          sizeof errorArray);
  } @finally {
    NSLog(@"Final GetInputError");
  }

  return errorArray;
}

//  2020-06-24
- (NSMutableArray *)setInput:(NSString *)inputField
                  inputValue:(NSString *)inputValue

{
  NSString *result;
  NSString *message;
  NSString *field;
  NSMutableArray *endResult;

  @try {
    [vpmsSession setvar:inputField value:inputValue];

    [vpmsSession compute:inputField buf:vpmsBuffer];
    message = vpmsBuffer.message;
    result = vpmsBuffer.result;
    field = vpmsBuffer.field;

  } @catch (NSException *exception) {
    NSLog(@"Calculate Premium Error: %@ , length: %lu", exception.reason,
          sizeof result);
  } @finally {
    NSLog(@"End of setInput");
  }

  endResult = [NSMutableArray arrayWithObjects:message, field, result, nil];

  return endResult;
}

- (NSMutableArray *)setAnyway:(NSString *)inputField {
  NSString *result;
  NSString *message;
  NSString *field;
  NSMutableArray *endResult;

  @try {
    [vpmsSession compute:inputField buf:vpmsBuffer];
    message = vpmsBuffer.message;
    result = vpmsBuffer.result;
    field = vpmsBuffer.field;
  } @catch (NSException *exception) {
    NSLog(@"Compute Error: %@ , length: %lu", exception.reason, sizeof result);
  } @finally {
    NSLog(@"End of setInput");
  }

  endResult = [NSMutableArray arrayWithObjects:message, field, result, nil];

  return endResult;
}

// Not Using anymore because anyway need to call calculatePremium to get the
// Rider List.
- (NSString *)getVPMSVersion {
  [vpmsSession compute:@"P_Version" buf:vpmsBuffer];
  P_Version = vpmsBuffer.result;
  return P_Version;
}
@end

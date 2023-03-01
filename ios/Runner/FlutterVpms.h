//
//  FlutterVpms.h
//  Flutter
//
//  Created by TT Admin on 20/03/2019.
//

#ifndef Flutter_Vpms_h
#define Flutter_Vpms_h

#import <VpmsRuntime/Pmsapi.h>

//
// Flutter_Vpms_Buffer
//

// hold results from a call to a VP/MS Runtime function.
@interface FlutterVpmsBuffer : NSObject {
  int capacity;
  char *name;         // ASCII name parameter into the VP/MS Runtime
  char *res;          // ASCII result string from the VP/MS Runtime
  char *msg;          // ASCII message string from the VP/MS Runtime
  char *fld;          // ASCII field string from the VP/MS Runtime
  NSString *result;   // converted from res
  NSString *message;  // converted from msg
  NSString *field;    // converted from fld
  int rc;             // the return code from the function call
}
@property(readonly) int capacity;
@property(readonly) char *name;  // ASCII name parameter into the VP/MS Runtime
@property(readonly, nonatomic)
    char *res;  // ASCII result string from the VP/MS Runtime
@property(readonly, nonatomic)
    char *msg;  // ASCII message string from the VP/MS Runtime
@property(readonly, nonatomic)
    char *fld;  // ASCII field string from the VP/MS Runtime
@property(nonatomic, retain)
    NSString *result;  // ASCII field string from the VP/MS Runtime
@property(nonatomic, retain)
    NSString *message;  // ASCII field string from the VP/MS Runtime
@property(nonatomic, retain)
    NSString *field;  // ASCII field string from the VP/MS Runtime
@property int rc;
@end

@implementation FlutterVpmsBuffer
@synthesize capacity;
@synthesize name;  // ASCII name parameter into the VP/MS Runtime
@synthesize res;
@synthesize msg;
@synthesize fld;
@synthesize result;
@synthesize message;
@synthesize field;
@synthesize rc;

// Initialize the buffer to the empty state.
//
// NOTE: NSASCIIStringEncoding is generally not recommended.
// See for example: http://vgable.com/blog/tag/nsasciistringencoding/
// Instead of ASCII, perhaps use NSUTF8StringEncoding.
- (FlutterVpmsBuffer *)initWithCapacity:(int)newCapacity {
  capacity = newCapacity;
  name = (char *)malloc(capacity);
  res = (char *)malloc(capacity);
  msg = (char *)malloc(capacity);
  fld = (char *)malloc(capacity);
  result = NULL;
  message = NULL;
  field = NULL;
  rc = 0;
  return self;
}

// Clear the buffer contents.
//- (void)clear {
//    rc = 0;
//    name[0] = 0;
//    res[0] = 0;
//    msg[0] = 0;
//    fld[0] = 0;
//    if (result != NULL) {
//        [result release];
//    }
//    result = NULL;
//    if (message != NULL) {
//        [message release];
//    }
//    message = NULL;
//    if (field != NULL) {
//        [field release];
//    }
//    field = NULL;
//}

// Release resources.
//- (void)dealloc {
//    free(name);
//    free(res);
//    free(msg);
//    free(fld);
//    if (result != NULL) {
//        [result release];
//    }
//    result = NULL;
//    if (message != NULL) {
//        [message release];
//    }
//    message = NULL;
//    if (field != NULL) {
//        [field release];
//    }
//    field = NULL;
//    [super dealloc];
//}

@end  // FlutterVpmsBuffer

//
// FlutterVpmsChoiceBuffer
//

// buffer to hold choices from calls to VP/MS Runtime choice.
@interface FlutterVpmsChoiceBuffer : NSObject {
}
@property(retain, nonatomic) NSMutableArray *names;
@property(retain, nonatomic) NSMutableArray *values;
@end

@implementation FlutterVpmsChoiceBuffer
@synthesize names, values;

- (FlutterVpmsChoiceBuffer *)init {
  names = [[NSMutableArray alloc] init];
  values = [[NSMutableArray alloc] init];
  return self;
}

- (void)clear {
  [names removeAllObjects];
  [values removeAllObjects];
}

- (void)add:(FlutterVpmsBuffer *)buf {
  [names addObject:buf.message];
  [values addObject:buf.result];
}

@end

//
// FlutterVpmsSession
//

// VP/MS Runtime session
@interface FlutterVpmsSession : NSObject {
  int sessionid;
  int encoding;
}
@property(readonly) int sessionid;
@property(readonly) int encoding;
@end

@implementation FlutterVpmsSession
@synthesize sessionid;
@synthesize encoding;

- (FlutterVpmsSession *)init {
  sessionid = 0;
  encoding = NSASCIIStringEncoding;
  return self;
}

// Finds model in Bundle root directory and opens a new session.
- (int)loadsession:(NSString *)name {
  // find path of travel.vpm within the bundle
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                       NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString *filePath =
      [NSString stringWithFormat:@"%@/%@.vpm", documentsDirectory, name];

  const char *cFilepath = [filePath
      fileSystemRepresentation];  // released when filepath is released
  sessionid = loadsession(cFilepath);
  return sessionid;
}

// Close the session.
- (void)closesession {
  closesession(sessionid);
}

// Calls VP/MS Runtime setvar function.
- (int)setvar:(NSString *)name value:(NSString *)value {
  NSLog(@"setvar '%@' '%@'", name, value);
  const char *cName = [name cStringUsingEncoding:encoding];
  const char *cValue = [value cStringUsingEncoding:encoding];
  return setvar(sessionid, cName, cValue);
}

// Calls VP/MS Runtime compute function.
- (int)compute:(NSString *)name buf:(FlutterVpmsBuffer *)buf {
  NSLog(@"compute '%@'", name);
  // [buf clear];
  const char *cName = [name cStringUsingEncoding:NSASCIIStringEncoding];
  buf.rc = compute(sessionid, cName, buf.res, buf.capacity, buf.msg,
                   buf.capacity, buf.fld, buf.capacity);
  buf.result = [[NSString alloc] initWithBytes:buf.res
                                        length:strnlen(buf.res, buf.capacity)
                                      encoding:encoding];
  buf.message = [[NSString alloc] initWithBytes:buf.msg
                                         length:strnlen(buf.msg, buf.capacity)
                                       encoding:encoding];
  buf.field = [[NSString alloc] initWithBytes:buf.fld
                                       length:strnlen(buf.fld, buf.capacity)
                                     encoding:encoding];
  NSLog(@"return %d result '%@' message '%@' field '%@'", buf.rc, buf.result,
        buf.message, buf.field);
  return buf.rc;
}

// Loads all choices for a given name.
- (void)choices:(NSString *)name
            buf:(FlutterVpmsBuffer *)buf
           into:(FlutterVpmsChoiceBuffer *)values {
  [values clear];
  //[buf clear];
  for (int i = 0; i < 100; i++) {
    [self choice:name buf:buf];
    if (buf.rc != 1) break;
    [values add:buf];
  }
}

// Loads all choices for a given name.
- (void)choices:(NSString *)name
            buf:(FlutterVpmsBuffer *)buf
          names:(NSMutableArray *)names
         values:(NSMutableArray *)values {
  //[buf clear];
  NSLog(@"Loading Choices...");
  for (int i = 0; i < 100; i++) {
    [self choice:name buf:buf];
    if (buf.rc != 1) break;
    [names addObject:buf.message];
    [values addObject:buf.result];
  }
}

// Calls VP/MS Runtime choice function.
- (int)choice:(NSString *)name buf:(FlutterVpmsBuffer *)buf {
  NSLog(@"choice '%@'", name);
  //[buf clear];
  const char *cName = [name cStringUsingEncoding:encoding];
  buf.rc = choice(sessionid, cName, cName, buf.res, buf.capacity, buf.msg,
                  buf.capacity, buf.fld, buf.capacity);
  buf.result = [[NSString alloc] initWithBytes:buf.res
                                        length:strnlen(buf.res, buf.capacity)
                                      encoding:encoding];
  buf.message = [[NSString alloc] initWithBytes:buf.msg
                                         length:strnlen(buf.msg, buf.capacity)
                                       encoding:encoding];
  buf.field = [[NSString alloc] initWithBytes:buf.fld
                                       length:strnlen(buf.fld, buf.capacity)
                                     encoding:encoding];
  NSLog(@"return %d result '%@' message '%@' field '%@'", buf.rc, buf.result,
        buf.message, buf.field);
  return buf.rc;
}

@end

#endif

//
// var vpmsModule = require("com.isat.vpms64");
// var mySession = vpmsModule.createSession();
//
// exports.session = mySession;
// exports.hasError = false;
// exports.vpmsModel = "";
//
// exports.loadModel = function(model){
//    vpms.hasError = false;
//
//    if (mySession != null) {
//        mySession.Close();
//    }
//
//    mySession = null;
//    mySession = vpmsModule.createSession();
//    this.vpmsModel = model;
//    var syncName = "mastersync";
//    var dataDir = Ti.Filesystem.applicationDataDirectory;
//    var syncPath = dataDir + syncName;
//    var path = String.format("%s/%s", syncPath, model);
//    var f = Titanium.Filesystem.getFile(syncPath, model);
//    path = f.resolve();
//    var setOk = mySession.Load(path);
//
//};
//
// exports.setTable = function(table, rowCount){
//
//    var result = [];
//    table.forEach(function(column){
//        var str = vpms.get(column.varname);
//        var arr = vpms.splitValues(str);
//        var data = [];
//
//        if(rowCount == null)
//            rowCount = 30;
//
//        for(var i=0;i<rowCount;i++){
//            if(i < arr.length){
//                if(isNaN(arr[i]) == true){
//                    data.push(arr[i]);
//                }
//                else{
//                    data.push(helper.cur(Math.round(arr[i])));
//                }
//            }
//            else
//            {
//                data.push("");
//            }
//        }
//
//        var subtitle = null;
//        if(column.subTitle != null) subtitle = column.subTitle;
//
//        result.push({ title: column.title, data: data, subTitle: subtitle });
//    });
//    return result;
//};
//
//
// exports.setTableDecimalPlaces = function(table, rowCount){
//
//    var result = [];
//    table.forEach(function(column){
//        var str = vpms.get(column.varname);
//        var arr = vpms.splitValues(str);
//        var data = [];
//
//        if(rowCount == null)
//            rowCount = 30;
//
//        for(var i=0;i<rowCount;i++){
//            if(i < arr.length){
//                if(isNaN(arr[i]) == true){
//                    data.push(arr[i]);
//                }
//                else{
//                    data.push(helper.cur(arr[i]));
//                }
//            }
//            else
//            {
//                data.push("");
//            }
//        }
//
//        var subtitle = null;
//        if(column.subTitle != null) subtitle = column.subTitle;
//
//        result.push({ title: column.title, data: data, subTitle: subtitle });
//    });
//    return result;
//};
//
//
//
//
// exports.set = function(attr, value){
//    mySession.SetAttribute(attr, value);
//    saveToHistory(attr, value);
//};
//
// exports.vpmsDataTest = [];
//
// exports.setTest = function(attr, value){
//    saveToHistoryTest(attr, value);
//};
//
// function saveToHistoryTest(attr, value){
//    var spliceIndex = -1;
//    var spliceArr = [];
//
//    for(var i=0; i<vpms.vpmsDataTest.length; i++){
//        if(vpms.vpmsDataTest[i].a == attr){
//            spliceArr.push(i);
//        }
//    }
//
//    spliceArr.forEach(function(item){
//        vpms.vpmsDataTest.splice(item, 1);
//    });
//
//    vpms.vpmsDataTest.push({ a: attr, v: value });
//}
//
// exports.vpmsData = [];
//
// function saveToHistoryOld(attr, value){
//    var spliceIndex = -1;
//    for(var i=0; i<vpms.vpmsData.length; i++){
//        if(vpms.vpmsData[i].attr == attr){
//            spliceIndex = i;
//            break;
//        }
//    }
//    if(spliceIndex != -1){
//        vpms.vpmsData.splice(spliceIndex, 1);
//    }
//
//    vpms.vpmsData.push({ a: attr, v: value });
//}
//
// function saveToHistory(attr, value){
//    var spliceIndex = -1;
//    var spliceArr = [];
//
//    for(var i=0; i<vpms.vpmsData.length; i++){
//        if(vpms.vpmsData[i].a == attr){
//            spliceArr.push(i);
//        }
//    }
//
//    spliceArr.forEach(function(item){
//        vpms.vpmsData.splice(item, 1);
//    });
//
//    vpms.vpmsData.push({ a: attr, v: value });
//}
//
// exports.get = function(attr){
//    var returnObj = "";
//    if(vpms.hasError == false){
//        if(attr != ""){
//            var r = mySession.Compute(attr);
//            if(r.Message.trim() != ""){
//                alert(r.Message + " (VPMS Message) : " + attr);
//                vpms.hasError = true;
//                returnObj = "";
//            }
//            else{
//                returnObj = r.Result;
//            }
//        }
//    }
//    return returnObj;
//};
//
// exports.getAnyway = function(attr){
//    var objResult = null;
//    var r = mySession.Compute(attr);
//    if(r.Message.trim() != ""){
//        objResult = { msg: r.Message.trim() + " (VPMS Message) : " + attr,
//        value: "", field: r.Field };
//    }
//    else{
//        objResult = { msg: "", value: r.Result, field: r.Field };
//    }
//    return objResult;
//};
//
// exports.splitRiders = function(str, rowDelimiter, delimiter, relDelimiter,
// mandatoryItemDelimiter, exclusiveItemDelimiter){
//    var rowDelim = rowDelimiter || "#";
//    var relDelim = relDelimiter || "/";
//    var delim = delimiter || "|";
//    var mandatoryItemDelim = mandatoryItemDelim || ",";
//    var exclusiveItemDelim = exclusiveItemDelimiter || ",";
//    var arr = [];
//
//    var riders = str.split(rowDelim);
//
//    riders.forEach(function(rider){
//        var hasData = false;
//        var data = rider.split(relDelim);
//        var r = {};
//
//        r.code = "";
//        r.desc = "";
//        r.ind = "";
//        r.mandatory = [];
//        r.exclusive = [];
//
//        if(data.length > 0){
//            if(data[0].trim() != ""){
//                var p = data[0].split(delim);
//                r.code = p[0];
//                r.desc = p[1];
//                r.ind = p[2];
//
//                hasData = true;
//            }
//        }
//
//        if(data.length > 1){
//            data[1].split(mandatoryItemDelim).forEach(function(item){
//                if(item.trim() != "")
//                    r.mandatory.push(item);
//            });
//        }
//        if(data.length > 2){
//            data[2].split(exclusiveItemDelim).forEach(function(item){
//                if(item.trim() != "")
//                    r.exclusive.push(item);
//            });
//        }
//
//        if(hasData == true){
//            arr.push(r);
//        }
//    });
//
//    return arr;
//};
//
// exports.splitValues = function(str, delimiter){
//    var delim = delimiter || "|";
//    var arr = [];
//    var values = str.split(delim);
//
//    values.forEach(function(value){
//        arr.push(value);
//    });
//
//    return arr;
//};

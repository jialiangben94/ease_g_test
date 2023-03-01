#import "EtiqacryptoPlugin.h"
#import <CommonCrypto/CommonCryptor.h>

@implementation EtiqacryptoPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"com.etiqa.flutter.crypto"
            binaryMessenger:[registrar messenger]];
  EtiqacryptoPlugin* instance = [[EtiqacryptoPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"decryptHttpData" isEqualToString:call.method]) {

    NSDictionary *params =  call.arguments;
    NSString *decryptedData = [self decryptData:params[@"value"] withKey:params[@"secretkey"] withIV:params[@"iv"]];
    result(decryptedData);
  }if ([@"encryptStringAsBase64" isEqualToString:call.method]) {

    NSDictionary *params =  call.arguments;
    NSString *encryptedData = [self encryptStringAsBase64:params[@"value"] withKey:params[@"secretkey"] withIV:params[@"iv"]];
    result(encryptedData);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (NSData*)AES256 :(NSData*)inputData :(CCOperation)operation :(NSString*)key :(NSString*)iv {
    
//    NSData *data = [[NSData alloc] initWithBase64EncodedString:self options:0];
    // 'key' should be 32 bytes for AES256, will be null-padded otherwise
    char keyPtr[kCCKeySizeAES256 + 1]; // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    // fetch key data
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    char ivPtr[kCCBlockSizeAES128 + 1];
    bzero(ivPtr, sizeof(ivPtr));
    [iv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];

    NSUInteger dataLength = [inputData length];
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t bufferSize           = dataLength + kCCBlockSizeAES128;
    void* buffer                = malloc(bufferSize);

    size_t numBytesEncrypted    = 0;
    CCCryptorStatus cryptStatus = CCCrypt(operation, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          ivPtr /* initialization vector (optional) */,
                                          [inputData bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess)
    {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }

    free(buffer); //free the buffer;
    return nil;
}


- (NSString*) decryptData:(NSString*)ciphertext withKey:(NSString*)key withIV:(NSString*)iv {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:ciphertext options:0];
    NSData *decryptedData = [self AES256:data:kCCDecrypt:key:iv];
    
    return [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
}

- (NSString*) encryptStringAsBase64:(NSString*)plaintext withKey:(NSString*)key withIV:(NSString*)iv{
    NSData *data = [plaintext dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptedData2 = [self AES256:data:kCCEncrypt:key:iv];
    NSData* base64Data = [encryptedData2 base64EncodedDataWithOptions:0];
    return [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
}


@end

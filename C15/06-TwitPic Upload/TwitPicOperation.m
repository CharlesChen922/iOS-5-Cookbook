/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import "TwitPicOperation.h"

#define NOTIFY_AND_LEAVE(MESSAGE) {[self cleanup:MESSAGE]; return;}
#define DATA(STRING)	[STRING dataUsingEncoding:NSUTF8StringEncoding]
#define SAFE_PERFORM_WITH_ARG(THE_OBJECT, THE_SELECTOR, THE_ARG) (([THE_OBJECT respondsToSelector:THE_SELECTOR]) ? [THE_OBJECT performSelector:THE_SELECTOR withObject:THE_ARG] : nil)

#define HOST    @"twitpic.com"

// 一些關於POST的常數
#define IMAGE_CONTENT @"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\nContent-Type: image/jpeg\r\n\r\n"
#define STRING_CONTENT @"Content-Disposition: form-data; name=\"%@\"\r\n\r\n"
#define MULTIPART @"multipart/form-data; boundary=------------0x0x0x0x0x0x0x0x"

@implementation TwitPicOperation
@synthesize imageData, delegate;

- (void) cleanup: (NSString *) output
{
	self.imageData = nil;
    SAFE_PERFORM_WITH_ARG(delegate, @selector(doneTweeting:), output);
}

- (NSData*)generateFormDataFromPostDictionary:(NSDictionary*)dict
{
    id boundary = @"------------0x0x0x0x0x0x0x0x";
    NSArray* keys = [dict allKeys];
    NSMutableData* result = [NSMutableData data];
	
    for (int i = 0; i < [keys count]; i++) 
    {
        id value = [dict valueForKey: [keys objectAtIndex:i]];
        [result appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		
		if ([value isKindOfClass:[NSData class]]) 
		{
			// 處理圖像資料
			NSString *formstring = [NSString stringWithFormat:IMAGE_CONTENT, [keys objectAtIndex:i]];
			[result appendData: DATA(formstring)];
			[result appendData:value];
		}
		else 
		{
			// 假定所有非圖像的欄位都是字串
			NSString *formstring = [NSString stringWithFormat:STRING_CONTENT, [keys objectAtIndex:i]];
			[result appendData: DATA(formstring)];
			[result appendData:DATA(value)];
		}
		
		NSString *formstring = @"\r\n";
        [result appendData:DATA(formstring)];
    }
	
	NSString *formstring =[NSString stringWithFormat:@"--%@--\r\n", boundary];
    [result appendData:DATA(formstring)];
    return result;
}

- (void) main
{
	if (!self.imageData)
		NOTIFY_AND_LEAVE(@"ERROR: Please set image before uploading.");

    NSURLProtectionSpace *protectionSpace = [[NSURLProtectionSpace alloc] initWithHost:HOST port:0 protocol:@"http" realm:nil authenticationMethod:nil];
    
    NSURLCredential *credential = [[NSURLCredentialStorage sharedCredentialStorage] defaultCredentialForProtectionSpace:protectionSpace];
    if (!credential)
        NOTIFY_AND_LEAVE(@"ERROR: Credentials not set.")

    NSString *uname = credential.user;
    NSString *pword = credential.password;

	if (!uname || !pword || (!uname.length) || (!pword.length))
		NOTIFY_AND_LEAVE(@"ERROR: Please enter your account credentials in the settings before tweeting.");
	
	NSMutableDictionary* post_dict = [[NSMutableDictionary alloc] init];
	[post_dict setObject:uname forKey:@"username"];
	[post_dict setObject:pword forKey:@"password"];
	[post_dict setObject:@"Posted from iTweet" forKey:@"message"];
	[post_dict setObject:self.imageData forKey:@"media"];
	
	// 從post_dict字典，建立postData資料
	NSData *postData = [self generateFormDataFromPostDictionary:post_dict];
	
	// 建立URLRequest
    // 以upload而不是uploadAndPost，可跳過tweet
    NSString *baseurl = @"http://twitpic.com/api/upload"; 
    NSURL *url = [NSURL URLWithString:baseurl];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    if (!urlRequest) NOTIFY_AND_LEAVE(@"ERROR: Error creating the URL Request");
	
    [urlRequest setHTTPMethod: @"POST"];
	[urlRequest setValue:MULTIPART forHTTPHeaderField: @"Content-Type"];
    [urlRequest setHTTPBody:postData];
	
	// 送出以及取得結果
    NSError *error;
    NSURLResponse *response;
	NSLog(@"Contacting TwitPic....");
    NSData* result = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    if (!result)
	{
		[self cleanup:[NSString stringWithFormat:@"Submission error: %@", [error localizedFailureReason]]];
		return;
	}
	
	// 回傳結果
    NSString *outstring = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
	[self cleanup: outstring];
}

+ (id) operationWithDelegate: (id) delegate andPath: (NSString *) path
{
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (!data) return nil;
    
    TwitPicOperation *op = [[TwitPicOperation alloc] init];
    op.delegate = delegate;
    op.imageData = data;
    
    return op;
}
@end
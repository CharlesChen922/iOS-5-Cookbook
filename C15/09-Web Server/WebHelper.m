/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.0 Edition
 BSD License, Use at your own risk
 */

#import "WebHelper.h"
#import "UIDevice-Reachability.h"

#define SAFE_PERFORM_WITH_ARG(THE_OBJECT, THE_SELECTOR, THE_ARG) (([THE_OBJECT respondsToSelector:THE_SELECTOR]) ? [THE_OBJECT performSelector:THE_SELECTOR withObject:THE_ARG] : nil)

// 簡單的工具方法，顯示警示視圖
void showAlert(id formatstring,...)
{
	if (!formatstring) return;

	va_list arglist;
	va_start(arglist, formatstring);
	id outstring = [[NSString alloc] initWithFormat:formatstring arguments:arglist];
	va_end(arglist);
	
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:outstring message:nil delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil];
	[av show];
}

@implementation WebHelper
@synthesize isServing, chosenPort, delegate;

- (NSString *) getRequest: (int) fd
{
	static char buffer[BUFSIZE+1];
	int len = read(fd, buffer, BUFSIZE); 	
	buffer[len] = '\0';
	return [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
}

- (void) handleWebRequest: (int) fd
{
    UIImage *image = SAFE_PERFORM_WITH_ARG(delegate, @selector(image), nil);
    if (!image) return;
    
    NSString *outcontent = [NSString stringWithFormat:@"HTTP/1.0 200 OK\r\nContent-Type: image/jpeg\r\n\r\n"];
    write (fd, [outcontent UTF8String], outcontent.length);
    NSData *data = UIImageJPEGRepresentation(image, 0.75f);
    write (fd, data.bytes, data.length);
    close(fd);    
}

// 聆聽從外而來的請求
- (void) listenForRequests
{
    @autoreleasepool {
        static struct sockaddr_in cli_addr; 
        socklen_t length = sizeof(cli_addr);
        
        while (1 > 0) {
            if (!isServing) return;

            if ((socketfd = accept(listenfd, (struct sockaddr *)&cli_addr, &length)) < 0)
            {
                isServing = NO;
                [[NSOperationQueue mainQueue] addOperationWithBlock:^(){
                    SAFE_PERFORM_WITH_ARG(delegate, @selector(serviceWasLost), nil);                    
                }];
                return;
            }
            
            [self handleWebRequest:socketfd];
        }
    }
}

// 開始服務 -- 私用方法，由startService呼叫
- (void) startServer
{
	static struct	sockaddr_in serv_addr;
	
	// 設定socket
	if((listenfd = socket(AF_INET, SOCK_STREAM,0)) < 0)	
	{
		isServing = NO;
		SAFE_PERFORM_WITH_ARG(delegate, @selector(serviceCouldNotBeEstablished), nil);
		return;
	}
	
    // 以任意port埠號進行服務
	serv_addr.sin_family = AF_INET;
	serv_addr.sin_addr.s_addr = htonl(INADDR_ANY);
	serv_addr.sin_port = 0;
	
	// bind
	if(bind(listenfd, (struct sockaddr *)&serv_addr,sizeof(serv_addr)) <0)	
	{
		isServing = NO;
        SAFE_PERFORM_WITH_ARG(delegate, @selector(serviceCouldNotBeEstablished), nil);
		return;
	}
	
	// 查出系統選了哪個埠號
	int namelen = sizeof(serv_addr);
	if (getsockname(listenfd, (struct sockaddr *)&serv_addr, (void *) &namelen) < 0) {
		close(listenfd);
		isServing = NO;
        SAFE_PERFORM_WITH_ARG(delegate, @selector(serviceCouldNotBeEstablished), nil);
		return;
	}
	
	chosenPort = ntohs(serv_addr.sin_port);
	
	// listen
	if(listen(listenfd, 64) < 0)	
	{
		isServing = NO;
        SAFE_PERFORM_WITH_ARG(delegate, @selector(serviceCouldNotBeEstablished), nil);
		return;
	} 
	
    isServing = YES;
    [NSThread detachNewThreadSelector:@selector(listenForRequests) toTarget:self withObject:NULL];
    SAFE_PERFORM_WITH_ARG(delegate, @selector(serviceWasEstablished:), self);
}

+ (id) serviceWithDelegate:(id)delegate
{
	if (![[UIDevice currentDevice] networkAvailable])
	{
		showAlert(@"You are not connected to the network. Please do so before running this application.");
		return nil;
	}
    
    WebHelper *helper = [[WebHelper alloc] init];
    helper.delegate = delegate ;
    [helper startServer];
    return helper;
}	
@end

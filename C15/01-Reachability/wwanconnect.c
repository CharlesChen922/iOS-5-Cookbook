// Direct from Apple. Thank you Apple

#include "wwanconnect.h"
#include <CFNetwork/CFSocketStream.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <ifaddrs.h>
#include <stdio.h>

static Boolean TestGetIFAddrs(void);
static void MyCFWriteStreamClientCallBack(CFWriteStreamRef stream, CFStreamEventType type, void *clientCallBackInfo);
static void CleanupAfterWAAN(MyStreamInfoPtr myInfoPtr);
static void CloseStreams(MyStreamInfoPtr myInfoPtr);

static Boolean TestGetIFAddrs(void)
{
	int				result;
	struct  ifaddrs	*ifbase, *ifiterator;
	int				done = 0;
	Boolean			addrFound = FALSE;
	char			loopbackname[] = "lo0/0";
	
	result = getifaddrs(&ifbase);
	ifiterator = ifbase;
	while (!done && (ifiterator != NULL))
	{
		if (ifiterator->ifa_addr->sa_family == AF_INET)
		{
			if (memcmp(ifiterator->ifa_name, loopbackname, 3))
			{
				struct	sockaddr *saddr, *netmask, *daddr;
				saddr = ifiterator->ifa_addr;
				netmask = ifiterator->ifa_netmask;
				daddr = ifiterator->ifa_dstaddr;
				
				// 找到該IP位址的欄位
				struct sockaddr_in	*iaddr;
				char				addrstr[64];
				iaddr = (struct sockaddr_in *)saddr;
				inet_ntop(saddr->sa_family, &iaddr->sin_addr, addrstr, sizeof(addrstr));
				fprintf(stderr, "ipv4 interface name %s, source IP addr %s ", ifiterator->ifa_name, addrstr);
				
				iaddr = (struct sockaddr_in *)netmask;
				if (iaddr)
				{
					inet_ntop(saddr->sa_family, &iaddr->sin_addr, addrstr, sizeof(addrstr));
					fprintf(stderr, "netmask IP addr %s ", addrstr);
				}
				
				iaddr = (struct sockaddr_in *)daddr;
				if (iaddr)
				{
					inet_ntop(saddr->sa_family, &iaddr->sin_addr, addrstr, sizeof(addrstr));
					fprintf(stderr, "dest/broadcast IP addr %s.\n\n", addrstr);
				}
				return TRUE;
			}
			
		}
		else if (ifiterator->ifa_addr->sa_family == AF_INET6)
		{
			// 找到該IP位址的欄位
			struct sockaddr_in6	*iaddr6 = (struct sockaddr_in6 *)ifiterator->ifa_addr;
			char				addrstr[256];
			inet_ntop(ifiterator->ifa_addr->sa_family, iaddr6, addrstr, sizeof(addrstr));
			fprintf(stderr, "ipv6 interface name %s, source IP addr %s \n\n", ifiterator->ifa_name, addrstr);
		}
		ifiterator = ifiterator->ifa_next;
	}
	if (ifbase)
		freeifaddrs(ifbase);	/* getifaddrs配置的記憶體，使用完畢 */
	
    return addrFound;
}

static void MyCFWriteStreamClientCallBack(CFWriteStreamRef stream, CFStreamEventType type, void *clientCallBackInfo)
{
	MyStreamInfoPtr	myInfoPtr = (MyStreamInfoPtr) clientCallBackInfo;
	
	printf("MyCFWriteStreamClientCallBack entered - event is %d\n", (int) type);
	
	switch (type)
	{
		case kCFStreamEventOpenCompleted:
			myInfoPtr->isConnected = TRUE;
			TestGetIFAddrs();		// 呼叫測試方法，回傳本地端與此網路連線關連在一起的IP位址
			if (myInfoPtr->clientCB)
			{
				// 呼叫客戶端的回呼函式
				myInfoPtr->clientCB(myInfoPtr->refCon);
			}
			printf("write stream connected\n");
			break;
			
		case kCFStreamEventErrorOccurred:
			myInfoPtr->errorOccurred = TRUE;
			myInfoPtr->error = CFWriteStreamGetError(myInfoPtr->wStreamRef);
			printf("write stream error %d .. giving up\n", (int) myInfoPtr->error.error);
			break;
			
		default:
			printf("event occurred\n"); // ??
			break;
	}
	// 在此處停止run loop
	CFRunLoopStop(CFRunLoopGetCurrent());
}

extern MyInfoRef StartWWAN(ConnectClientCallBack clientCB, void *refCon)
{ 
	char						host[] = kTestHost;
	int							portNum = kTestPort;
	CFDataRef					addressData;
	MyStreamInfoPtr				myInfoPtr;
	CFStreamClientContext		ctxt = {0, NULL, NULL, NULL, NULL};
	Boolean						errorOccurred = FALSE;
	
	myInfoPtr = malloc(sizeof(MyStreamInfo));
	if (!myInfoPtr)
	{
		return NULL;
	}
	
	// 初始配置記憶體
	memset(myInfoPtr, 0, sizeof(MyStreamInfo));
	myInfoPtr->clientCB = clientCB;
	myInfoPtr->refCon = refCon;	
	ctxt.info = myInfoPtr;
	
	// 檢查有四個句點的位址，如果有，不進行名稱查詢
	in_addr_t addr = inet_addr(host); 
	if (addr != INADDR_NONE) { 
		// 從數字型的主機名稱建立CFStream
		struct sockaddr_in sin; 
		memset(&sin, 0, sizeof(sin)); 
		
		sin.sin_len= sizeof(sin); 
		sin.sin_family = AF_INET; 
		sin.sin_addr.s_addr = addr; 
		sin.sin_port = htons(portNum); 
		
		addressData = CFDataCreate(NULL, (UInt8 *)&sin, sizeof(sin)); 
		CFSocketSignature sig = { AF_INET, SOCK_STREAM, IPPROTO_TCP, addressData }; 
		
		// 建立CFStream
		CFStreamCreatePairWithPeerSocketSignature(kCFAllocatorDefault, &sig, &(myInfoPtr->rStreamRef), &(myInfoPtr->wStreamRef)); 		
		CFRelease(addressData); 
	} else { 
		// 從ascii的主機名稱建立CFStream
		CFStringRef hostStr = CFStringCreateWithCStringNoCopy(kCFAllocatorDefault, host, kCFStringEncodingUTF8, kCFAllocatorNull); 
		CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, hostStr, portNum, &(myInfoPtr->rStreamRef), &(myInfoPtr->wStreamRef)); 
	} 
	
	myInfoPtr->isConnected = FALSE;
	myInfoPtr->isStreamInitd = TRUE;
	myInfoPtr->isClientSet = FALSE;
	
	// 告知CFStream，結束時要關閉socket
	// 這也會影響寫入的CFStream，因為這一對共享同一個socket
	CFWriteStreamSetProperty(myInfoPtr->wStreamRef, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue); 
	
	// 設定客戶端
	if (!CFWriteStreamSetClient(myInfoPtr->wStreamRef, kCFStreamEventOpenCompleted | kCFStreamEventErrorOccurred | kCFStreamEventEndEncountered, 
								MyCFWriteStreamClientCallBack, &ctxt))
	{
		printf("CFWriteStreamSetClient failed\n");
		errorOccurred = TRUE;
	}
	else
		myInfoPtr->isClientSet = TRUE;
	
	if (!errorOccurred)
	{
		// 排程
		CFWriteStreamScheduleWithRunLoop(myInfoPtr->wStreamRef, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
		
		// 試著開啟
		if (!CFWriteStreamOpen(myInfoPtr->wStreamRef))
		{
			printf("CFWriteStreamOpen failed\n");
			errorOccurred = TRUE;
		}
	}
	
	if (!errorOccurred)
	{
		// 到目前為止沒有問題，所以執行run loop，當回呼函式被呼叫時，它會停止run loop
		printf("CFWriteStreamOpen returned with no error - calling CFRunLoopRun\n");
		CFRunLoopRun();
		if (myInfoPtr->errorOccurred)
			errorOccurred = TRUE;
		printf("after CFRunLoopRun - returning\n");
	}
	
	if (errorOccurred)
	{
		myInfoPtr->isConnected = FALSE;
		CleanupAfterWAAN(myInfoPtr);
		CloseStreams(myInfoPtr);
		
		if (myInfoPtr->isStreamInitd)
		{
			CFRelease(myInfoPtr->rStreamRef);
			CFRelease(myInfoPtr->wStreamRef);
			myInfoPtr->isStreamInitd = FALSE;
		}
		free(myInfoPtr);
		return NULL;
	}
	return (MyInfoRef)myInfoPtr;
} 

static void CleanupAfterWAAN(MyStreamInfoPtr myInfoPtr)
{
	assert(myInfoPtr != NULL);
	if (myInfoPtr->isClientSet)
	{
		CFWriteStreamSetClient(myInfoPtr->wStreamRef, 0, NULL, NULL);
		CFWriteStreamUnscheduleFromRunLoop(myInfoPtr->wStreamRef, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
		myInfoPtr->isClientSet = FALSE;
	}
}

static void CloseStreams(MyStreamInfoPtr myInfoPtr)
{
	assert(myInfoPtr != NULL);
	if (myInfoPtr->rStreamRef)
	{
		CFReadStreamClose(myInfoPtr->rStreamRef);
		myInfoPtr->rStreamRef = NULL;
	}
	if (myInfoPtr->wStreamRef)
	{
		CFWriteStreamClose(myInfoPtr->wStreamRef);
		myInfoPtr->wStreamRef = NULL;
	}
}

extern void StopWWAN(MyInfoRef infoRef)
{
	MyStreamInfoPtr myInfoPtr = (MyStreamInfoPtr)infoRef;
	
	printf("stopWWAN entered\n");
	assert(myInfoPtr != NULL);
	myInfoPtr->isConnected = FALSE;
	CleanupAfterWAAN(myInfoPtr);
	CloseStreams(myInfoPtr);
	free(myInfoPtr);
}

// 從Apple範例程式碼抄來的，謝謝你Apple。

#if !defined(__WWAN_CONNECT__)
#define __WWAN_CONNECT__	1

#include <CoreFoundation/CoreFoundation.h>
#include <assert.h>

#define kTestHost	"www.whatismyip.com"
#define kTestPort	80		

typedef void (*ConnectClientCallBack)(void *refCon);


struct MyStreamInfoStruct{
	CFWriteStreamRef		wStreamRef;
	CFReadStreamRef			rStreamRef;
	ConnectClientCallBack	clientCB;
	void					*refCon;
	CFStreamError			error;
	Boolean					errorOccurred;
	Boolean					isConnected;
	Boolean					isStreamInitd;
	Boolean					isClientSet;
};

typedef struct MyStreamInfoStruct MyStreamInfo;
typedef struct MyStreamInfoStruct *MyStreamInfoPtr;
typedef struct __MyInfoRef *MyInfoRef;

/*
 *  StartWWAN()
 *  
 *  Discussion:
 *    這個函式，以CFSocketStream API，開啟Wireless Wide Area Network (WWAN)連線，
 *     與上頭kTestHost:kTestPort定義的伺服器系統連線，
 *     在CFSocketStream連線上，並不會發生任何的資料溝通。
 *  
 *    clientCB:
 *     開啟連線後，這代表會被呼叫的回呼函式，如果不是NULL的話。
 *     函式的定義請見上頭的ConnectClientCallBack。
 *     
 *    refCon:
 *     如果clientCB與refCon有定義的話，
 *     呼叫回呼函式時，會傳入這個refCon當參數。
 *
 *    return:
 *     如果WWAN連線成功了，回傳MyInfoRef。
 *     這個MyInfoRef，必須傳入StopWWAN，以關閉WWAN連線。
 *     若回傳NULL，代表連線失敗。
 *    
 */
extern MyInfoRef StartWWAN(ConnectClientCallBack clientCB, void *refCon);

/*
 *  StopWWAN()
 *  
 *  Discussion:
 *    這個函式會關閉當初用來開啟WWAN連線的CFSocketStream，
 *    一旦WWAN開始連線，就可以使用BSD的網路函式，在WWAN連線上進行溝通。
 *    當我撰寫此範例時，只使用BSD socket API的話，
 *    並不能保證WWAN會一直處於連線狀態。
 *  
 *    infoRef:
 *     傳入從StartWWAN得來的MyInfoRef。
 *     
 */

extern void StopWWAN(MyInfoRef infoRef);

#endif // __WWAN_CONNECT__
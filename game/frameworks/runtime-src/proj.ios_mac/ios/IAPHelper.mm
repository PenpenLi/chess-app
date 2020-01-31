//
//  IAPHelper.cpp
//  majo
//
//  Created by 李 丁 on 14-7-23.
//
//

#include "IAPHelper.h"
#include "cocos2d.h"
#include "../../Classes/SDK/SPlatform.h"
#include "../../Classes/SDK/SInstance.h"
#include "../../Classes/CallLuaFunction.h"

using namespace SDK;

@implementation IAPHelper

static IAPHelper *sharedIAPHelper = nil;

+(IAPHelper*) sharedIAPHelper
{
    if (sharedIAPHelper == nil)
    {
        sharedIAPHelper = [[IAPHelper alloc] init];
    }
    return sharedIAPHelper;
}

-(id)init
{
    if ((self = [super init]))
    {
        //监听购买结果 一定要打开
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        alert = [UIAlertView alloc];
    }
    return self;
}

-(void)buy:(string)type flag:(int)isSandBox buyItemID:(int)itemID buyPrice:(int)price buyInfo:(string)playerid ip:(string)httpServerIP port:(int)httpServerPort page:(string)httpServerPage
{
    if ([SKPaymentQueue canMakePayments])
    {
        // 测试代码
//        INSTANCE(CallLuaFunction)->SendIOSPayResult("mildstudio.majo.6", "strPayTran");

        
        _isSandBox = isSandBox;
        _httpServerIP = httpServerIP;
        _httpServerPort = httpServerPort;
        _httpServerPage = httpServerPage;
        _privateInfo = playerid;
        
//        if (transList.size() > 0)
//        {
//            [self ShowCloseAlertView:"Alert" showMessage:"需要恢复购买！"];
//            return;
//        }
        if ([self CheckIshaveUnFinishItem:type isInsert:true] == true)
        {
            [self ShowCloseAlertView:"Alert" showMessage:"该商品还未完成交易！"];
            return;
        }
        
        [self RequestProductData:type];
        CCLOG("允许程序内付费购买");
    }
    else
    {
        CCLOG("不允许程序内付费购买");
        [self ShowCloseAlertView:"Alert" showMessage:"您没有允许程序内付费购买！"];
    }

}

-(void)resumBuy:(string)type flag:(int)isSandBox buyInfo:(string)privateInfo ip:(string)httpServerIP port:(int)httpServerPort page:(string)httpServerPage
{
    _isSandBox = isSandBox;
    _httpServerIP = httpServerIP;
    _httpServerPort = httpServerPort;
    _httpServerPage = httpServerPage;
    _privateInfo = privateInfo;
    [self ShowCloseAlertView:"Alert" showMessage:"需要恢复购买！"];
}

-(bool)CanMakePay
{
    return [SKPaymentQueue canMakePayments];
}

-(void)RequestProductData:(string)strBuyID
{
    CCLOG("---------请求对应的产品信息------------");
    CCLOG("%s",strBuyID.c_str());
    NSArray *product = nil;
    product=[[NSArray alloc] initWithObjects:@(strBuyID.c_str()),nil];
    
    NSSet *nsset = [NSSet setWithArray:product];
    SKProductsRequest *request=[[SKProductsRequest alloc] initWithProductIdentifiers: nsset];
    request.delegate=self;
    [request start];
    [product release];
    
    // 提示等候
    [self ShowCloseAlertView:"" showMessage:"正在查询商品 请稍等！"];
}
//<SKProductsRequestDelegate> 请求协议
//收到的产品信息
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    
    NSLog(@"-----------收到产品反馈信息--------------");
    // 有效
    NSArray *myProduct = response.products;
    NSLog(@"产品Product ID:%@",response.invalidProductIdentifiers);
    NSLog(@"产品付费数量: %ld",[myProduct count]);
    if ([myProduct count] <= 0)
    {
        NSLog(@"-----------收到产品的付费数量不正确--------------");
        [self ShowCloseAlertView:"Alert" showMessage:"Failed to get product information!"];
        return;
    }
    // populate UI
    for(SKProduct *product in myProduct)
    {
        NSLog(@"product info");
        NSLog(@"SKProduct 描述信息%@", [product description]);
        NSLog(@"产品标题 %@" , product.localizedTitle);
        NSLog(@"产品描述信息: %@" , product.localizedDescription);
        NSLog(@"价格: %@" , product.price);
        NSLog(@"Product id: %@" , product.productIdentifier);
        
        _transID = [product.productIdentifier UTF8String];
    }
    SKPayment *payment = nil;
    SKProduct *product = nil;
    
    product = [myProduct objectAtIndex:0];
    
    payment  = [SKPayment paymentWithProduct:product];
    CCLOG("---------发送购买请求------------");
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    [request autorelease];
    // 提示等候
    [self ShowCloseAlertView:"" showMessage:"请稍等！"];
    
}
- (void)requestProUpgradeProductData
{
    CCLOG("------请求升级数据---------");
    NSSet *productIdentifiers = [NSSet setWithObject:@"com.productid"];
    SKProductsRequest* productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];
}
//弹出错误信息
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    CCLOG("-------弹出错误信息----------");
    
    [self ShowCloseAlertView:"Alert" showMessage:[[error localizedDescription] UTF8String]];
}

-(void) requestDidFinish:(SKRequest *)request
{
    NSLog(@"----------反馈信息结束--------------");
    
}

-(void) PurchasedTransaction: (SKPaymentTransaction *)transaction
{
    CCLOG("-----PurchasedTransaction----");
    NSArray *transactions =[[NSArray alloc] initWithObjects:transaction, nil];
    [self paymentQueue:[SKPaymentQueue defaultQueue] updatedTransactions:transactions];
    [transactions release];
}

//<SKPaymentTransactionObserver> 千万不要忘记绑定，代码如下：
//----监听购买结果
//[[SKPaymentQueue defaultQueue] addTransactionObserver:self];

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions//交易结果
{
    CCLOG("-----paymentQueue--------");
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased://交易完成
            {
                [self ShowCloseAlertView:"Alert" showMessage:"验证中！"];
                //[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                string itemStr = [transaction.payment.productIdentifier UTF8String];
                [self CheckIshaveUnFinishItem:itemStr isInsert:true];
                [self completeTransaction:transaction];
                NSLog(@"-----交易完成 --------");
                break;
            }
            case SKPaymentTransactionStateFailed://交易失败
            {
                [self failedTransaction:transaction];
                NSLog(@"%@", [transaction.error localizedDescription]);
                CCLOG("-----交易失败 --------");
                string itemStr = [transaction.payment.productIdentifier UTF8String];
                [self DelUnFinishItem:itemStr];
                [self ShowCloseAlertView:"Alert" showMessage:"购买失败！"];
                break;
            }
            case SKPaymentTransactionStateRestored://已经购买过该商品
                [self restoreTransaction:transaction];
                NSLog(@"-----已经购买过该商品 --------");
            case SKPaymentTransactionStatePurchasing:      //商品添加进列表
                NSLog(@"-----商品添加进列表 --------");
                break;
            default:
                break;
        }
    }
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction
{
    CCLOG("-----completeTransaction--------");
    // 交易完成 该扣就扣 该加就加
    NSString *product = transaction.payment.productIdentifier;
    NSLog(@"产品交易完成 ID:%@",transaction.payment.productIdentifier);
    
    // 购买的id
    string strProID = [transaction.payment.productIdentifier UTF8String];
    
    if ([product length] > 0)
    {
        NSArray *tt = [product componentsSeparatedByString:@"."];
        NSString *bookid = [tt lastObject];
        if ([bookid length] > 0)
        {
            [self recordTransaction:bookid];
            [self provideContent:bookid];
        }
        
        // Client验证
//        // 接受到的App Store验证字符串，这里需要经过JSON编码
//        NSString* ObjectString = [self encode:(uint8_t *)transaction.transactionReceipt.bytes length:transaction.transactionReceipt.length];
//        NSString* sendString = [[NSString alloc] initWithFormat:@"{\"receipt-data\":\"%@\"}",ObjectString ];
//        
//        // https://buy.itunes.apple.com/verifyReceipt
//        // https://sandbox.itunes.apple.com/verifyReceipt
//        string urlStr = "";
//        if (_isSandBox == 1)
//            urlStr = "https://sandbox.itunes.apple.com/verifyReceipt";
//        else
//            urlStr = "https://buy.itunes.apple.com/verifyReceipt";
//        
//        NSURL *sandboxStoreURL = [[NSURL alloc] initWithString: @(urlStr.c_str())];
//        NSData *postData = [NSData dataWithBytes:[sendString UTF8String] length:[sendString length]];
//        NSMutableURLRequest *connectionRequest = [NSMutableURLRequest requestWithURL:sandboxStoreURL];
//        [connectionRequest setHTTPMethod:@"POST"];
//        [connectionRequest setTimeoutInterval:120.0];
//        [connectionRequest setCachePolicy:NSURLRequestUseProtocolCachePolicy];
//        [connectionRequest setHTTPBody:postData];
////        [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
//        
//        NSURLConnection *connection = [[NSURLConnection alloc]
//                                       initWithRequest:connectionRequest
//                                       delegate:self];
//        [connection release];
        
        
        // 发送到fwq验证
        [self SendReceiptToFWQ:transaction PayID:strProID];
        
        //        // 提示
        //        int nPay = [self GetProductId:transaction.payment.productIdentifier];
        //        if (nPay > IAP0 && nPay < IAPMax)
        //        {
        //            [self ShowTransactionTips:nPay];
        //        }
        //        // 完成交易（该版本暂时直接完成交易）
        //        [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    }
    
    // Remove the transaction from the payment queue.
    //    // 不完成交易 由服务器验证后驱动完成
    //    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}

// 发送商品购买收据到fwq验证
-(void)SendReceiptToFWQ:(SKPaymentTransaction *)transaction PayID:(string)strPayID
{
    // 保存交易
    if ([self PushPaymentTransaction:transaction])
    {
        // 0402 comment by pk begin
        NSString* ObjectString = [self encode:(uint8_t *)transaction.transactionReceipt.bytes length:transaction.transactionReceipt.length];
        string receiptStr = [ObjectString UTF8String];
        int nLen = receiptStr.length();
        string strProID = [transaction.payment.productIdentifier UTF8String];
        INSTANCE(CallLuaFunction)->SenIOSBuyToServer(receiptStr, strProID,_privateInfo);
        // 0402 comment by pk begin
//        // 验证信息 发送到fwq进行验证
//        NSData *pReceipt = transaction.transactionReceipt;  // 收据
//        int nDataLen =[pReceipt length];
//        
//        void *pRecData = malloc(nDataLen);                  // 收据的数据
//        [pReceipt getBytes:pRecData];
        
//        // 通知fwq购买成功
//        INSTANCE(CallLuaFunction)->SendIOSPayResult(strPayID, strPayID);
        
//        SPacker objPck;                                     // 复合包
//        objPck.SetProNumber(CS_SHOP_P);
//        
//        CS_SHOP objGoods;                                   // 商品信息
//        objGoods.emPaymentPlatform = PAYMENT_PLATFORM_APPLE;
//        objGoods.nGoodsID = nPayID;
//        objGoods.nVerifyLength = nDataLen;
//        objPck.Push(&objGoods, sizeof(objGoods));
//        objPck.Push(pRecData , nDataLen);
//        objPck.SetProNumber(CS_SHOP_P);
//        INSTANCE(CClient)->Send(objPck);
        
//        free(pRecData);
    }
    else
    {
        [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    }
}

// 发送所有未完成的交易到FWQ验证
-(void) SendAllReceiptToFWQ
{
    if (transList.size() > 0)
    {
        for (list<SKPaymentTransaction*>::iterator itr = transList.begin(); itr != transList.end(); itr++)
        {
            // comment by pk 0402 begin
//            NSData *pitrReceipt = (*itr).transactionReceipt;  // 收据
//            NSString *itrreceiptStr = [[NSString alloc] initWithBytes:[pitrReceipt bytes] length:[pitrReceipt length] encoding:(NSUTF8StringEncoding)];
//            string receiptStr = [itrreceiptStr UTF8String];
//            NSString *product = (*itr).payment.productIdentifier;
//            string strProID = [product UTF8String];
//            INSTANCE(CallLuaFunction)->SenIOSBuyToServer(receiptStr, strProID,_privateInfo);
//            [itrreceiptStr release];
            // comment by pk 0402 end
        
//            NSString *product = (*itr).payment.productIdentifier;
//            // 购买的id
//            string strProID = [product UTF8String];
//            // 验证信息 发送到fwq进行验证
//            NSData *pReceipt = (*itr).transactionReceipt;  // 收据
//            int nDataLen =[pReceipt length];
//            
//            void *pRecData = malloc(nDataLen);                  // 收据的数据
//            [pReceipt getBytes:pRecData];
            
//            SPacker objPck;                                     // 复合包
//            objPck.SetProNumber(CS_SHOP_P);
//            
//            CS_SHOP objGoods;                                   // 商品信息
//            objGoods.emPaymentPlatform = PAYMENT_PLATFORM_APPLE;
//            objGoods.nGoodsID = nProID;
//            objGoods.nVerifyLength = nDataLen;
//            objPck.Push(&objGoods, sizeof(objGoods));
//            objPck.Push(pRecData , nDataLen);
//            objPck.SetProNumber(CS_SHOP_P);
//            INSTANCE(CClient)->Send(objPck);
            
//            free(pRecData);
        }
    }
}

// 完成交易 fwq驱动
-(bool)CompleteSeverTransaction:(string)strPayID
{
    [self DelUnFinishItem:strPayID];
    
    NSLog(@"交易完成,删除订单号:%s",  strPayID.c_str());
    if (transList.size() > 0)
    {
        // 判断商品ID 用于完成购买 由于同一件商品不能同时购买2件以上，所以链表中只会有一个同类商品
        for (list<SKPaymentTransaction*>::iterator itr = transList.begin(); itr != transList.end(); itr++)
        {
            string strPay = [(*itr).payment.productIdentifier UTF8String];
            if (strcmp(strPay.c_str(), strPayID.c_str()) == 0)
            {
                // 完成交易
                [[SKPaymentQueue defaultQueue] finishTransaction: (*itr)];
                // 提示
                [self ShowTransactionTips:strPay];
                // 删除交易
                transList.erase(itr);
                return true;
            }
        }
    }
    return false;
}

// 记录交易 准备由fwq来完成交易
-(bool)PushPaymentTransaction:(SKPaymentTransaction *)transaction
{
//    if (transList.size() > 0)
//    {// 检测商品是否重复
//        for (list<SKPaymentTransaction*>::iterator itr = transList.begin(); itr != transList.end(); itr++)
//        {
//            NSData *pReceipt = transaction.transactionReceipt;  // 收据
//            NSString *receiptStr = [[NSString alloc] initWithBytes:[pReceipt bytes] length:[pReceipt length] encoding:(NSUTF8StringEncoding)];
//            
//            NSData *pitrReceipt = (*itr).transactionReceipt;  // 收据
//            NSString *itrreceiptStr = [[NSString alloc] initWithBytes:[pitrReceipt bytes] length:[pitrReceipt length] encoding:(NSUTF8StringEncoding)];
//            
//            if (strcmp([itrreceiptStr UTF8String], [receiptStr UTF8String]) == 0)
//            {
////                [self ShowCloseAlertView:"Alert" showMessage:"商品重复购买！"];
//                [receiptStr release];
//                [itrreceiptStr release];
//                return false;
//            }
//            
//            [receiptStr release];
//            [itrreceiptStr release];
//        }
//    }
    
    transList.push_back(transaction);
    return true;
    
    //    // 测试代码
    //    NSData *pReceipt = transaction.transactionReceipt;  // 收据
    //    int nDataLen =[pReceipt length];
    //    void *pRecData = malloc(nDataLen);         // 收据的数据
    //    [pReceipt getBytes:pRecData];
    //    NSString *receiptStr = [[NSString alloc] initWithBytes:pRecData length:nDataLen encoding:(NSUTF8StringEncoding)];
    //    [self ShowCloseAlertView:"transstr" showMessage:[receiptStr UTF8String]];
}

-(bool)CheckIshaveUnFinishItem:(string)itemStr isInsert:(bool)insert
{
    if (payItemStrList.size() > 0)
    {
        for (list<string>::iterator itr = payItemStrList.begin(); itr != payItemStrList.end(); itr++)
        {
            string strPay = (*itr);
            if (strcmp(strPay.c_str(), itemStr.c_str()) == 0)
            {
                return true;
            }
        }
    }
    if (insert)
    {
        payItemStrList.push_back(itemStr);
    }
    
    return false;
}

-(void)DelUnFinishItem:(string)itemStr
{
    if (payItemStrList.size() > 0)
    {
        for (list<string>::iterator itr = payItemStrList.begin(); itr != payItemStrList.end(); itr++)
        {
            string strPay = (*itr);
            if (strcmp(strPay.c_str(), itemStr.c_str()) == 0)
            {
                payItemStrList.erase(itr);
                break;
            }
        }
    }
}

// 显示交易成功后的提示
-(void)ShowTransactionTips:(string)strPayID
{
    [self ShowCloseAlertView:"Success" showMessage:"购买成功"];
}

// 显示带关闭的alertview
-(void)ShowCloseAlertView:(const char *)title showMessage:(const char *)message
{
    [alert dismissWithClickedButtonIndex:0 animated:NO];
    [alert release];
    
    NSString *titleStr = [[NSString alloc] initWithCString:title encoding:(NSUTF8StringEncoding)];
    NSString *messageStr =[[NSString alloc] initWithCString:message encoding:(NSUTF8StringEncoding)];
    alert = [[UIAlertView alloc] initWithTitle:titleStr message:messageStr delegate:nil cancelButtonTitle:NSLocalizedString(@"Close",nil) otherButtonTitles:nil];
    
    [alert show];
    [titleStr release];
    [messageStr release];
}

// 显示不带关闭的alertview
//-(void)ShowAlertView:(const char *)title showMessage:(const char *)message
//{
//    NSString *titleStr = [[NSString alloc] initWithCString:title encoding:(NSUTF8StringEncoding)];
//    NSString *messageStr =[[NSString alloc] initWithCString:message encoding:(NSUTF8StringEncoding)];
//    UIAlertView *alercomplete =  [[UIAlertView alloc] initWithTitle:titleStr
//                                                            message:messageStr
//                                                           delegate:nil cancelButtonTitle:nil
//                                                            otherButtonTitles:nil];
//
//    [alercomplete show];
//    [alercomplete release];
//    [titleStr release];
//    [messageStr release];
//}

//记录交易
-(void)recordTransaction:(NSString *)product
{
    CCLOG("-----记录交易--------");
}

//处理下载内容
-(void)provideContent:(NSString *)product
{
    CCLOG("-----下载--------");
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"失败");
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    
}
-(void) paymentQueueRestoreCompletedTransactionsFinished: (SKPaymentTransaction *)transaction
{
    
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@" 交易恢复处理");
    [self ShowCloseAlertView:"payment" showMessage:"restore"];
}

-(void) paymentQueue:(SKPaymentQueue *) paymentQueue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    CCLOG("-------paymentQueue----");
}


#pragma mark connection delegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSString *receiveString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    NSLog(@"%@",  receiveString);
    
    if ([self CompleteSeverTransaction:_transID])
    {
        string buffer = [receiveString UTF8String];
        string state = [self GetJsonValue:buffer.c_str() key:"status"];
        if (strcmp(state.c_str(), "0") == 0)
        {
            string transaction_id = [self GetJsonValue:buffer.c_str() key:"transaction_id"];
            CCLOG("------%s",transaction_id.c_str());
            // 通知fwq购买成功
            INSTANCE(CallLuaFunction)->SendIOSPayResult(_transID, transaction_id);
        }
    }
    
    
    
    //NSData* xmlData = [@"testdata" dataUsingEncoding:NSUTF8StringEncoding];
    
//    INSTANCE(CallLuaFunction)->SendIOSPayResult(strPayID, strPayID);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    switch([(NSHTTPURLResponse *)response statusCode])
    {
        case 200:
        case 206:
            break;
        case 304:
            break;
        case 400:
            break;
        case 404:
            break;
        case 416:
            break;
        case 403:
            break;
        case 401:
        case 500:
            break;
        default:
            break;
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"test");
}

-(void)dealloc
{
    if (transList.size() > 0)
    {
        for (list<SKPaymentTransaction*>::iterator itr = transList.begin(); itr != transList.end(); itr++)
        {
            [(*itr) release];
        }
        transList.clear();
    }
    [alert release];
    [super dealloc];  
}

// base64编码
- (NSString *)encode:(const uint8_t *)input length:(NSInteger)length
{
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData *data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t *output = (uint8_t *)data.mutableBytes;
    
    for (NSInteger i = 0; i < length; i += 3) {
        NSInteger value = 0;
        for (NSInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger index = (i / 3) * 4;
        output[index + 0] =                    table[(value >> 18) & 0x3F];
        output[index + 1] =                    table[(value >> 12) & 0x3F];
        output[index + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[index + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
}

// 获取Json键值对
-(string)GetJsonValue:(const char*)pStr key:(const char*)pKey
{
    string str;
    
    if(pStr==NULL)
        return str;
    if(pKey==NULL)
        return str;
    
    string strKey="\"";
    strKey+=pKey;
    strKey+="\"";
    
    const char *p=strstr(pStr,strKey.c_str());
    if(p==NULL)
        return str;
    p+=strKey.length();
    
    while(*p!=0)
    {
        if(*p==' '||*p==':'||*p=='='||*p=='"')
        {
            ++p;
            continue;
        }
        if(*p==','||*p=='}')
            break;
        
        str+=*p;
        ++p;
    }
    
    return str;
}
@end

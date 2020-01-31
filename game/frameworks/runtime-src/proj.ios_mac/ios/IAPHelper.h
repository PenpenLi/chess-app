//
//  IAPHelper.h
//  majo
//
//  Created by 李 丁 on 14-7-23.
//
//

#ifndef __majo__IAPHelper__
#define __majo__IAPHelper__

#include <iostream>
//#include <string>
//#include <list>
#include "../../Classes/SDK/SHead.h"

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

using namespace std;

@interface IAPHelper : NSObject<SKProductsRequestDelegate,SKPaymentTransactionObserver>
{
    UIAlertView                  *alert;        // 提示框
    list<SKPaymentTransaction*>  transList;     // 交易成功的表单List
    list<string>                 payItemStrList;     // 准备购买的商品List
    int                          _isSandBox;
    string                       _transID;      // 商品id
    string                       _httpServerIP;   // 验证fwq地址ip
    int                          _httpServerPort;   // 验证fwq地址port
    string                       _httpServerPage;   // 验证fwq地址page
    string                       _privateInfo;  // 私有信息
}

+(IAPHelper*) sharedIAPHelper;
- (void)    requestProUpgradeProductData;
-(void)     RequestProductData:(string)strBuyID;
-(bool)     CanMakePay;
-(void)     buy:(string)type flag:(int)isSandBox buyItemID:(int)itemID buyPrice:(int)price buyInfo:(string)privateInfo ip:(string)httpServerIP port:(int)httpServerPort page:(string)httpServerPage;
-(void)     resumBuy:(string)type flag:(int)isSandBox buyInfo:(string)privateInfo ip:(string)httpServerIP port:(int)httpServerPort page:(string)httpServerPage;
-(void)     paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions;
-(void)     PurchasedTransaction: (SKPaymentTransaction *)transaction;
-(void)     completeTransaction: (SKPaymentTransaction *)transaction;
-(void)     failedTransaction: (SKPaymentTransaction *)transaction;
-(void)     paymentQueueRestoreCompletedTransactionsFinished: (SKPaymentTransaction *)transaction;
-(void)     paymentQueue:(SKPaymentQueue *) paymentQueue restoreCompletedTransactionsFailedWithError:(NSError *)error;
-(void)     restoreTransaction: (SKPaymentTransaction *)transaction;
-(void)     provideContent:(NSString *)product;
-(void)     recordTransaction:(NSString *)product;

-(bool)     CompleteSeverTransaction:(string)strPayID;                                                   // 完成交易 由fwq驱动
-(bool)     PushPaymentTransaction:(SKPaymentTransaction *)transaction;                 // 记录交易 准备由fwq来完成交易
-(void)     ShowTransactionTips:(string)strPayID;                                            // 显示交易成功后的提示
-(void)     ShowCloseAlertView:(const char *)title showMessage:(const char *)message;   // 显示带关闭的alertview
//-(void)     ShowAlertView:(const char *)title showMessage:(const char *)message;        // 显示无按钮的alertview
-(void)     SendReceiptToFWQ:(SKPaymentTransaction *)transaction PayID:(string)strPayID;      // 发送商品购买收据到fwq验证
-(void)     SendAllReceiptToFWQ;                                                         // 发送所有未完成的交易到FWQ验证
-(bool)     CheckIshaveUnFinishItem:(string)itemStr isInsert:(bool)insert;
-(void)     DelUnFinishItem:(string)itemStr;

@end

#endif /* defined(__majo__IAPHelper__) */

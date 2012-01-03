/* 列表2-1：宣告Car介面（Car.h） */

#import <Foundation/Foundation.h>
@interface Car : NSObject
{
    int year;
    NSString *make;
    NSString *model;
}
- (void) setMake:(NSString *) aMake andModel:(NSString *) aModel
    andYear: (int) aYear;
- (void) printCarInfo;
- (int) year;
@end

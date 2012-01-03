/* 列表2-2：Car類別的實作（Car.m） */

#import "Car.h"

@implementation Car
- (id) init
{
    self = [super init];
    if (!self) return nil;

    // make與model已經被初始化為nil，這是預設值
    year = 1901;

    return self;
}

- (void) setMake:(NSString *) aMake andModel:(NSString *) aModel
    andYear: (int) aYear
{
    // 注意，底下程式碼還沒有正確管理記憶體
    // Car物件沒有保留這些項目，
    // 之後可能會造成記憶體錯誤
    make = aMake;
    model = aModel;
    year = aYear;
}

- (void) printCarInfo
{
    if (!make) return;
    if (!model) return;

    printf("Car Info\n");
    printf("Make: %s\n", [make UTF8String]);
    printf("Model: %s\n", [model UTF8String]);
    printf("Year: %d\n", year);
}

- (int) year
{
    return year;
}
@end

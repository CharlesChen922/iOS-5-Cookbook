/* 列表2-4：main.m，ARC風格 */

int main(int argc, char *argv[])
{
    @autoreleasepool
    {
        int retVal = UIApplicationMain(argc, argv, nil,
            @"MyAppDelegateClass");
        return retVal;
    }
}

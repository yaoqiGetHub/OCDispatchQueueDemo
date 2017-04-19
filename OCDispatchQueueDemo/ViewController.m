//
//  ViewController.m
//  OCDispatchQueueDemo
//
//  Created by yaoqi on 2017/4/18.
//  Copyright © 2017年 yaoqi. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
//    dispatch_queue_t mainQueue = dispatch_get_main_queue();
//    dispatch_sync(mainQueue,^{// （可能是这个是主线程，得等到所有的主线程的任务完成之后才能继续进行，因为主线程的任务不能全部完成，所以造成程序死锁）
//        NSLog(@"MainQueue");
//    });
//    dispatch_queue_t serialQueue = dispatch_queue_create("com.dullgrass.serialQueue", DISPATCH_QUEUE_SERIAL);
//    dispatch_sync(serialQueue, ^{   //该代码段后面的代码都不会执行，程序被锁定在这里
//        NSLog(@"会执行的代码");
//        dispatch_sync(serialQueue, ^{//两个（多个）线程都要等待对方完成某个操作才能进行下一步，这时就会发生死锁。将它放到block外面就能正常调用了
//            NSLog(@"代码不执行");
//        });
//    });
    
//    主线成
//    dispatch_queue_t mainQueue = dispatch_get_main_queue(); //因为是串行的所以按照顺序一个一个执行
//    dispatch_async(mainQueue, ^{
//        NSLog(@"1");
//        NSLog(@"11");
//        NSLog(@"111");
//        NSLog(@"1111");
//
//    });
//    dispatch_async(mainQueue, ^{
//        NSLog(@"2");
//    });
//    dispatch_async(mainQueue, ^{
//        NSLog(@"3");
//    });
//    dispatch_async(mainQueue, ^{
//        NSLog(@"4");
//    });
////    全局并发线程
//    dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_async(defaultQueue, ^{ //因为是并发的所以无需的执行，但是block里面是顺序执行。如果都改成sync就是按照顺序执行的了
//        NSLog(@"g1");
//        NSLog(@"g11");
//        NSLog(@"g111");
//        NSLog(@"g1111");
//    });
//    dispatch_async(defaultQueue, ^{
//        NSLog(@"g2");
//    });
//    dispatch_async(defaultQueue, ^{
//        NSLog(@"g3");
//    });
//    dispatch_async(defaultQueue, ^{
//        NSLog(@"g4");
//    });
    
    
    //利用自定义队列可以模拟出 串行队列 并行队列 同步任务 异步任务
    //    同步：无论是串行还是并行，都按照主线程顺序执行；
    //    异步：串行的时候顺序执行，并行的时候无序执行；
    //    串行：无论同步还是异步都顺序执行
    //    并行：同步顺序执行，异步无序执行
//    自定义队列（在这因为是同步任务所以得等到block执行完毕之后才能进行下一步执行 NSLog(@"c6"); 但是如果改成async就会无序执行不会等待三秒，会先执行NSLog(@"c6");后执行NSLog(@"c5");）
//    自己创建的并行队列DISPATCH_QUEUE_CONCURRENT、串行队列DISPATCH_QUEUE_SERIAL（NULL）
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.bjsxt.concurrentQueuess", NULL);
    dispatch_async(concurrentQueue, ^{//在这里要是改成sync 就会按照顺序一个一个执行下去 等待线程睡眠之后再执行
        NSLog(@"c4");
        dispatch_async(concurrentQueue, ^{//串行队列--这个改成sync不知道为什么会死锁。。。有可能是因为外层的线程是异步的，不用等待就向下执行，而里面又是同步执行，得等待，所以发生了冲突。导致线程死锁。但是改成并行又能用了不知道为什么。
            [NSThread sleepForTimeInterval:3];
            NSLog(@"c5");
        });
        NSLog(@"c6");
    });
    dispatch_sync(concurrentQueue, ^{//如果改成sync，同步。。这样的话就会阻塞当前的线程（concurrentQueue），必须等到他执行完之后才能向下执行
        NSLog(@"c7");//NSLog(@"c7")这个相当于是任务的执行代码，就是把打印的这句话放到concurrentQueue这个线程中去执行
    });
    dispatch_async(concurrentQueue, ^{
        NSLog(@"c8");
        
    });
    dispatch_async(concurrentQueue, ^{
        NSLog(@"c9");
        
    });

    
    
    
    
    //1.创建队列组
    dispatch_group_t group = dispatch_group_create();
    //2.创建队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    //3.多次使用队列组的方法执行任务, 只有异步方法，没有同步方法
    //3.1.执行3次循环
    dispatch_group_async(group, queue, ^{
        for (NSInteger i = 0; i < 3; i++) {
            NSLog(@"group-01 - %@", [NSThread currentThread]);
        }
    });
    
    //3.2.主队列执行8次循环
    dispatch_group_async(group, dispatch_get_main_queue(), ^{
        for (NSInteger i = 0; i < 8; i++) {
            NSLog(@"group-02 - %@", [NSThread currentThread]);
        }
    });
    
    //3.3.执行5次循环
    dispatch_group_async(group, queue, ^{
        for (NSInteger i = 0; i < 5; i++) {
            NSLog(@"group-03 - %@", [NSThread currentThread]);
        }
    });
    
    //4.都完成后会自动通知
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"完成 - %@", [NSThread currentThread]);
    });
    
    
    //延迟执行
    // 创建队列
    dispatch_queue_t queueG = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // 设置延时，单位秒
    double delay = 5;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), queueG, ^{
        // 3秒后需要执行的任务
        NSLog(@"延迟执行操作");
    });
//    我们都知道在其他线程操作完成后必须到主线程更新UI。所以，介绍完所有的多线程方案后，我们来看看有哪些方法可以回到主线程。
    //Objective-C
//    [self performSelectorOnMainThread:@selector(run) withObject:nil waitUntilDone:NO];
    
}






























@end

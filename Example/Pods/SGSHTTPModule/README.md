# Southgis iOS(OC) 移动支撑平台组件 - HTTP 请求模块

[![CI Status](http://img.shields.io/travis/Lee/SGSHTTPModule.svg?style=flat)](https://travis-ci.org/Lee/SGSHTTPModule)
[![Version](https://img.shields.io/cocoapods/v/SGSHTTPModule.svg?style=flat)](http://cocoapods.org/pods/SGSHTTPModule)
[![License](https://img.shields.io/cocoapods/l/SGSHTTPModule.svg?style=flat)](http://cocoapods.org/pods/SGSHTTPModule)
[![Platform](https://img.shields.io/cocoapods/p/SGSHTTPModule.svg?style=flat)](http://cocoapods.org/pods/SGSHTTPModule)

------

SGSHTTPModule（OC版本）是移动支撑平台 iOS Objective-C 组件之一，其思想借鉴了 [YTKNetwork](https://github.com/yuantiku/YTKNetwork) ，基于 AFNetworking 封装的一套 HTTP 请求组件。通过这套组件可以轻松实现 HTTP 请求、上传与下载

使用 [AFNetworking 3.1](https://github.com/AFNetworking/AFNetworking) 作为基础

## 安装
------
SGSHTTPModule 可以通过 **Cocoapods** 进行安装，可以复制下面的文字到 Podfile 中：

```ruby
target '项目名称' do
  pod 'SGSHTTPModule', '~> 0.5.0'
end
```

## 功能
------
使用 **AFNetworking 3.1** 版本进行封装，内部使用 `NSURLSession` 发起请求

**SGSHTTPModule** 提供了以下功能：
> * 支持请求的发起、暂停、取消、继续操作
> * 支持设置请求的优先级，充分利用 HTTP/2 的调度优势 
> * 支持不同的网络服务类型（标准网络传输、VoIP传输等）
> * 支持统一设置服务器地址
> * 可自行判断是否禁止蜂窝网络传输
> * 支持不同的 URL Request 缓存策略
> * 可自定义判断是否处理 cookies 数据
> * 支持自定义对请求结果的过滤
> * 支持 block 和 delegate 两种回调方式
> * 支持断点续传功能
> * 支持过滤重复下载
> * 支持批量发起网络请求
> * 支持依次发起具有依赖性的网络请求

## 基本思想
------
基于面向对象的思想，将每个网络请求封装为一个对象，通过继承 `SGSBaseRequest`，重写父类的一些必要方法来构造不同的网络请求

将请求操作与其他业务相隔离，降低代码的耦合度，减少 `ViewController`（或者是业务 `Model` ）的代码量，让代码更简洁，更容易调试

并且通过继承的方式方便在基类中处理公共逻辑，以及对响应结果的持久化存储

## 代码结构
------
> * SGSBaseRequest：网络请求基础类
> * SGSBatchRequest：批量发起网络请求
> * SGSChainRequest：发起具有依赖性的网络请求
> * SGSBaseRequest+Convenient：实现 AFHTTPSessionManager 请求风格的请求方法
> * 辅助
>  - SGSHTTPConfig：统一设置服务器地址和缓存路径
>  - SGSRequestDelegate：请求过程的代理
>  - AFURLSessionManager+SGS：网络请求管理类
> * 对象序列化
>  - SGSResponseObjectSerializable：方便请求返回对象模型数据
>  - SGSResponseCollectionSerializable：方便请求返回包含对象的集合数据

## 使用方法
------
### 网络请求配置

通过 `SGSHTTPConfig` 可以统一设置服务器地址、缓存路径以及安全策略，可以考虑放在App启动时进行这项操作

```
typedef NS_ENUM(NSInteger, SGSServer) {
    SGSServerDev,   // 开发环境
    SGSServerRel,   // 发布环境
};

// App 启动
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [self setupNetworkConfig:SGSServerDev];
    return YES;
}

// 设置网络请求配置
- (void)setupNetworkConfig:(SGSServer)server {
    SGSHTTPConfig *config = [SGSHTTPConfig sharedInstance];

    switch (server) {
        case SGSServerDev: // 开发环境
            config.baseURL = @"http://192.168.10.xx";
            break;

        case SGSServerRel: // 发布环境
            config.baseURL = @"http://110.123.10.xx";
            break;

        default:
            break;
    }

    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    cachePath = [cachePath stringByAppendingPathComponent:@"RequestCache"];

    // 默认的缓存路径为：~/Library/Caches/com.southgis.iMobile.HTTPModule.RequestCacheData
    config.requestCacheDataPath = cachePath;
}
```

### AFHTTPSessionManager 风格的请求
------

#### 1.直接通过 URL 字符串发起请求

如果 SGSHTTPConfig 设置了 config.baseURL，那么这里的 urlString 可以是相对路径，例如：`/path/someserver?name1=value1&name2=value2`

```
[SGSBaseRequest GET:urlString success:^(SGSBaseRequest * _Nonnull request) {
    NSLog(@"response: %@", request.response);
    NSLog(@"string: %@", request.responseString);
    NSLog(@"json: %@", request.responseJSON);
} failure:^(SGSBaseRequest * _Nonnull request) {
    NSLog(@"failure: %@", request.error);
}];
```

#### 2.带有参数和请求过滤的请求

responseFilter 为请求完毕回调之前的过滤，当 responseFilter 调用完毕后
只要 request 的 error 不为空，那么就会回调 failure 分支，否则回调 success 分支
因此可以在该闭包中统一过滤特定的响应数据格式

假设返回的JSON格式如下：
{
    "code": 正确的code为200，错误的code为其他状态码
    "results": 正确返回的结果
    "description": 错误描述
}


```
[SGSBaseRequest GET:urlString parameters:params responseFilter:^(SGSBaseRequest * _Nonnull originalResponse) {
    // 如果 request 的 error 不为空，那么都会回调 failure 分支
    if (originalResponse.error != nil) return ;

    id json = originalResponse.responseJSON;
    if ((json == nil) || ![json isKindOfClass:[NSDictionary class]]) {
        // 不是合法的数据格式错误
        originalResponse.error = [NSError errorWithDomain:kSGSErrorDomain code:-8001 userInfo:@{NSLocalizedDescriptionKey: @"非法格式数据"}];
        return;
    }

    // 服务端自定义的code
    NSInteger code = [[json objectForKey:@"code"] integerValue];
    if (code != 200) {
        // 不是合法的自定义响应
        NSString *desc = [json objectForKey:@"description"];
        originalResponse.error =  [NSError errorWithDomain:kSGSErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey: desc ?: @"系统错误"}];
        return;
    }

    // 只要 request 的 error == nil，那么都会回调 success 分支
    id results = [json objectForKey:@"results"];
    originalResponse.responseData = [NSJSONSerialization dataWithJSONObject:results options:kNilOptions error:NULL];

} success:^(SGSBaseRequest * _Nonnull request) {
    NSLog(@"response: %@", request.response);
    NSLog(@"string: %@", request.responseString);
    NSLog(@"json: %@", request.responseJSON);
} failure:^(SGSBaseRequest * _Nonnull request) {
    NSLog(@"failure: %@", request.error);
}];
```


#### 3.通过传入目标对象类型，直接取回对应的对象数据的请求方法

forClass 指明最终所返回的 request.responseObject 或 request.responseObjectArray 的对象类型
如果 forClass 为空，那么 request.responseObject 或 request.responseObjectArray 就会返回 nil

```
[SGSBaseRequest GET:urlString
         parameters:params
           progress:nil
     responseFilter:[self defaultResponseFilter]
           forClass:[AccountInfo class]
            success:^(SGSBaseRequest *request) {

    AccountInfo *account = (AccountInfo *)request.responseObject;
    NSLog(@"获取用户信息成功: %@", account.description);

} failure:^(SGSBaseRequest *request) {
    NSLog(@"获取用户信息失败: %@", request.error);
}];
```

#### 4.简化统一的操作

当一些请求都具有相同的行为时，可以编写一个通过继承 `SGSBaseRequest` 类的基础请求类

如果需要过滤的数据格式都是统一的，那么除了通过一个指定的方法（静态方法、extern等）传递过滤 block 外，使用基础请求类的方式也是可以达到统一过滤的效果

例如在这个基础请求类中定义响应数据的过滤，并且在发起请求前都可以打印请求地址

```
@interface MyBaseRequest : SGSBaseRequest
@end

@implementation MyBaseRequest
// 发起请求前的block
- (void (^)(__kindof SGSBaseRequest * _Nonnull))requestWillStartBlock {
    return ^(SGSBaseRequest *request) {
        // 打印请求地址和请求参数
        NSLog(@"%@", [[NSURL URLWithString:[self originURLString] parameters:self requestParameters]]);
    };
}

// 请求完毕过滤
- (void)requestCompleteFilter {
    // 如果有错误直接返回
    if (self.error != nil) {
        return ;
    }

    id json = self.responseJSON;

    // 不是JSON数据
    if ((json == nil) || ![json isKindOfClass:[NSDictionary class]]) {
        self.error = errorWithCode(ErrorCodeInvalidResponseValue, @"非法数据");

        // 清空返回结果
        self.responseData = nil;
        return ;
    }

    // 返回的状态码不合法
    NSInteger state = [[json objectForKey:@"code"] integerValue];

    if (state != 200) {
        NSString *desc = [json objectForKey:@"description"];
        self.error = errorWithCode(state, desc);
        NSLog(@"返回的状态码不合法: %@", json);

        // 清空返回结果
        self.responseData = nil;
        return ;
    }

    // 获取结果
    id result = [json objectForKey:@"results"];

    if (result != nil) {
        // 重置结果
        self.responseData = [NSJSONSerialization dataWithJSONObject:result options:kNilOptions error:nil];
    } else {
        self.responseData = nil;
    }
}

@end
```

接下来就直接使用这个 `MyBaseRequest` 发起请求即可

```
[MyBaseRequest GET:_urlString
        parameters:_params
          progress:nil
    responseFilter:nil  // 这里的过滤闭包可以传入空
          forClass:[AccountInfo class]
           success:^(__kindof SGSBaseRequest * _Nonnull request) {

    AccountInfo *account = (AccountInfo *)request.responseObject;
    NSLog(@"请求成功:\n%@", account.description);

} failure:^(__kindof SGSBaseRequest * _Nonnull request) {
    NSLog(@"请求失败: %@", request.error);
}];
```

或者
```
[MyBaseRequest GET:_urlString 
        parameters:_params
           success:^(__kindof SGSBaseRequest * _Nonnull request) {
    NSLog(@"请求成功:\n%@", request.responseJSON);
} failure:^(__kindof SGSBaseRequest * _Nonnull request) {
    NSLog(@"请求失败: %@", request.error);
}];

```

### 基础请求
------

#### 1.定义一个继承自 `SGSBaseRequest` 的 API 类

```
// 定义一个 LoginAPI 类，并继承 SGSBaseRequest
// 该请求需要用户名和密码
@interface LoginAPI : SGSBaseRequest
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;

- (instancetype)initWithUsername:(NSString *)username password:(NSString *)password;
@end
```

#### 2.通过重写父类参数方法的形式，指定不同的请求

```
// 类实现部分
@implementation LoginAPI

// 请求方法，如果不重写默认为GET请求
- (SGSRequestMethod)requestMethod {
    return SGSRequestMethodPost;
}

// 重写 requestURL 方法，返回登录的请求地址
- (NSString *)requestURL {
    return @"http://192.168.11.11/service/mobileLogin";
}

// 请求参数
- (id)requestParameters {
    // 使用该方法避免传入 nil 造成创建字典崩溃
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:_username, @"username", _password, @"password", nil];

    return params;
}

// 模型对象类型
// 只要返回可以解析的类型，可以直接使用 responseObject 直接获取对象
- (Class<SGSResponseObjectSerializable>)responseObjectClass {
    // 该 AccountInfo 类包含 userId 和 nickname 两个属性
    return [AccountInfo class];
}
@end
```

#### 3. baseURL

如果共用一个基础地址，可以声明一个基础请求父类，并重写他的 `-baseURL` 方法

```
// 基础请求父类
@interface FileService : SGSBaseRequest
@end

@implementation FileService 
// 重写 baseURL 方法，返回请求的基础地址
- (NSString *)baseURL {
    return @"http://192.168.11.11";
}
@end


#pragma mark - DownloadFileAPI

// 下载文件请求类
@interface DownloadFileAPI : FileService
@property (nonatomic, copy) NSString *fileId;
@end

@implementation DownloadFileAPI 

// 当然，也可以直接在这里重写 -baseURL 方法，但是没有这个必要
//- (NSString *)baseURL {
//    return @"http://192.168.11.11";
//}

/**
 当发起请求时是根据 `originURLString` 属性作为请求地址，`originURLString` 的拼接规则如下：
	1. -requestURL 返回的字符串是否包含了“http://”，如果包含直接使用该地址进行请求
	2. 判断该类是否重写父类的 -baseURL 方法，如果有则与 -requestURL 进行组合并发起请求
	3. 判断 SGSHTTPConfig 是否设置了 baseURL，如果有则将配置的基础地址与 requestURL 进行组合并发起请求
	4. 如果都没有设置 baseURL，并且 requestURL 的头部没有包含“http://”，那么会尝试直接使用 requestURL 的链接发起请求
*/
- (NSString *)requestURL {
    return @"/service/mobileLogin";
}

// 请求参数
- (id)requestParameters {
    return (_fileId) ? @{@"fileId": _fileId} : nil;
}
@end
```

#### 4.过滤返回结果

如果返回的结果有特定形式，可以通过重写 `-requestCompleteFilter` 来过滤请求结果

只要error属性不为空，在最终请求回调时自动判断为请求失败，回调 `failureCompletionBlock` 和代理方法

所以当请求结果不符合预期值的时候，可以将自定义的 `NSError` 复制给 `error` 属性


```
假设合法的JSON结果为：
	{
		"code": 200,
 		"description": null,
		"result": {
					"userId": "1001"
					"nickname": "李四"
				}
	}
	
非法的JSON结果为：
	{
		"code": 301,
		"description": "密码错误",
		"result": null
	} 
	
@implementation SomeRequestAPI
// 自定义请求完毕的过滤
- (void)requestCompleteFilter {
    // 如果有错误直接返回
    if (self.error != nil) return ;

    id json = self.responseJSON;

    // 苹果定义的的JSON数据格式
    // 最外层为字典，并且key的类型全部字符串类型
    if ((json == nil) || ![json isKindOfClass:[NSDictionary class]]) {
        // 不是JSON数据
        self.error = errorWithCode(ErrorCodeInvalidResponseValue, @"非法数据");
        NSLog(@"登录接口返回错误信息: %@", self.responseString);

        // 清空返回结果
        self.responseData = nil;
        return ;
    }
  
    NSInteger state = [[json objectForKey:@"code"] integerValue];

    if (state != 200) {
        // 返回的状态码不合法
        NSString *desc = [json objectForKey:@"description"];
        self.error = errorWithCode(state, desc);
        NSLog(@"返回的状态码不合法: %@", json);

        // 清空返回结果
        self.responseData = nil;
        return ;
    }

    // 获取结果
    id result = [json objectForKey:@"results"];

    if (result != nil) {
        // 重置结果
        self.responseData = [NSJSONSerialization dataWithJSONObject:result options:kNilOptions error:nil];
    } else {
        self.responseData = nil;
    }
}
@end
```


#### 5.发起请求并通过block方式回调

```
// 获取对象类型
- (void)loginWithUsername:(NSString *)username password:(NSString *)password {

    LoginAPI *request = [[LoginAPI alloc] initWithUsername:username password:password];

    [request startWithCompletionSuccess:^(__kindof SGSBaseRequest * _Nonnull request) {

        // 回调block将在主线程中执行
        NSLog(@"登录成功，当前线程: %@", [NSThread currentThread]); // Main Thread

        // 使用模型接收返回结果
        AccountInfo *account = request.responseObject;

        // 在回调block执行完毕后会主动清空，打破循环引用
        // 所以可以直接使用self而不用担心保留环问题
        [self handleAccountInfo:account];

    } failure:^(__kindof SGSBaseRequest * _Nonnull request) {
        NSLog(@"登录失败，当前线程: %@", [NSThread currentThread]); // Main Thread

        NSString *msg = request.error.localizedDescription;
        [self showAlert:@"登录失败" message:msg];
    }];
}
```

#### 6.使用代理方式处理请求回调

```
- (void)loginWithUsername:(NSString *)username password:(NSString *)password {
    LoginAPI *request = [[LoginAPI alloc] initWithUsername:username password:password];

    // 将self设置为代理
    request.delegate = self;

    // 开始请求
    [request start];
}

#pragma mark - SGSRequestDelegate
// 请求成功
- (void)requestSuccess:(SGSBaseRequest *)request {
    NSLog(@"登录成功，当前线程: %@", [NSThread currentThread]); // Main Thread

    AccountInfo *account = request.responseObject;
    [self handleAccountInfo:account];
}

// 请求失败
- (void)requestFailed:(SGSBaseRequest *)request {
    NSLog(@"登录失败，当前线程: %@", [NSThread currentThread]); // Main Thread

    NSString *msg = request.error.localizedDescription;
    [self showAlert:@"登录失败" message:msg];
}
```

### 下载

使用 `-startWithCompletionSuccess:failure:` 或者 `-start` 即可进行下载，但是使用这两个方法下载不支持断点续传功能

```
@interface HDImageAPI : SGSBaseRequest
@end

@implementation HDImageAPI
- (NSString *)requestURL {
    return @"http://www.example.com/DownloadImg/32405513.jpg";
}
@end

- (IBAction)downloadHDImage:(UIButton *)sender {
    // 创建请求
    _downloadHDImage = [HDImageAPI new];

    // 进度将会在主线程中执行
    [_downloadHDImage setProgressBlock:^(NSProgress * _Nonnull progress) {
        float pro = (float)progress.completedUnitCount / (float)progress.totalUnitCount;
        _progressBar.progress = pro;
    }];
    
    // > 发起下载请求
    [_downloadHDImage startWithCompletionSuccess:^(__kindof SGSBaseRequest * _Nonnull request) {

        [self handleHDImage:request.responseData];

    } failure:^(__kindof SGSBaseRequest * _Nonnull request) {

        [self showAlert:@"高清大图下载失败" message:request.error.localizedDescription];
    }];
}

```

如果希望使用断点续传功能可以使用 `-downloadWithCompletionSuccess:failure:` 或者 `-startDownload`

在发起下载请求前，根据下载地址自动判断本地是否有断点数据：如果没有断点数据将发起新的下载请求；如果有断点数据，那么将读取断点数据继续下载

当下载或者断点续传失败时，会在磁盘和缓存中保存这次请求的断点数据

并且使用这两个方法会过滤掉重复的请求，当发起多个请求时，上一次的下载请求将会取消并且保存断点数据，使用断点续传发起新的下载请求

并且可以重写 `-downloadTargetPath` 方法指定下载完成后的保存路径

```
@implementation ChineseMapAPI

- (NSString *)requestURL {
    return @"http://www.onegreen.net/maps/m/a/zhongguo1.jpg";
}

// 下载完毕后的保存路径
- (NSURL * _Nonnull (^)(NSURL * _Nonnull, NSURLResponse * _Nonnull))downloadTargetPath {
    return ^(NSURL * location, NSURLResponse * response) {
        
        NSURL *docDir = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
        
        if (docDir == nil) {
            return location;
        }
        
        // 下载完毕后的保存路径：~/Document/(图片名)
        return [docDir URLByAppendingPathComponent:[response suggestedFilename]];
    };
}
@end

- (IBAction)downloadHDImage:(UIButton *)sender {
    // 创建请求
    _downloadChineseMap = [ChineseMapAPI new];

    // 进度将会在主线程中执行
    [_downloadChineseMap setProgressBlock:^(NSProgress * _Nonnull progress) {
        float pro = (float)progress.completedUnitCount / (float)progress.totalUnitCount;
        _progressBar.progress = pro;
    }];

    // > 使用带有断点续传功能的下载
    [_downloadChineseMap downloadWithCompletionSuccess:^(__kindof SGSBaseRequest * _Nonnull request) {

        [self handleChineseMap:request.responseData];

    } failure:^(__kindof SGSBaseRequest * _Nonnull request) {

        [self showAlert:@"中国地图下载失败" message:request.error.localizedDescription];
    }];
}
```

### 上传

同样的只需要自定义一个类继承自 `SGSBaseRequest` 并且重写父类的 `-requestMethod` 的方法并返回 `SGSRequestMethodPost`，在 `constructingBodyBlock` 属性中拼接需要上传的数据即可

```
@interface UploadItem : SGSBaseRequest
@property (nonatomic, strong) NSDictionary <NSString *, NSString *> *HTTPRequestHeaders;
@end

// 自定义UploadAPI
@interface UploadAPI : SGSBaseRequest
@end

@implementation UploadAPI
- (NSString *)requestURL {
    return @"http://www.example.com";
}

// 上传需要指定为Post请求
- (SGSRequestMethod)requestMethod {
    return SGSRequestMethodPost;
}

// 如果需要上传的数据已经明确，可以通过重写 constructingBodyBlock 的 getter 方法
// - (void (^)(id<AFMultipartFormData> _Nonnull))constructingBodyBlock {
//    return ^(id <AFMultipartFormData> formData) {
//        拼接参数...
//    };
//}
@end

- (void)uploadImage {
    // 创建上传请求实例
    __weak typeof(&*self) weakSelf = self;

    UploadAPI *upload = [UploadAPI new];

    [upload setConstructingBodyBlock:^(id<AFMultipartFormData> formData) {
        // 以文件URL的形式拼接表单数据
        NSURL *imgURL1 = [[NSBundle mainBundle] URLForResource:@"1" withExtension:@"jpg"];
        if (imgURL1 != nil) {
            NSError *error = nil;
            [formData appendPartWithFileURL:imgURL1 name:@"image1" error:&error];
            if (error != nil) {
                NSLog(@"获取图片'1'失败：%@", error);
            }
        }

        // 以数据的形式拼接表单数据
        UIImage *img2 = [UIImage imageNamed:@"2"];
        if (img2 != nil) {
            NSData *imgData = UIImagePNGRepresentation(img2);
            if (imgData != nil) {
                [formData appendPartWithFormData:imgData name:@"image2"];
            }
        }

        // 以文件URL和参数的形式拼接表单数据
        NSURL *docDir = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        NSURL *imgURL3 = [docDir URLByAppendingPathComponent:@"3.png"];
        NSError *appendFileError = nil;
        [formData appendPartWithFileURL:imgURL3 name:@"image3" fileName:@"3" mimeType:@"image/png" error:&appendFileError];
        if (appendFileError != nil) {
            NSLog(@"获取图片'3'失败：%@", appendFileError);
        }

        // 以数据和参数的形式拼接表单数据
        NSData *img4 = [NSData dataWithContentsOfFile:@"../4.jpg"];
        if (img4) {
            [formData appendPartWithFileData:img4 name:@"image4" fileName:@"4" mimeType:@"image/jpeg"];
        }

        // 更多的拼接方法请参照 AFMultipartFormData
    }];

    // 设置显示上传进度
    [upload setProgressBlock:^(NSProgress * progress) {
        float pro = (float)progress.completedUnitCount / (float)progress.totalUnitCount;
        weakSelf.progressBar.progress = pro;
    }];

    // 发起上传请求
    [upload startWithCompletionSuccess:^(__kindof SGSBaseRequest * _Nonnull request) {

        weakSelf.textView.text = [NSString stringWithFormat:@"上传成功：\n%@\n", request.responseString];

    } failure:^(__kindof SGSBaseRequest * _Nonnull request) {

        weakSelf.textView.text = [NSString stringWithFormat:@"上传失败：\n%@\n", request.error.localizedDescription];
    }];
}

```

### 批处理请求

可以使用 `SGSBatchRequest` 对批量发起多个网络请求
当所有请求全部成功返回的时候，通过 `SGSBatchRequest` 的 `successCompletionBlock` 回调
当某个请求失败时，将会取消其他尚未响应的请求，并且通过 `SGSBatchRequest` 的 `failureCompletionBlock` 回调

```
// 创建 GitHub HTML 文本的请求
- (GitHubAPI *)githubRequest {
    GitHubAPI *request = [GitHubAPI new];

    [request setCompletionBlockWithSuccess:^(__kindof SGSBaseRequest * _Nonnull request) {
        // github HTML请求成功的处理
    } failure:^(__kindof SGSBaseRequest * _Nonnull request) {
        // github HTML请求失败的处理
    }];

    return request;
}

// 创建新浪 HTML 文本的请求
- (SinaAPI *)sinaRequest {
    SinaAPI *request = [SinaAPI new];
    request.ignoreCache = YES;  // 忽略缓存

    [request setSuccessCompletionBlock:^(__kindof SGSBaseRequest * _Nonnull request) {
        // 新浪HTML请求成功的处理
    }];

    [request setFailureCompletionBlock:^(__kindof SGSBaseRequest * _Nonnull request) {
        // 新浪HTML请求失败的处理
    }];

    return request;
}

- (IBAction)loadHTML:(UIButton *)sender {
    // 批量发起请求
    SGSBatchRequest *batch = [[SGSBatchRequest alloc] initWithRequestArray:@[[self githubRequest], [self sinaRequest]]];

    [batch startWithCompletionSuccess:^(SGSBatchRequest * _Nonnull batchRequest) {
        NSLog(@"批处理的请求: %@", batchRequest.requestArray);
        [self showAlert:@"批处理请求完毕" message:nil];

    } failure:^(SGSBatchRequest * _Nonnull batchRequest, __kindof SGSBaseRequest * _Nonnull baseRequest) {
        NSString *msg = baseRequest.error.localizedDescription;
        [self showAlert:@"请求网页出错" message:msg];
    }];
}
```

有时候会有这种类似的需求：
> 有若干个文件（a, b, c, d...），将文件上传到服务器后，返回一个 `fileId` 
> 需要对这个 `fileId` 做一些关联处理，并且上传成功后删除本地的该文件
> 每个文件上传互不影响，因此只对上传成功的文件做处理，上传失败的等待下一次机会接着上传

这种情况使用 `SGSBatchRequest` 就很容易实现

```
- (void)uploadDatas:(NSArray<NSData *> *)datas {
    NSMutableArray *uploads = [NSMutableArray arrayWithCapacity:datas.count];

    for (NSData *data in datas) {
        UploadFileAPI *upload = [UploadFileAPI new];

        // 拼接上传的数据
        [upload setConstructingBodyBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFormData:data name:@"image"];
        }];

        // 设置回调
        [upload setCompletionBlockWithSuccess:^(__kindof SGSBaseRequest * _Nonnull request) {
            // 上传成功，拿到fileId进行关联处理
            NSString *fileId = request.responseString;

            // 删除文件...

        } failure:^(__kindof SGSBaseRequest * _Nonnull request) {
            // 上传失败处理
        }];

        // 将上传请求添加到数组中
        [uploads addObject:upload];
    }

    // 构建批处理
    SGSBatchRequest *batch = [[SGSBatchRequest alloc] initWithRequestArray:uploads];
    batch.stopRequestWhenOneOfBatchFails = NO; // 其中某个请求失败时，不会停止其他请求，该属性默认为YES

    [batch startWithCompletionBlock:^(SGSBatchRequest * _Nonnull batchRequest) {
        // 所有请求全部处理完
    } failure:nil];

    // 由于 batch.stopRequestWhenOneOfBatchFails 为 NO，所以该 failure 分支不会走，可以置为 nil
}
```

### 依赖性请求

当需要发起相互依赖的链式网络请求时，可以使用 `SGSChainRequest` 类。`SGSChainRequest` 先发起 A 请求，待 A 请求成功后再发起 B 请求，待 B 请求成功后再发起 C 请求，依次进行，直至所有请求全部响应成功。如果途中某个请求失败（例如 B 请求），那么后面的请求将会取消（例如 C 请求），并且通过 `SGSChainRequest` 的代理方法回调


例如某个场景下，需要用户先进行登录操作，待登录成功后获取到用户的信息，根据用户的信息在主页上加载用户的日程数据；如果登录失败则不做后面的处理

这种情况就需要发起具有依赖性的网络请求，通过 `SGSChainRequest` 类可以方便地实现这些功能

```
- (void)loginWithUsername:(NSString *)username password:(NSString *)password {
    // 创建登录请求
    LoginAPI *login = [[LoginAPI alloc] initWithUsername:username password:password];

    // 创建链式请求
    SGSChainRequest *chain = [[SGSChainRequest alloc] init];

    // 添加登录依赖请求
    [chain addRequest:login callback:^(SGSChainRequest * _Nonnull chainRequest, __kindof SGSBaseRequest * _Nonnull baseRequest) {
        // 登录成功后获取 userId
        NSString *userId = ((LoginAPI *)baseRequest).userId;

        // 创建日程请求
        ScheduleAPI *scheduleRequest = [[ScheduleAPI alloc] initWithUserId:userId];

        // 添加日程请求
        // 最终的请求可以通过 SGSChainRequest 的代理方法回调
        // 因此可以不设置callback，
        [chainRequest addRequest:scheduleRequest callback:nil];
    }];

    // 设置代理并发起请求
    chain.delegate = self;
    [chain start];
}

#pragma mark - SGSChainRequestDelegate

// 链式请求完毕
- (void)chainRequestFinished:(SGSChainRequest *)chainRequest {
    id result = chainRequest.requestQueue.lastObject.responseObject;

    if ([result isKindOfClass:[ScheduleGroup class]]) {
        _textView.text = [NSString stringWithFormat:@"日程:\n%@\n", [result description]];
    } else {
        _textView.text = @"日程数据有误";
    }
}

// 链式请求失败
- (void)chainRequestFailed:(SGSChainRequest *)chainRequest failedBaseRequest:(__kindof SGSBaseRequest *)request {
    _failedCount++;

    if (_failedCount >= 3) {
        // 失败太多次不再继续请求
        [self showAlert:@"失败了太多次，请重新登录..." message:nil];
        _failedCount = 0;
        return ;
    }

    if ([request isKindOfClass:[LoginAPI class]]) {
        _textView.text = [NSString stringWithFormat:@"失败%ld次\n获取userId失败，重新请求中...\n", _failedCount];
    } else {
        _textView.text = [NSString stringWithFormat:@"失败%ld次\n获取日程失败，重新请求中...\n", _failedCount];
    }

    // 会从上一次失败的节点再次发起请求
    [chainRequest start];
}
```

## 结尾
------
**移动支撑平台** 是研发中心移动团队打造的一套移动端开发便捷技术框架。这套框架立旨于满足公司各部门不同的移动业务研发需求，实现App快速定制的研发目标，降低研发成本，缩短开发周期，达到代码的易扩展、易维护、可复用的目的，从而让开发人员更专注于产品或项目的优化与功能扩展

整体框架采用组件化方式封装，以面向服务的架构形式供开发人员使用。同时兼容 Android 和 iOS 两大移动平台，涵盖 **网络通信**, **数据持久化存储**, **数据安全**, **移动ArcGIS** 等功能模块（近期推出混合开发组件，只需采用前端的开发模式即可同时在 Android 和 iOS 两个平台运行），各模块间相互独立，开发人员可根据项目需求使用相应的组件模块

更多组件请参考：
> * [数据持久化存储组件](http://112.94.224.243:8081/kun.li/sgsdatabase/tree/master)
> * [数据安全组件](http://112.94.224.243:8081/kun.li/sgscrypto/tree/master)
> * [ArcGIS绘图组件](https://github.com/crash-wu/SGSketchLayer-OC)
> * [常用类别组件](http://112.94.224.243:8081/kun.li/sgscategories/tree/master)
> * [常用工具组件](http://112.94.224.243:8081/kun.li/sgsutilities/tree/master)
> * [集合页面视图](http://112.94.224.243:8081/kun.li/sgscollectionpageview/tree/master)


如果您对移动支撑平台有更多的意见和建议，欢迎联系我们！

研发中心移动团队

2016 年 08月 26日    


## Author
------
Lee, kun.li@southgis.com

## License
------
SGSHTTPModule is available under the MIT license. See the LICENSE file for more info.

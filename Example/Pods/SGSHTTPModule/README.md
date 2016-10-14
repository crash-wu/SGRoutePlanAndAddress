# Southgis iOS(OC) 移动支撑平台组件 - HTTP 请求模块

[![CI Status](http://img.shields.io/travis/Lee/SGSHTTPModule.svg?style=flat)](https://travis-ci.org/Lee/SGSHTTPModule)
[![Version](https://img.shields.io/cocoapods/v/SGSHTTPModule.svg?style=flat)](http://cocoapods.org/pods/SGSHTTPModule)
[![License](https://img.shields.io/cocoapods/l/SGSHTTPModule.svg?style=flat)](http://cocoapods.org/pods/SGSHTTPModule)
[![Platform](https://img.shields.io/cocoapods/p/SGSHTTPModule.svg?style=flat)](http://cocoapods.org/pods/SGSHTTPModule)

------

SGSHTTPModule（OC版本）是移动支撑平台 iOS Objective-C 组件之一，其思想借鉴了 [YTKNetwork](https://github.com/yuantiku/YTKNetwork) ，基于 AFNetworking 封装的一套 HTTP 请求组件。通过这套组件可以轻松实现 HTTP 请求、上传与下载

所支持的 `AFNetworking` 的最低版本为 3.0，鉴于 3.1 以前的版本有一些 BUG，所以推荐使用 [AFNetworking 3.1](https://github.com/AFNetworking/AFNetworking) 作为基础

如果只是简单的项目，网络环境不复杂的情况下，建议使用 `AFHTTPSessionManager+SGS` 中的扩展方法

## 安装
------
SGSHTTPModule 可以通过 **Cocoapods** 进行安装，可以复制下面的文字到 Podfile 中：

```ruby
target '项目名称' do
  pod 'SGSHTTPModule', '~> 0.4.1'
end
```

## 功能
------
使用 **AFNetworking 3.x** 版本进行封装，内部使用 `NSURLSession` 发起请求，相比 **YTKNetwork** 在请求过程拥有更灵活的使用方式

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
基于面向对象的思想，将每个网络请求封装为一个对象，通过继承 `SGSBaseRequest`（如果有缓存的需要可以继承自 `SGSCacheableRequest`），重写父类的一些必要方法来构造不同的网络请求

将请求操作与其他业务相隔离，降低代码的耦合度，减少 `ViewController`（或者是业务 `Model` ）的代码量，让代码更简洁，更容易调试

并且通过继承的方式方便在基类中处理公共逻辑，以及对响应结果的持久化存储

## 代码结构
------
> * SGSBaseRequest：网络请求基础类
> * SGSBatchRequest：批量发起网络请求
> * SGSChainRequest：发起具有依赖性的网络请求
> * AFHTTPSessionManager+SGS：基于 **AFNetworking** 网络请求接口的一些扩展方法
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

### 基础请求

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

## AFNetworking+SGS
------

`SGSHTTPModule` 还提供了 `AFNetworking` 的一些扩展方法，在原生的请求接口上，添加了请求结果过滤闭包（ `responseFilter` ）和请求结果转模型对象类（ `forClass` ）两个参数，其使用方法不变

目的是为了在请求不太复杂时，可以继续沿用 **AFNetworking** 的原生接口，避免每个请求都需要封装一个对象的麻烦

### responseFilter
`responseFilter` 用于过滤返回结果，接收 **AFNetworking** 原始的返回数据，数据类型根据 `responseSerializer` 而定，默认的返回类型是 `[AFJSONResponseSerializer serializer]` 也就是 JSON 格式的数据

该闭包将根据自定义的过滤结果，需要返回一个 id 类型的数据，返回的数据如果是 `NSError` 类型，那么最终将判断为请求失败

如果返回其他类型，那么最终判断为请求成功

如果该参数传入 nil 将不进行过滤


### forClass
**forClass** 表示最终返回的类型，类型必须是遵守 `SGSResponseObjectSerializable` 或 `SGSResponseCollectionSerializable` 的类

**forClass** 的类型，是根据 **responseFilter** 返回的过滤数据进行转换，如果没有进行过滤则将根据 **AFNetworking** 返回的数据进行转换

如果为 `nil` ，则直接返回过滤后的数据或返回 **AFNetworking** 的默认类型。



```
@interface AccountInfo : NSObject <SGSResponseObjectSerializable>
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *loginName;
@ end

@implementation
+ (id<SGSResponseObjectSerializable>)objectSerializeWithResponseObject:(id)object {
	return [AccountInfo yy_modelWithJSON:object];
}
@end


- (void)loginWithUsername:(NSString *)username password:(NSString *)password {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:username, @"username", password, @"password", nil];
 
	AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

	// AF的返回格式默认就是JSON，所以这里可以忽略，如果希望返回其他格式的可以自行设定
	// manager.responseSerializer = [AFJSONResponseSerializer serializer];
	
	// AFNetworking 响应头默认接收JSON的 Content-Type 为 "application/json", "text/json", "text/javascript"
	// 如果服务器响应头返回的不是这些格式，并且内容还是 JSON 数据的话，那么应该把这个属性设置为 nil 或者添加服务器返回的类型
	manager.responseSerializer.acceptableContentTypes = nil;

	// 这里提供的 defaultResponseFilter 是过滤指定的 JSON 数据格式:
	// 	{
	//		"code": 自定义状态码，请求成功返回200，其余状态码表示失败
	//		"description": 请求失败的错误描述信息，可为空
	// 		"results": 请求成功的数据结果，可为空
	//	}
	[manager GET:@"http://192.168.10.10/appServer/userLogin"
	  parameters:params
        progress:nil
  responseFilter:[AFHTTPSessionManager defaultResponseFilter]
        forClass:[AccountInfo class]  
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         
			// 请求成功
			AccountInfo *account = (AccountInfo *)responseObject;
			[self handlerAccount:account];

		} failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
			// 请求失败处理
		}];
}

```

## 详细说明
------

### SGSHTTPConfig

网络配置类 `SGSHTTPConfig` 采用单例设计模式，用于统一设置通用的网络配置，例如：基础地址、缓存目录、HTTPS 安全策略等

```
/**
 *  基础地址，默认为 @""
 */
@property (nonatomic, copy) NSString *baseURL;

/**
 *  默认的下载保存目录，用于指定 SGSBaseRequest 中 downloadTargetPath 方法的默认返回路径
 *  原始目录为 `~/Library/Caches/com.southgis.iMobile.HTTPModule.downloads`
 */
@property (nonatomic, copy) NSString *defaultDownloadsDirectory;

/**
 *  单例
 */
+ (instancetype)sharedInstance;
```

### SGSResponseObjectSerializable

`SGSResponseObjectSerializable` 协议指定了一个根据响应数据实例化对象的类方法，遵守该协议的对象可以方便的通过请求直接获取对象模型数据

```
@protocol SGSResponseObjectSerializable <NSObject>

/**
 *  将响应结果转换为内容全部是模型对象的数组
 *
 *  @param object 响应结果
 *
 *  @return 转换成功返回 `NSArray` ，否则返回 `nil`
 */
+ (nullable id<SGSResponseObjectSerializable>)objectSerializeWithResponseObject:(id)object;
@end
```


### SGSResponseCollectionSerializable

该协议指定了一个返回包含遵守 `SGSResponseObjectSerializable` 协议对象的数组的类方法，遵守该协议的对象可以方便的通过请求直接获取对象数组数据

```
@protocol SGSResponseCollectionSerializable <NSObject>

/**
 *  将响应结果转换为模型对象
 *
 *  @param object 响应结果
 *
 *  @return 转换成功返回模型对象，否则返回 `nil`
 */
+ (nullable NSArray<id<SGSResponseObjectSerializable>> *)colletionSerializeWithResponseObject:(id)object;
@end
```


### SGSBaseRequest

`SGSBaseRequest` 是请求模块的基础类，通过继承该类实现网络请求的发起和响应

该类主要分为六个部分：
> 1. 基础属性
> 2. 请求过程闭包
> 3. 响应数据属性
> 4. 操作方法
> 5. 请求参数
> 6. 代理方法

#### 1.基础属性

基础属性包括代理、请求 task、请求状态以及请求优先级等

```
/**
 *  代理
 *  
 *  @discussion 通过代理可以获取请求过程的代理方法，包括请求的开始、暂停、取消、成功、失败等
 */
@property (nullable, weak) id<SGSRequestDelegate> delegate;

/**
 *  请求任务
 */
@property (nullable, nonatomic, strong) NSURLSessionTask *task;

/**
 *  请求状态，包括：正在请求、暂停、已取消、已完成
 */
@property (nonatomic, assign, readonly) NSURLSessionTaskState state;

/**
 *  请求
 *
 *  @discussion 由 `task.originalRequest` 获取
 */
@property (nullable, nonatomic, strong, readonly) NSURLRequest *request;

/**
 *  原始请求地址，根据 `-requestURL` , `-baseURL` , 以及 SGSHTTPConfig 的 `-baseURL` 拼接
 *
 *  @discussion 当发起请求时会基于以下规则拼接请求地址：
 *      1. `-requestURL` 返回的字符串是否包含了“http://”协议，如果包含直接使用该地址进行请求
 *      2. 判断是否重写父类的 `-baseURL` 方法，如果有则与 `-requestURL` 进行组合并发起请求
 *      3. 判断 SGSHTTPConfig 是否设置了 `-baseURL`，如果有则将配置的基础地址与 `-requestURL` 进行组合并发起请求
 *      4. 如果都没有设置 `-baseURL`，并且 `-requestURL` 的头部没有包含“http://”，那么会尝试直接使用 `-requestURL` 的链接发起请求
 */
@property (nonatomic, copy, readonly) NSString *originURLString;

/**
 *  请求优先级，默认为 `SGSRequestPriorityDefault`
 */
@property (nonatomic, assign) SGSRequestPriority requestPriority;
```

#### 2.请求过程闭包

请求过程包括：请求成功、请求失败、开始、暂停、取消、请求中等状态

```
/**
 *  请求成功回调闭包
 */
@property (nullable, nonatomic, copy) void (^successCompletionBlock)(__kindof SGSBaseRequest *request);

/**
 *  请求失败回调闭包
 */
@property (nullable, nonatomic, copy) void (^failureCompletionBlock)(__kindof SGSBaseRequest *request);

/**
 *  即将开始请求回调闭包
 */
@property (nullable, nonatomic, copy) void (^requestWillStartBlock)(__kindof SGSBaseRequest *request);


/**
 *  即将暂停回调闭包
 *  
 *  @discussion 只有调用 `-suspend` 方法才会触发
 */
@property (nullable, nonatomic, copy) void (^requestWillSuspendBlock)(__kindof SGSBaseRequest *request);

/**
 *  已经暂停回调闭包
 *
 *  @discussion 只有调用 `-suspend` 方法才会触发
 */
@property (nullable, nonatomic, copy) void (^requestDidSuspendBlock)(__kindof SGSBaseRequest *request);


/**
 *  即将停止请求回调闭包
 *
 *  @discussion 当有以下情形时，该闭包将会被调用：
 *      - 请求成功
 *      - 请求失败
 *      - 主动调用 `-stop` 方法停止请求
 *      - 调用 `NSURLSessionTask` 及其子类的 `-cancel` 方法
 *      - 调用 `NSURLSessionDownloadTask` 的 `-cancelByProducingResumeData:` 方法
 */
@property (nullable, nonatomic, copy) void (^requestWillStopBlock)(__kindof SGSBaseRequest *request);

/**
 *  已经停止请求回调闭包，调用情形参考 `requestWillStopBlock` 属性
 */
@property (nullable, nonatomic, copy) void (^requestDidStopBlock)(__kindof SGSBaseRequest *request);

/**
 *  请求进度回调闭包，包括下载进度和上传进度
 */
@property (nullable, nonatomic, copy) void (^progressBlock)(__kindof SGSBaseRequest *request, NSProgress *progress);
```

#### 3.响应数据属性

响应数据属性包括：NSHTTPURLResponse、响应数据、 请求的错误信息等

```
/**
 *  HTTP 响应，当请求失败时可能为 `nil`
 */
@property (nullable, nonatomic, strong) NSHTTPURLResponse *response;

/**
 *  请求响应的原始数据，当响应码为 `204` 或请求失败时可能为 `nil`
 */
@property (nullable, nonatomic, strong) NSData *responseData;

/**
 *  请求错误，当请求失败时将会有值，只要该属性不为空，最终将判断为请求失败
 */
@property (nullable, nonatomic, strong) NSError *error;

/**
 *  响应字符串，默认根据 `responseData` 解析，可通过重写该属性的 getter 方法自定义解析
 */
@property (nullable, nonatomic, copy  , readonly) NSString *responseString;

/**
 *  响应JSON数据，默认根据 `responseData` 解析，可通过重写该属性的 getter 方法自定义解析
 */
@property (nullable, nonatomic, strong, readonly) id responseJSON;

/**
 *  响应模型对象，响应数据转为模型对象的便捷获取方法
 *
 *  @discussion 该属性通过 `-responseObjectClass` 方法获取对象类型
 *      该对象类型需要遵守 `SGSResponseObjectSerializable` 协议
 *      默认根据 `responseJSON` 调用该协议的方法序列化为对象
 *      可通过重写该属性的 getter 方法自定义解析
 */
@property (nullable, nonatomic, strong, readonly) id<SGSResponseObjectSerializable> responseObject;

/**
 *  响应对象数组，响应数据转为模型数组的便捷获取方法
 *
 *  @discussion 该属性通过 `--responseObjectArrayClass` 方法获取对象类型
 *      该对象类型需要遵守 `SGSResponseCollectionSerializable` 协议
 *      默认根据 `responseJSON` 调用该协议的方法序列化为对象
 *      可通过重写该属性的 getter 方法自定义解析
 */
@property (nullable, nonatomic, strong, readonly) NSArray<id<SGSResponseObjectSerializable>> *responseObjectArray;
```

#### 4.操作方法

包括对请求进行执行、暂停、取消等操作的方法，以及设置成功与失败回调block，清空所有block，检查响应状态码等

```

/*!
 *  @abstract 开始请求
 *
 *  @discussion 默认使用 defaultSessionConfiguration 初始化的 AFURLSessionManager 单例
 *      详细参考 `-startWithSessionManager:success:failure:`
 *
 *  @param success 请求成功回调
 *  @param failure 请求失败回调
 */
- (void)startWithCompletionSuccess:(nullable void (^)(__kindof SGSBaseRequest *request))success
failure:(nullable void (^)(__kindof SGSBaseRequest *request))failure;

/**
 *  开始请求
 *
 *  @discussion 可以发起 `GET`, `POST`, `HEAD`, `PUT`, `PATCH`, `DELETE` 请求
 *
 *  如果需要上传，可以在 `constructingBodyBlock` 里添加需要上传的内容，然后用 `POST` 发起请求
 *  如果需要下载，可以直接发起 `GET` 请求，但是不支持断点续传
 *
 *  @param manager AFNetworking 的会话管理类，如果为空等同于调用 `-startWithCompletionSuccess:failure:`
 *  @param success 请求成功回调
 *  @param failure 请求失败回调
 */
- (void)startWithSessionManager:(nullable AFURLSessionManager *)manager
success:(nullable void (^)(__kindof SGSBaseRequest *request))success
failure:(nullable void (^)(__kindof SGSBaseRequest *request))failure;

/*!
 *  @abstract 下载数据，支持断点续传
 *
 *  @discussion 默认使用 defaultSessionConfiguration 初始化的 AFURLSessionManager 单例
 *      详细参考 `-downloadWithSessionManager:success:failure:`
 *
 *  @param success 下载成功回调
 *  @param failure 下载失败回调
 */
- (void)downloadWithCompletionSuccess:(nullable void (^)(__kindof SGSBaseRequest *request))success
failure:(nullable void (^)(__kindof SGSBaseRequest *request))failure;

/**
 *  下载数据，支持断点续传（使用GET请求）
 *
 *  @discussion
 *    1.
 *      在下载请求前，根据下载地址自动判断本地是否有断点数据
 *      如果没有断点数据将重新创建下载请求
 *      如果有断点数据，那么将重新获取本地的断点数据，继续下载
 *
 *      当下载或者断点续传失败时，会在磁盘和缓存中保存这次请求的断点数据
 *      该断点数据是数据概要（因此很小），并非真实下载数据
 *      真实下载数据是 ~/tmp 文件夹中的 CFNetworkDownload_xxxxxx.tmp 文件
 *      如果是后台下载，目录则是 ~/Library/Caches/com.apple.nsurlsessiond/Downloads/(App ID)/CFNetworkDownload_xxxxxx.tmp
 *
 *    2.
 *      由于 `NSURLSession` 使用 download task 下载数据时，数据保存在临时文件夹中，
 *      当数据下载完毕 `NSURLSession` 会自动删除该临时数据，因此使用该方法下载数据时，
 *      可以重写 `-downloadTargetPath` 方法指定保存路径，该方法默认路径为：~/Library/Caches/com.southgis.iMobile.HTTPModule.downloads
 *
 *    3.
 *      如果使用该方法发起多次同样的下载请求，上一次的下载请求将会取消并且保存断点数据，使用断点续传发起新的下载请求
 *
 *      例如：
 *      第一次发起的下载请求的回调
 *      @code
 *          [Adownload downloadWithCompletionSuccess:^(__kindof SGSBaseRequest * _Nonnull request) {
 *              NSLog(@"第一次请求成功");
 *          } failure:nil];
 *      @endcode
 *
 *      第二次发起的下载请求回调
 *      @code
 *          [Adownload downloadWithCompletionSuccess:^(__kindof SGSBaseRequest * _Nonnull request) {
 *              NSLog(@"第二次请求成功");
 *          } failure:nil];
 *      @endcode
 *
 *      此时第二次发起的下载请求将被判断为重复请求，取消第一次下载请求并保存断点数据，再使用断点续传发起第二次下载请求
 *      下载成功后，将会打印"第二次请求成功"，而不是"第一次请求成功"
 *
 *  @param manager AFNetworking 的会话管理类，如果为空等同于调用 `-downloadWithCompletionSuccess:failure:`
 *  @param success 下载成功回调
 *  @param failure 下载失败回调
 */
- (void)downloadWithSessionManager:(nullable AFURLSessionManager *)manager
success:(nullable void (^)(__kindof SGSBaseRequest *request))success
failure:(nullable void (^)(__kindof SGSBaseRequest *request))failure;

/*!
 *  @abstract 开始请求
 *
 *  @discussion 默认使用 defaultSessionConfiguration 初始化的 AFURLSessionManager 单例
 */
- (void)start;

/*!
 *  @abstract 开始请求
 *
 *  @param manager AFNetworking 的会话管理类，如果为空等同于调用 `-start`
 */
- (void)startWithSessionManager:(nullable AFURLSessionManager *)manager;

/*!
 *  @abstract 开始下载，支持断点续传
 *
 *  @discussion 默认使用 defaultSessionConfiguration 初始化的 AFURLSessionManager 单例
 */
- (void)startDownload;

/*!
 *  @abstract 开始下载，支持断点续传
 *
 *  @discussion 参见 `-downloadWithCompletionSuccess:failure:`
 *      由于 `NSURLSession` 使用 download task 下载数据时，数据是保存在临时文件夹中，
 *      当数据下载完毕 `NSURLSession` 会自动删除该临时数据，因此使用该方法下载数据时，
 *      可以重写 `-downloadTargetPath` 方法指定保存路径，该方法默认路径为：~/Library/Caches/com.southgis.iMobile.HTTPModule.downloads
 *
 *  @param manager AFNetworking 的会话管理类，如果为空等同于调用 `-startDownload`
 */
- (void)startDownloadWithSessionManager:(nullable AFURLSessionManager *)manager;

/**
 *  继续执行请求
 */
- (void)resume;

/**
 *  暂停请求
 */
- (void)suspend;

/**
 *  主动停止请求
 */
- (void)stop;

/**
 *  设置请求完毕回调block
 *
 *  @param success 将赋值给 `successCompletionBlock` 属性，在请求成功时回调
 *  @param failure 将赋值给 `failureCompletionBlock` 属性，在请求失败时回调
 */
- (void)setCompletionBlockWithSuccess:(nullable void (^)(__kindof SGSBaseRequest *request))success
failure:(nullable void (^)(__kindof SGSBaseRequest *request))failure;


/**
 *  把所有block属性置为nil来打破循环引用
 */
- (void)clearBlock;


/**
 *  用于检查Status Code是否正常
 *
 *  @return 响应码
 */
- (BOOL)statusCodeValidator;

/**
 *  请求完毕的回调过滤，如果子类不重写，将不做任何处理
 *
 *  @discussion 该方法将在回调前调用，可以通过该方法验证返回的数据是否为有效数据
 *      例如在获取到JSON数据时，验证是否是指定格式的JSON数据
 *      如果获取到非法的JSON数据，可以直接给 `error` 属性赋值自定义的错误信息
 *      在最终执行回调block或代理方法前判断，只要 `error` 属性不为 `nil` ，即视为请求失败
 *
 *      因此可以通过重写该方法验证和过滤数据
 */
- (void)requestCompleteFilter;
```

#### 5.请求参数

子类通过重写这些参数方法来指定不同的网络请求

```
/**
 *  HTTP请求方法，支持 GET/POST/HEAD/PUT/PATCH/DELETE 六种类型
 *  如果子类不重写，默认为GET请求
 */
- (SGSRequestMethod)requestMethod;

/**
 *  请求参数序列化类型，支持：表单、JSON、PList 三种形式
 *  如果子类不重写，默认为表单形式
 */
- (SGSRequestSerializerType)requestSerializerType;


/**
 *  请求基础URL，如果子类不重写，默认返回nil
 */
- (nullable NSString *)baseURL;

/**
 *  请求的URL，如果子类不重写，默认返回@""
 */
- (NSString *)requestURL;

/**
 *  请求的参数列表，如果子类不重写，默认返回nil
 */
- (nullable id)requestParameters;

/**
 *  NSURLRequest 缓存策略，如果子类不重写，默认返回 `NSURLRequestUseProtocolCachePolicy`
 */
- (NSURLRequestCachePolicy)cachePolicy;

/**
 *  请求的连接超时时长，单位为: *秒* ，如果子类不重写，默认为60秒
 */
- (NSTimeInterval)requestTimeout;

/**
 *  网络服务类型，如果子类不重写，默认返回 `NSURLNetworkServiceTypeDefault`
 */
- (NSURLRequestNetworkServiceType)networkServiceType;

/**
 *  是否允许蜂窝网络传输数据，如果子类不重写，默认返回 `YES`
 */
- (BOOL)allowsCellularAccess;

/**
 *  是否允许处理 cookies 数据，如果子类不重写，默认返回 `YES`
 */
- (BOOL)HTTPShouldHandleCookies;

/*!
 *  是否等待之前的响应，如果子类不重写，默认返回 `NO`
 */
- (BOOL)HTTPShouldUsePipelining;

/**
 *  需要认证的 HTTP 请求头的用户名（内部默认进行 Base-64 编码）
 *  如果子类不重写，默认返回nil
 */
- (nullable NSString *)authorizationUsername;

/**
 *  需要认证的 HTTP 请求头的密码（内部默认进行 Base-64 编码）
 *  如果子类不重写，默认返回nil
 */
- (nullable NSString *)authorizationPassword;

/**
 *  请求报头自定义参数，如果子类不重写，默认返回 nil
 */
- (nullable NSDictionary<NSString *, NSString *> *)requestHeaders;

/**
 *  使用自定义的URLRequest发起请求，如果子类不重写，默认返回 `nil`
 *
 *  如果该方法返回非 `nil` 对象，将忽略以下参数：
 *      - requestSerializerType 
 *      - baseURL
 *      - requestURL
 *      - requestParameters
 *      - requestHeaders
 *      - cachePolicy
 *      - requestTimeout
 *      - networkServiceType
 *      - allowsCellularAccess
 *      - HTTPShouldHandleCookies
 *      - HTTPShouldUsePipelining
 *      - requestMethod
 *      - authorizationUsername
 *      - authorizationPassword
 *      - requestHeaders
 *      - constructingBodyBlock
 */
- (nullable NSURLRequest *)customURLRequest;

/**
 *  多部件表单的Block，用于上传，默认为nil
 */
@property (nullable, nonatomic, copy) void (^constructingBodyBlock)(id<AFMultipartFormData> formData);


/*!
 *  下载完毕后需要保存的本地路径
 *
 *  只有调用 `-downloadWithCompletionSuccess:failure:` 或 `-startDownload` 才会生效，
 *      在调用该闭包的同时，会根据 `-removeAlreadyExistsFileWhenDownloadSuccess` 判断是否要先删除已存在的同名文件再进行保存
 *
 *      如果子类不重写，默认返回： [SGSHTTPConfig sharedInstance].downloadDataTempDirectory/response.suggestedFilename
 */
- (nullable NSURL * (^)(NSURL *location, NSURLResponse *response))downloadTargetPath;


/**
 *  发起下载请求时是否忽略断点数据
 *    - YES：将忽略断点数据，始终发起新的下载请求
 *    - NO：如果有断点数据，优先进行断点续传
 *
 *  只有使用 --downloadWithCompletionSuccess:failure: 或 -startDownload 方法才生效
 *
 *  如果子类不重写，默认返回NO
 */
- (BOOL)ignoreResumeData;


/**
 *  可序列化的响应对象类型，如果子类不重写，默认返回nil
 */
- (nullable Class<SGSResponseObjectSerializable>)responseObjectClass;


/**
 *  可序列化的响应对象集合类型，如果子类不重写，默认返回nil
 */
- (nullable Class<SGSResponseCollectionSerializable>)responseObjectArrayClass;
```

#### 6.代理方法

`SGSBaseRequest` 的代理方法放在 `SGSRequestDelegate.h` 头文件中，可以通过代理的形式处理在请求过程的业务

```
@protocol SGSRequestDelegate <NSObject>

@optional

/// 请求完毕
- (void)requestSuccess:(SGSBaseRequest *)request;

/// 请求失败
- (void)requestFailed:(SGSBaseRequest *)request;

/// 请求进度（包括普通请求、上传和下载）
- (void)request:(SGSBaseRequest *)request progress:(NSProgress *)progress;

/// 请求即将开始
- (void)requestWillStart:(SGSBaseRequest *)request;

/// 请求即将暂停
- (void)requestWillSuspend:(SGSBaseRequest *)request;

/// 请求已经暂停
- (void)requestDidSuspend:(SGSBaseRequest *)request;

/// 请求即将停止，包括请求完毕
- (void)requestWillStop:(SGSBaseRequest *)request;

/// 请求已经停止，包括请求完毕
- (void)requestDidStop:(SGSBaseRequest *)request;

@end
```


### SGSBatchRequest

可通过 `SGSBatchRequest`  类批量发起多个请求，并通过 block 或者代理的方式进行回调，回调时机根据 `stopRequestWhenOneOfBatchFails` 属性判断：
* YES：当所有请求都成功返回时，回调 `-batchRequestFinished:` 或 `completionBlock` 。当其中某个请求失败时，会立即终止其余尚未响应的请求，并且回调 `-batchRequestFailed:failedRequest:` 或 `failureBlock`
* NO：当所有请求全部处理完毕时，回调 `-batchRequestFinished:` 或 `completionBlock` ，无论它们请求成功或失败

属性：
```
/// 唯一标识，可以自行设定
@property (nonatomic, assign) NSInteger identifier;

/// 请求数组，即需要批处理的请求
@property (nonatomic, strong, readonly) NSArray<__kindof SGSBaseRequest *> *requestArray;

/// 批处理请求代理
@property (nullable, nonatomic, weak) id<SGSBatchRequestDelegate> delegate;

/// 当批处理中有一个失败时，停止其他请求，默认为 YES
@property (nonatomic, assign) BOOL stopRequestWhenOneOfBatchFails;

/**
 *  所有请求完毕后回调闭包
 *
 *  @discussion 根据 `stopRequestWhenOneOfBatchFails` 不同将会有不同的调用时机
 *      - YES：所有请求都响应成功时才会调用
 *      - NO：所有请求全部处理完毕时回调，无论它们请求成功或失败
 */
@property (nullable, nonatomic, copy) void (^completionBlock)(SGSBatchRequest *batchRequest);

/**
 *  某个请求失败后回调的block
 *
 *  @discussion 只有 `stopRequestWhenOneOfBatchFails` 为 `YES` 并且某个请求失败后才会调用
 */
@property (nullable, nonatomic, copy) void (^failureBlock)(SGSBatchRequest *batchRequest, __kindof SGSBaseRequest *baseRequest);
```

方法：

```
/**
 *  指定实例化方法，已禁用 -new 和 -alloc -init 方法初始化
 */
- (instancetype)initWithRequestArray:(NSArray<__kindof SGSBaseRequest *> *)requestArray NS_DESIGNATED_INITIALIZER;


/**
 *  设置回调闭包并发起批处理请求
 *
 *  @param finished 将赋值给 `completionBlock` 属性
 *  @param failure  将赋值给 `failureBlock` 属性
 */
- (void)startWithCompletionBlock:(nullable void (^)(SGSBatchRequest *batchRequest))finished
failure:(nullable void (^)(SGSBatchRequest *batchRequest, __kindof SGSBaseRequest *baseRequest))failure;



/**
 *  设置回调block
 *
 *  @param finished 将赋值给 `completionBlock` 属性
 *  @param failure  将赋值给 `failureBlock` 属性
 */
- (void)setCompletionBlock:(nullable void (^)(SGSBatchRequest *batchRequest))finished
failure:(nullable void (^)(SGSBatchRequest *batchRequest, __kindof SGSBaseRequest *baseRequest))failure;


/**
 *  把block置nil来打破循环引用
 */
- (void)clearCompletionBlock;


/**
 *  开始执行，可通过代理方法获取完成回调
 */
- (void)start;


/**
 *  停止执行，可通过代理方法获取完成回调
 */
- (void)stop;
```

代理方法：

```
@protocol SGSBatchRequestDelegate <NSObject>

@optional

/**
 *  所有请求全部处理完成
 *
 *  @param batchRequest 批处理
 */
- (void)batchRequestFinished:(SGSBatchRequest *)batchRequest;

/**
 *  某个请求处理失败
 *
 *  @param batchRequest 批处理
 *  @param request      失败的HTTP请求
 */
- (void)batchRequestFailed:(SGSBatchRequest *)batchRequest
             failedRequest:(__kindof SGSBaseRequest *)request;;

@end
```


### SGSChainRequest

当各请求有相互依赖时，可以使用链式请求

链式请求将以此发起HTTP请求，当前一个请求有响应时，再执行下一个请求

如果中途某个请求失败，后面的请求将不会执行，但请求队列依旧保持着。如果此时继续发起请求，那么会从上一次失败的节点重新发起请求


属性和方法：

```
/**
 *  代理
 */
@property (nullable, nonatomic, weak) id<SGSChainRequestDelegate> delegate;

/**
 *  开始执行链式请求
 */
- (void)start;

/**
 *  终止链式请求
 */
- (void)stop;

/**
 *  添加请求
 *
 *  @discussion 添加的请求成功返回时，将会执行 `callback`
 *      如果请求失败，将会执行链式请求的失败代理方法
 *
 *  @param request  待处理的请求
 *  @param callback 添加的请求响应成功时回调的闭包
 */
- (void)addRequest:(__kindof SGSBaseRequest *)request callback:(nullable ChainCallback)callback;

/**
 *  请求队列
 *
 *  @return 请求队列
 */
- (NSArray<__kindof SGSBaseRequest *> *)requestQueue;
```

代理：

```
@protocol SGSChainRequestDelegate <NSObject>

@optional

/**
 *  链式请求全部执行完毕
 *
 *  @param chainRequest 链式请求
 */
- (void)chainRequestFinished:(SGSChainRequest *)chainRequest;

/**
 *  某个请求处理失败的代理方法
 *
 *  @param chainRequest 链式请求
 *  @param request      HTTP请求
 */
- (void)chainRequestFailed:(SGSChainRequest *)chainRequest
         failedBaseRequest:(__kindof SGSBaseRequest *)request;

@end
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

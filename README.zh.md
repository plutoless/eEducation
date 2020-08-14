> *Read this article in another language: [English](README.md)*

## 目录
- [项目概述](https://github.com/AgoraIO-Usecase/eEducation/blob/master/README.zh.md#%E9%A1%B9%E7%9B%AE%E6%A6%82%E8%BF%B0)
  - [支持场景](https://github.com/AgoraIO-Usecase/eEducation/blob/master/README.zh.md#%E6%94%AF%E6%8C%81%E5%9C%BA%E6%99%AF)
  - [功能列表](https://github.com/AgoraIO-Usecase/eEducation/blob/master/README.zh.md#%E5%8A%9F%E8%83%BD%E5%88%97%E8%A1%A8)
  - [平台兼容](https://github.com/AgoraIO-Usecase/eEducation/blob/master/README.zh.md#%E5%B9%B3%E5%8F%B0%E5%85%BC%E5%AE%B9)
  - [限制条件](https://github.com/AgoraIO-Usecase/eEducation/blob/master/README.zh.md#%E9%99%90%E5%88%B6%E6%9D%A1%E4%BB%B6)
- [快速开始](https://github.com/AgoraIO-Usecase/eEducation/blob/master/README.zh.md#%E5%BF%AB%E9%80%9F%E5%BC%80%E5%A7%8B)
  - [前提条件](https://github.com/AgoraIO-Usecase/eEducation/blob/master/README.zh.md#%E5%89%8D%E6%8F%90%E6%9D%A1%E4%BB%B6)
    - [获取声网 App ID](https://github.com/AgoraIO-Usecase/eEducation/blob/master/README.zh.md#%E8%8E%B7%E5%8F%96%E5%A3%B0%E7%BD%91-app-id)
    - [进行 HTTP 基本认证](https://github.com/AgoraIO-Usecase/eEducation/blob/master/README.zh.md#%E8%BF%9B%E8%A1%8C-http-%E5%9F%BA%E6%9C%AC%E8%AE%A4%E8%AF%81)
    - [获取第三方白板 sdkToken 并注册到Agora云服务](https://github.com/AgoraIO-Usecase/eEducation/blob/master/README.zh.md#获取第三方白板-sdkToken-并注册到Agora云服务)
  - [运行示例项目](https://github.com/AgoraIO-Usecase/eEducation/blob/master/README.zh.md#%E8%BF%90%E8%A1%8C%E7%A4%BA%E4%BE%8B%E9%A1%B9%E7%9B%AE)
  - [接入 Agora Edu 云服务](https://github.com/AgoraIO-Usecase/eEducation/blob/master/README.zh.md#%E6%8E%A5%E5%85%A5-agora-edu-%E4%BA%91%E6%9C%8D%E5%8A%A1)
- [常见问题](https://github.com/AgoraIO-Usecase/eEducation/blob/master/README.zh.md#%E5%B8%B8%E8%A7%81%E9%97%AE%E9%A2%98)
- [推荐 SDK 版本](https://github.com/AgoraIO-Usecase/eEducation/blob/master/README.zh.md#%E6%8E%A8%E8%8D%90-SDK-%E7%89%88%E6%9C%AC)

## 项目概述

Agora e-Education 是声网专为教育行业提供的示例项目，演示了如何通过 Agora Edu 云服务，并配合 Agora RTC SDK、Agora RTM SDK、Agora 云端录制和第三方 Netless 白板 SDK，快速实现基本的在线互动教学场景。

### 支持场景

Agora e-Education 示例项目支持以下教学场景：

- 1 对 1 互动教学：1 位老师对 1 名学生进行专属在线辅导教学，老师和学生能够进行实时音视频互动。
- 1 对 N 在线小班课：1 位教师对 N 名学生（2 ≤ N ≤ 16）进行在线辅导教学，老师和学生能够进行实时音视频互动。
- 互动直播大班课：一名老师进行教学，多名学生实时观看和收听，学生人数无上限。与此同时，学生可以“举手”请求发言，与老师进行实时音视频互动。

### 功能列表

| 功能                   | Web（老师端） | Web（学生端）                                                | iOS 和 Android（学生端）                                       | 备注                                                         |
| :--------------------------------------- | :------------ | :----------------------------------------------------------- | :---------------------------------------------------------- | :----------------------------------------------------------- |
| 实时音视频互动                           | ✔             | ✔                                                            | ✔                                                           | /                                                            |
| 文字聊天                                 | ✔             | ✔                                                            | ✔                                                           | /                                                             |
| 互动白板                             | ✔             | ✔ 1 对 1 互动教学<p> ✔ 1 对 N 在线小班课<p>✘ 互动直播大班课 | ✔ 1 对 1 互动教学<p>✔ 1 对 N 在线小班课<p>✘ 互动直播大班课 | <li>1 对 1 互动教学中，学生和老师默认都可以操作白板。<li>1 对 N 在线小班课中，学生默认没有权限操作白板，老师可以授权学生操作白板。<li>互动直播大班课中，学生不能操作白板，只能观看。        |
| 白板跟随                                 | ✔             | ✔                                                            | ✔                                                           | 老师端点击白板跟随后，学生的白板视野跟随老师的白板。          |
| 教学文件上传（PPT、Word、PDF、音视频等） | ✔             | ✘                                                            | ✘                                                           | 老师端上传文件，学生端只能观看。                                   |
| 举手连麦                           | ✔             | ✔                                                            | ✔                                                           | 互动直播大班课中，学生“举手”请求发言，老师同意或取消。             |
| 屏幕共享                                 | ✔             | ✔                                                            | ✔                                                           | 老师端发起屏幕共享，学生端只能观看。                           |
| 录制回放                                 | ✔             | ✔                                                            | ✔                                                           | 老师端开启录制，**需要录制至少 15 秒**。录制结束后链接会显示在聊天消息里面，点击链接即可跳转到回放页面。 |

### 平台兼容

Agora e-Education 示例项目支持以下平台和版本：

- iOS 10 及以上。iOS 9 系列版本未经验证。
- Android 4.4 及以上。
- Web Chrome 72 及以上，Web 其他浏览器未经验证。

### 限制条件
详见[限制条件](https://github.com/AgoraIO-Usecase/eEducation/wiki/%E9%99%90%E5%88%B6%E6%9D%A1%E4%BB%B6)。

## 快速开始

### 前提条件

在编译及运行 Agora e-Education 示例项目之前，你需要完成以下准备工作。

#### 获取声网 App ID
通过以下步骤获取声网 App ID：
  1. 在声网[控制台](https://sso.agora.io/v2/signup)创建一个账号。
  2. 登录声网控制台，创建一个项目，鉴权方式选择 **“App ID + App 证书 + Token”**。注意，请确保该项目启用了 [App 证书](https://docs.agora.io/cn/Agora%20Platform/token?platform=All%20Platforms#appcertificate)。
  3. 前往**项目管理**页面，获取该项目的 App ID。

#### 进行 HTTP 基本认证

在使用 RESTful API 时，你需要使用声网提供的 Customer ID 和 Customer Certificate 通过 Base64 算法编码生成一个 Authorization 字段，填入 HTTP 请求头部，进行 HTTP 基本认证。详见[具体步骤](https://docs.agora.io/cn/faq/restful_authentication)。

#### 获取第三方白板 sdkToken 并注册到Agora云服务
通过以下步骤获取第三方白板 `sdkToken`：
1. 在 [Netless 控制台](https://console.herewhite.com/en/register/)创建一个账号。
2. 登录 Netless 控制台，前往**密钥管理**页面，获取 `sdkToken`。

你需要将白板的 `sdkToken` 注册到Agora云服务器中。
1. 打开[Agora控制台](https://Console.Agora.io/)
2. 编辑**项目管理**，移动功能模块，找到白板token，点击“更新token”进行注册。

### 运行示例项目

参考以下文档在对应的平台编译及运行示例项目：

- [Android 运行指南](https://github.com/AgoraIO-Usecase/eEducation/blob/master/education_Android/AgoraEducation/README.zh.md)
- [iOS 运行指南](https://github.com/AgoraIO-Usecase/eEducation/tree/master/education_iOS/README.zh.md)
- [Web & Electron 运行指南](https://github.com/AgoraIO-Usecase/eEducation/tree/master/education_web/README.zh.md)

### 接入 Agora Edu 云服务

Agora Edu 云服务是声网为后端开发能力稍弱的开发者提供的教室后台管理服务。接入后，你无需自研教育后台业务，通过调用 RESTful API 就能轻松快速实现教室状态管理、权限控制等功能。详见 [Agora Edu 云服务文档](https://github.com/AgoraIO-Usecase/eEducation/wiki/Agora-Edu-%E4%BA%91%E6%9C%8D%E5%8A%A1)。

## 常见问题
详见[常见问题](https://github.com/AgoraIO-Usecase/eEducation/wiki/%E5%B8%B8%E8%A7%81%E9%97%AE%E9%A2%98)。

## 推荐 SDK 版本

对于 Agora RTC Native SDK，声网专为教育行业用户而量身打磨了高稳定性的版本，下载链接如下：
- [Android 端最新的教育专版 SDK](https://docs-preview.agoralab.co/cn/Interactive%20Broadcast/edu_release_note_android)
- [iOS 端最新的教育专版 SDK](https://docs-preview.agoralab.co/cn/Interactive%20Broadcast/edu_release_note_ios)
- [macOS 端最新的教育专版 SDK](https://docs-preview.agoralab.co/cn/Interactive%20Broadcast/edu_release_note_macos)
- [Windows 端最新的教育专版 SDK](https://docs-preview.agoralab.co/cn/Interactive%20Broadcast/edu_release_note_windows)
- [Electron 端最新的教育专版 SDK](https://docs-preview.agoralab.co/cn/Interactive%20Broadcast/edu_release_note_electron)

对于 Agora RTC Web SDK，请下载[官网最新版 SDK](https://docs.agora.io/cn/Agora%20Platform/downloads)。

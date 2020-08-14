> *Read this in another language: [English](README.md)*

# !!重要!!如果你修改了.env.local，你可能需要删除一下node_modules/.cache以确保配置得到更新

## 概览

|支持场景|代码入口|功能描述|
| ---- | ----- | ----- |
|1 对 1 互动教学 | [one-to-one.tsx](https://github.com/AgoraIO-Usecase/eEducation/blob/master/education_web/src/pages/classroom/one-to-one.tsx) | 1 个老师和 1 个学生默认以主播角色进入教室 |
|1 对 N 在线小班课| [small-class.tsx](https://github.com/AgoraIO-Usecase/eEducation/blob/master/education_web/src/pages/classroom/small-class.tsx) | 1个老师和最多 16 个学生默认以主播角色进入教室 |
|互动直播大班课| [big-class.tsx](https://github.com/AgoraIO-Usecase/eEducation/blob/master/education_web/src/pages/classroom/big-class.tsx) | 1个老师默认以主播角色进入教室，学生默认以观众角色进入教室，学生人数无限制 |

### 在线体验

[web demo](https://solutions.agora.io/education/web/)

### 使用的 SDK

- agora-rtc-sdk（声网 RTC Web SDK）
- agora-rtm-sdk（声网实时消息 Web SDK）
- agora-electron-sdk（声网官方 electron sdk）
- white-web-sdk（Netless 官方白板 sdk）
- ali-oss（可替换成你自己的 oss client）
- 声网云录制 （建议在服务端集成）

### 使用的技术
- typescript 3.8.3
- react & react hooks & rxjs
- electron 7.1.14 & electron-builder
- material-ui
- Agora Edu 云服务

## 准备工作

- 请确保你已经完成 [Agora e-Education 项目指南](https://github.com/AgoraIO-Usecase/eEducation/blob/master/README.zh.md)中的前提条件。
- 配置阿里云 OSS，详见[阿里云OSS配置指南](https://github.com/AgoraIO-Usecase/eEducation/wiki/%E9%98%BF%E9%87%8C%E4%BA%91OSS%E9%85%8D%E7%BD%AE%E6%8C%87%E5%8D%97)。
- 可以从[这里](https://github.com/AgoraIO-Usecase/eEducation/blob/master/README.zh.md#%E5%89%8D%E6%8F%90%E6%9D%A1%E4%BB%B6)开始配置appId sdkToken restful token 
- 重命名 `.env.example` 为 `.env.local`，并配置以下参数：
   - **（必填）声网 App ID**
   ```bash
   # 声网的 App ID
   REACT_APP_AGORA_APP_ID=agora appId
   # 开启声网前端日志
   REACT_APP_AGORA_LOG=true
   ELECTRON_START_URL=http://localhost:3000
   ```
   - **（必填）声网 HTTP basic 认证 Authorization 字段**
   ```
   # 声网 HTTP basic 认证 Authorization 字段
   REACT_APP_AGORA_RESTFULL_TOKEN=agora_restful_api_token
   ```
   - **（选填）适用于白板课件服务，如不需要可以直接按照下列配置**
   ```bash
   # 你自己的 OSS bucket name
   REACT_APP_YOUR_OWN_OSS_BUCKET_NAME=your_oss_bucket_name
   # 你自己的 OSS bucket folder
   REACT_APP_YOUR_OWN_OSS_BUCKET_FOLDER=your_oss_bucket_folder
   # 你自己的 OSS bucket region
   REACT_APP_YOUR_OWN_OSS_BUCKET_REGION=your_bucket_region
   # 你自己的 OSS bucket access key
   REACT_APP_YOUR_OWN_OSS_BUCKET_KEY=your_bucket_ak
   # 你自己的 OSS bucket access secret key
   REACT_APP_YOUR_OWN_OSS_BUCKET_SECRET=your_bucket_sk
   # 你自己的 OSS bucket access endpoint
   REACT_APP_YOUR_OWN_OSS_CDN_ACCELERATE=your_cdn_accelerate_endpoint
   ```
   - **（选填）用于 RTM 前端回放展示能力，不推荐生产上直接使用。如不需要可以直接按照下列配置**
   ```
   # 声网开发者 Customer ID
   REACT_APP_AGORA_CUSTOMER_ID=customer_id
   # 声网开发者 Customer Certificate
   REACT_APP_AGORA_CUSTOMER_CERTIFICATE=customer_certificate
   # 声网开发者 rtm restful api 接口，仅供demo展示（请在自己的服务端接入）
   REACT_APP_AGORA_RTM_ENDPOINT=your_server_rtm_endpoint_api
   ```

- 中国区客户推荐使用以下方式安装 npm 依赖包和 electron & node-sass 加速
  > 我们建议使用 npm 而非 yarn 或 cnpm
  ```
  # 仅适用于中国区客户
  # macOS
  export ELECTRON_MIRROR="https://npm.taobao.org/mirrors/electron/"
  export ELECTRON_CUSTOM_DIR="7.1.14"
  export SASS_BINARY_SITE="https://npm.taobao.org/mirrors/node-sass/"
  export ELECTRON_BUILDER_BINARIES_MIRROR="https://npm.taobao.org/mirrors/electron-builder-binaries/"

  # Windows
  set ELECTRON_MIRROR=https://npm.taobao.org/mirrors/electron/
  set ELECTRON_CUSTOM_DIR=7.1.14
  set ELECTRON_BUILDER_BINARIES_MIRROR=https://npm.taobao.org/mirrors/electron-builder-binaries/
  set SASS_BINARY_SITE=https://npm.taobao.org/mirrors/node-sass/

  npm install --registry=https://registry.npm.taobao.org
  ```

- 安装 Node.js LTS

## 运行和发布 Web demo

1. 安装 npm

   ```
   npm install
   ```

2. 本地运行 Web demo

   ```
   npm run dev
   ```
3. 发布 Web demo。发布前需要修改 `package.json` 中的 "homepage": "你的域名/地址"。例如，`https://solutions.agora.io/education/web` 需修改为 `"homepage": "https://solutions.agora.io/education/web"` 

   ```
   npm run build
   ```

## 运行和发布 Electron demo

### macOS
1. 安装 npm

   ```
   npm install
   ```
2. 本地运行 Electron demo

   ```
   npm run electron  
   ```

2. 发布 Electron demo

   ```
   npm run pack:mac
   ```

成功运行结束后会生成一个 release 目录，里面包含一个 dmg 安装文件，正常打开移动到 Application 目录即可完成安装，然后可以执行程序。 

### Windows
1. 安装 electron 7.1.14: 先找到 `package.json` 里的 `agora_electron` 按照如下结构替换
   ```
   "agora_electron": {
     "electron_version": "7.1.2",
     "prebuilt": true,
     "platform": "win32"
   },
   ```
   再手动安装 electron 7.1.14
   ```
   npm install electron@7.1.14 --arch=ia32 --save-dev
   ```
2. 安装 npm
   ```
   npm install
   ```

3. 本地运行 Electron demo

   ```
   npm run electron  
   ```

4. 发布 Electron demo

   ```
   npm run pack:win
   ```

成功运行结束后会生成一个 release 目录，里面包含一个 exe 安装程序，请使用 Windows 管理员身份打开，即可完成安装，然后可以执行程序。

## 常见问题 
- 如果你在运行 Electron 时发现 localhost:3000 端口被占用，可以在 `package.json` 里找到 `ELECTRON_START_URL=http://localhost:3000` 修改成你本地可以使用的端口号。 

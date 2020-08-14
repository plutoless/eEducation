> *其他语言版本：[简体中文](README.zh.md)*

## Table of contents
- [About the project](https://github.com/AgoraIO-Usecase/eEducation#about-the-project)
  - [Applicable scenarios](https://github.com/AgoraIO-Usecase/eEducation#applicable-scenarios)
  - [Functions](https://github.com/AgoraIO-Usecase/eEducation#functions)
  - [Compatibility](https://github.com/AgoraIO-Usecase/eEducation#compatibility)
  - [Restrictions](https://github.com/AgoraIO-Usecase/eEducation#restrictions)
- [Get started](https://github.com/AgoraIO-Usecase/eEducation#get-started)
  - [Prerequisites](https://github.com/AgoraIO-Usecase/eEducation#prerequisites)
    - [Get an Agora App ID](https://github.com/AgoraIO-Usecase/eEducation#get-an-agora-app-id)
    - [Pass the basic HTTP authentication](https://github.com/AgoraIO-Usecase/eEducation#pass-the-basic-http-authentication)
    - [Get a Netless  `sdkToken` and register with Agora Cloud Service](https://github.com/AgoraIO-Usecase/eEducation#get-a-netless--sdktoken-and-register-with-agora-cloud-service)
  - [Run the sample project](https://github.com/AgoraIO-Usecase/eEducation#run-the-sample-project)
  - [Use Agora Edu Cloud Service](https://github.com/AgoraIO-Usecase/eEducation#use-agora-edu-cloud-service)
- [FAQ](https://github.com/AgoraIO-Usecase/eEducation#faq)
- [Recommended versions of the Agora RTC SDK](https://github.com/AgoraIO-Usecase/eEducation#recommended-versions-of-the-agora-rtc-sdk)

## About the project

Agora e-Education is a sample project provided by Agora for developers in the education industry, which demonstrates how to use **Agora Edu Cloud Service**, **Agora RTC SDK**, **Agora RTM SDK**, **Agora Cloud Recording**, and the third-party Netless whiteboard SDK to quickly implement basic online interactive tutoring scenarios.

### Applicable scenarios

Agora e-Education supports the following scenarios:

- One-to-one Classroom: An online teacher gives an exclusive lesson to only one student, and both can interact in real time.
- Small Classroom: A teacher gives an online lesson to multiple students, and both the teacher and students can interact with each other in real time. The number of students in a small classroom should not exceed 16.
- Lecture Hall: Thousands of students watch an online lecture together. Students can "raise their hands" to interact with the teacher, and their responses are viewed by all the other students at the same time.

### Functions

| Function                    | Web (Teacher) | Web (Student)                                           | iOS and Android (Student)                                   | Note                                                         |
| :--------------------------------------- | :------------ | :----------------------------------------------------------- | :---------------------------------------------------------- | :----------------------------------------------------------- |
| Real-time audio and video communication                   | ✔             | ✔                                                | ✔                                                           | /                                                            |
| Real-time messaging                     | ✔             | ✔                                                            | ✔                                                           | /             |
| Interactive Whiteboard                             | ✔             | ✔ One-to-one Classroom<p> ✔ Small Classroom<p>✘ Lecture Hall | ✔One-to-one Classroom<p>✔ Small Classroom<p>✘ Lecture Hall | <li>In a one-to-one classroom, both the teacher and students can draw on the whiteboard by default.<li>In a small classroom, students cannot draw on the whiteboard by default, but the teacher can give a student the permission of drawing on the whiteboard.<li>In a lecture hall, students can never draw on the whiteboard. |
| Whiteboard follow               | ✔             | ✔                                                            | ✔                                                           | The teacher can enable "whiteboard follow". When the teacher is moving the whiteboard or turning pages, the whiteboard area that students see will be consistent with the teacher's whiteboard area.|
| Uploading files (PPT, Word, PDF, audio files or video files) | ✔             | ✘                                                            | ✘                                                           | Only teachers can upload files to the classroom. |
| Students raising hands                           | ✔             | ✔                                                            | ✔                                                           | In a lecture hall, students do not send their audio and video by default, but they can "raise their hands" to apply for interacting with the teacher. The teacher can approve or decline the application. |
| Screen sharing                    | ✔             | ✔                                                            | ✔                                                           | The teacher can share the screen.                           |
| Recording and replay                                 | ✔             | ✔                                                            | ✔                                                           | The teacher can start recording and record the class **for at least 15 seconds**. After the recording finishes, a link for replaying the class will be displayed in the message box. |

### Compatibility

 Agora e-Education supports the following platforms and versions: 

- iOS 10 or later. We do not test Agora e-Education on iOS 9 updates.
- Android 4.4 and later.
- Web Chrome 72 and later. We do not test Agora e-Education on browsers.

### Restrictions
See [Restrictions](https://github.com/AgoraIO-Usecase/eEducation/wiki/Restrictions).

## Get started

### Prerequisites 

Make sure you make the following preparations before compiling and running the sample project.

#### Get an Agora App ID
Follow these steps to get an Agora App ID:
  1. Create an account in [Agora Console](https://sso.agora.io/v2/signup).
  2. Log in to Agora Console and create a project. Select **"App ID + App Certificate + Token"** as your authentication mechanism when creating the project. Make sure that you enable the [App Certificate](https://docs.agora.io/en/Agora%20Platform/token?platform=All%20Platforms#appcertificate) of this project.
  3. Get the App ID of this project in **Project Management** page.

#### Pass the basic HTTP authentication

Before using the Agora RESTful APIs, you need to generate the `Authorization` parameter with the Customer ID and Customer Certificate provided by Agora and pass the `Authorization` parameter in the HTTP request header for authentication. For details, see the [steps of basic HTTP authentication](https://docs.agora.io/en/faq/restful_authentication).

#### Get a Netless  `sdkToken` and register with Agora Cloud Service
Follow these steps to get a Netless whiteboard  `sdkToken`:
1. Create an account in [Netless Console](https://console.herewhite.com/en/register/).
2. Log in to Netless Console and get the `sdkToken` in the **Key management** page.

You need to register the sdkToken of the whiteboard to the Agora cloud server.
1. Open[Agora Console](https://console.agora.io/)
2. Edit**Project Management**, select the function module and click "update the token" to register.

### Run the sample project

See the following documents to compile and run the sample project:

- [Run the Android project](https://github.com/AgoraIO-Usecase/eEducation/tree/master/education_Android/AgoraEducation)
- [Run the iOS project](https://github.com/AgoraIO-Usecase/eEducation/tree/master/education_iOS)
- [Run Web and Electron project](https://github.com/AgoraIO-Usecase/eEducation/tree/master/education_web)

### Use Agora Edu Cloud Service

Agora provides Agora Edu Cloud Service for developers who are not good at back end development. You can call the RESTful APIs of Agora Edu Cloud Service to quickly implement managing the states of classrooms and the permissions of users on the back end. For details, see [Agora Edu Cloud Service](https://github.com/AgoraIO-Usecase/eEducation/wiki/Agora-Edu-Cloud-Service).

## FAQ

See [Trouble Shooting](https://github.com/AgoraIO-Usecase/eEducation/wiki/Trouble-Shooting).

## Recommended versions of the Agora RTC SDK

Agora provides high-stability versions of the Agora RTC Native SDK for companies in the education industry. The educational special versions are developed based on the Agora RTC SDK v2.9.0.

- [Android](https://docs-preview.agoralab.co/cn/Interactive%20Broadcast/edu_release_note_android?platform=Android)
- [iOS](https://docs-preview.agoralab.co/cn/Interactive%20Broadcast/edu_release_note_ios?platform=iOS)
- [macOS](https://docs-preview.agoralab.co/cn/Interactive%20Broadcast/edu_release_note_macos?platform=macOS)
- [Windows](https://docs-preview.agoralab.co/cn/Interactive%20Broadcast/edu_release_note_windows?platform=Windows)
- [Electron](https://docs-preview.agoralab.co/cn/Interactive%20Broadcast/edu_release_note_electron?platform=Electron)

For the Agora RTC Web SDK, download the [latest version](https://docs.agora.io/en/Agora%20Platform/downloads) on Agora Developer Portal.

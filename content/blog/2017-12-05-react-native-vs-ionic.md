---
layout: post
title: "React Native vs Ionic - A Quick Comparison"
author: "@codehakase"
imagefeature: "https://cdn.scotch.io/23499/HDDv8v7TRhqt4ao1nwfH_React_Native_vs_Ionic_m5b5ol.png.jpg"
description: "Demistifying the differences between Ionic and React Native"
modified: 2017-12-05
tags: [ionic, react-native]
share: true
category: javascript
comments: true
---
!["React Native vs Ionic"](https://cdn.scotch.io/23499/HDDv8v7TRhqt4ao1nwfH_React_Native_vs_Ionic_m5b5ol.png.jpg )

The main purpose of this article, is to highlight the important differences between Ionic and React Native. Developers utilize a variety of tools. There's always an unending discussion and argument on which platform is best, as every developer has her own personal preferences. Hopefully this article would give you the information you'll need to make a decision on which you'd want to settle for in your next mobile app project.

## Native vs Hybrid apps
We're going to journey smoothly on pointing out the differences between Ionic and React Native after we note the difference between a Native and a Hybrid app.

Hybrid apps are websites/web apps embedded in a mobile app through what we call a webview. They are developed using web technologies like HTML5, CSS, and JavaScript, and execute the same code regardless of the platform in which they run. They can, with tools like PhoneGap, to use the native features of a device, like bluetooth or camera.

Native apps are developed in the language required by the platform it targets, Objective-C or Swift for iOS, Java for Android, etc. The code written is not shared across platforms and their behavior varies. They have direct access to all features offered by the platform without any restriction.

## Ionic vs React Native - Differences

### Ionic
Ionic is a typical hybrid development framework. It uses web technologies to write and render the application, and requires PhoneGap/Cordova bridges to access native features. Then it will try to reproduce native behaviors to provide the best user experience.

### React Native
Developing in React Native is primarily done with JavaScript, which means most of the code you need to get started can be shared across platforms. However, where hybrid apps render using HTML and CSS, React Native will render using native components. In React Native, you can choose to write in Native code (Objective-C or Java) based on the feature you want to optimize.

### Hello world in Ionic
```html

<!-- Template -->
<ion-navbar *navbar>
  <ion-title>
    Home
  </ion-title>
</ion-navbar>

<ion-content class="home">
  <ion-card>
    <ion-card-header>
      Card Header
    </ion-card-header>
    <ion-card-content>
      Hello World, Man's not Hot!!!
    </ion-card-content>
  </ion-card>
</ion-content>
```

### Hello world in React Native
```javascript
import React from 'react'
import {
  AppRegistry,
  Text,
  View
} from 'react-native'

class App extends React.Component
{
  render() {
    return(
      <View>
    <Text>Hello World!</Text>
      </View>
   );
  }
}

AppRegistry.registerComponent('App', () => App)
```

## Write once, run anywhere?
### Ionic
Hybrid apps, are meant to run the same code on any platform, and that is what Ionic is capable of doing. However, in order to feel more “native”, Ionic will adapt a few of its behaviors according to the platform.

### React Native
React focuses on the use of components which best follow the native behaviors of the platform. For example, Android has a highly customizable toolbar; iOS does not. You can use the component for the toolbar on Android but you’ll have to use something different for iOS.

## Community & Plugins
When I choose an Open Source project to use, I find it very important to assess how the community is backing such project. This directly impacts how easily you can find information online, answers to your questions, or getting bugs fixed.

### Ionic
At the point of this writing, The Ionic project on [https://github.com/ionic-team/ionic](Github), has over 6k commits, 30 branches, **32,264** stars, 108 releases, and 252 contributors. Ionic also have hundreds on plugins on npm that adds to bringing more native feel to Ionic apps.

### React Native
Also, at the point of this writing, The React Native project on [https://github.com/facebook/react-native](Github), has over 12k commits, 56 branches, **56,007** stars, 233 releases, and **1,531** contributors. React native have hundreds on plugins available on npm.

## Conclusion
In the cross-platform app development worlds, Ionic and React Native are the developer's best choices. Its really hard to say which is better than the other, its all a matter of preference.

From my personal prespective, React Native has these advantages over Ionic:
- React Native gives you more Native feel compared to a hybrid app
- React Native's native rendering, is faster compared to Ionic's

But anyway, the best way to choose the best tool for resolving particular issues is to test different options. So, try them both to make a choice.

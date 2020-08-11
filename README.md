# HLS_demo
A demo for playing M3U8 by AVPlayer in Swift.  
Streaming demo for reading url from M3U8 string.  

## Check  
If you want to access http(without s) url,   
make sure you have set "App Transport Security Settings" and "Allow Arbitrary Loads" to "YES".  
  
## What we do?  
Here we set M3U8 url to AVPlayer.  
Use play() / pause() to set player.  
AVPlayer does not have "stop", just to pause it and set it to nil.  

## Get duration for video  
We get total duration by  
```swift
videoPlayer.currentItem?.asset.duration  
```
And get current playing time by
```swift
videoPlayer?.addPeriodicTimeObserver(forInterval: CMTime(seconds: Double(1), preferredTimescale: 2), queue: DispatchQueue.main), using: {})
```

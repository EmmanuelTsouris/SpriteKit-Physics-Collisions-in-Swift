# SpriteKit Physics Collisions in Swift

I originally wrote this to learn Swift 1.x. I've since updated and cleaned it up for Swift 2.x and Xcode 7.

The code and architecture based on the original Objective-C [SpriteKit Physics Collisions](https://developer.apple.com/library/mac/samplecode/SpriteKit_Physics_Collisions/Introduction/Intro.html) sample from Apple.

Some of the differences in this version from the Apple code, includes breaking out the constants into a seperate swift file, as well as a few other minor organizational changes.

## Player Controls

* w or forward arrow :  **accelerate forward**
* a or left arrow    :  **turn left**
* d or right arrow   :  **turn right**
* s or back arrow    :  **accelerate backwards**
* space bar          :  **fire a missile**
* r                  :  **reset the simulation**

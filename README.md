# Process
A project management app designed to allow users to collaborate on multiple projects simultaneously through custom tasks. It allows you to specify which tasks need to be done before others, and enhances productivity by generating possible orders in which to complete them. Process can also infer how long a task will take to complete based on the user’s completion time for similar tasks.

# Notes

This was mainly a summer project, and the last task I set out to complete was to fix a UI bug where views would flicker due to being recalculated redundantly or at the wrong times. I found out that it was due to poor use of the SwiftUI combine features, such as `@EnvironmentObject`. I started fixing it but then school happened, so I am sorry if anything you see hurts your eyes -- I do not plan on keeping it around.

If right now you are saying 'hmph, this is why branches exist," I agree. However, sorry or not, time doesn't grow on trees lately; I also wish my project was perfectly developed.

# Video Explanation of Technical Features

Here is a snippet of a little presentation I made for this app (don't be scared by the moldy thumbnail, quality gets better after a few seconds). You can view/download it in better quality through [this Google Drive link](https://drive.google.com/file/d/1J0gPdP4TA8VprA-1Qt904_b0OT0EuprH/view?usp=sharing).


https://user-images.githubusercontent.com/69845191/187618176-063ef314-bef3-44c2-a81f-7092969559ef.mp4


# Credits

## UI frameworks and components
* [SwiftUI](https://developer.apple.com/xcode/swiftui/): Apple’s fairly recent declarative framework for building user interfaces
* [Combine](https://developer.apple.com/documentation/combine): Provides a way of processing values over time, allowing for the representation of asynchronous events
* [SwiftUIX](https://github.com/SwiftUIX/SwiftUIX): Provides UIKit-like components for SwiftUI (pending integration)
* [ActionButton](https://github.com/swiftui-library/action-button): Convenient button component
* [SwiftUIBanner](https://github.com/jboullianne/SwiftUIBanner): Basic banner component (modified)
* [FloatingButton](https://swiftuirecipes.com/blog/floating-action-button-in-swiftui): Round Android-like button component (modified)
* [GridView](https://github.com/Q-Mobile/QGrid): CollectionView equivalent in SwiftUI (pending integration)

## SDKs
* [Firebase Auth](https://firebase.google.com/docs/auth): Authentication kit
* [Firebase Firestore](https://firebase.google.com/docs/firestore?authuser=0): Real time NoSQL cloud database kit
* [Firebase Analytics](https://firebase.google.com/docs/analytics): Integration with Google Analytics
* [Firebase Storage](https://firebase.google.com/docs/storage): Storage and servicing of large user generated files such as images

## Resources
* [Login image](https://www.freepik.com/free-vector/colleagues-working-together-project_9174459.htm#query=people%20working&position=12&from_view=search)
* [Registration image](https://www.freepik.com/free-vector/businessman-holding-pencil-big-complete-checklist-with-tick-marks_11879344.htm#query=register&position=0&from_view=search)

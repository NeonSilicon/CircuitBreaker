# CircuitBreaker iOS AUv3

CircuitBreaker is a small demonstration project. They primary purpose of the project is to investigate how to solve issues with code signing and project configuration for an open source project developed in Xcode and hosted on GitHub.

The deliverable part of the project is an AUv3 that provides for a safety hard clip at a specified volume level. The GUI is minimal and the container app for the AUv3 does absolutely nothing. Its only purpose is to allow for the installation of the audio unit on the device.

## Project Organization 

The Xcode project is in the CircuitBreaker subdirectory of the directory that contains this README.md file.

the *setup.sh* script should be run before opening the project in Xcode. Setup.sh will build a directory named Xcode_Config that contains a file named DeveloperSettings.xcconfig using information that is provided to the script when it is executed. The Xcode_Config directory is excluded from the Git repository in the .gitignore file. The point of doing this is that it insures that the developer signing data is not checked into the git repo. The configuration also allows for providing the organization identifier and the four character manufacturer code for the AUv3.

Once the script has been run, you can directly edit the Xcode_Config/DeveloperSettings.xcconfig file to make changes or you can delete the Xcode_Config directory and rerun the setup.sh script.

## How does the project configuration work?
The Xcode_Config/DeveloperSettings.xcconfig file contains definitions for parameters that are needed for signing. This file is included by the xcconfig files in the Xcode project. The parameter definitions are then usable in the xcconfig files to configure the build parameters.

You should not change the build parameters within the normal Xcode configuration screens. Doing so will cause Xcode to add the parameter defs to the main configuration files and these will override the definitions that are made in the xcconfig files.

The configuration files also include using different icons for the debug builds and the release build so that it is easy to see which configuration is currently being used by built application and audio unit. The debug build uses a smiley face based on a circuit breaker symbol and the release build uses an icon based on a diode to ground.

## Installing Builds

Before installing a build for either a Mac or an iOS device you need to have Xcode configured to use your developer credentials and your device registered with with Xcode and your development computer. See the following two articles from Apple for further information about Xcode and distributing applications to registered devices.

[Xcode](https://developer.apple.com/documentation/xcode)

[Distribution to registered devices](https://developer.apple.com/documentation/xcode/distributing-your-app-to-registered-devices)

You will want to do a debug build on your device first. To do this for your mac, choose the *CircuitBreaker > My Mac (Mac Catalyst)* option in the title bar of Xcode. This will build both the dummy container app and the contained AUv3. The debug build should launch and an empty application window will come up. The application icon should be the smiley face circuit breaker icon indicating that the build is a debug build. You should no be able to run auval to verify that the audio unit has been built correctly using `auval -v aufx cbau Demo` replacing the `Demo` with the manufacturer code that you provided to the setup.sh script when configuring the project. You should see `AU VALIDATION SUCCEEDED.` at the end of the print out in the terminal. If auval fails, it is likely that the manufacturer code or the organization identifier are configured incorrectly in the Xcode_Config/DeveloperSettings.xcconfig file.

Once this step is running correctly you should be able to do a debug build to your iPhone or iPad

### MacOS

To get an optimized release build for macOS you need to do an archive build and then distribute the archived application. In the title bar selector choose **Any Mac (Mac Catalyst, Apple Silicon, Intel)**. Then under the **Product Menu** choose **Archive**. When the build is completed the **Archives** window will be displayed. Select the build that was just completed and press the **Distribute App** button. In the dialog that comes up, choose **Copy App**. This will bring up a file interaction dialog that will let you select a location to save the export folder to. Select a location and then press the **Export** button. You can now navigate to the export folder in the Finder and install the CircuitBreaker.app application to wherever you would like to. The icon for the app should now be diode based icon to indicate that this is an optimized release build.

Note that you will need to run the container app at this point to make sure the AUv3 is registered with the system. Once you have done that you can `auval -v aufx cbau Demo` using the correct manufacturer code that you have selected in place of `Demo`. If the validation is successful, you should be able to use the plugin in any macOS host that supports AUv3 plugins.

### iOS

To do a release build for an iPhone or an iPad you need to debug build to the device first. This will ensure that you have the device correctly provisioned to accept the signed archived build. The build process is similar to what is described in the macOS section above. In the title bar selector area choose **CircuitBreaker > Any iOS Device (arm64)**. Then in the **Product** menu select **Archive**. When the build is complete the *Archives* window will come up. Select the latest build and press the **Distribute App** button. Choose the **Ad Hoc** selector and press the **Next Button**. A new dialog will be presented to let you select some options for the distribution files. The simplest is to use the defaults and I'd suggest doing this on the first time you do a distribution to your iOS device. Press the **Next** button. This will bring up the Re-sign dialog. Choose **Automatically manage signing** and press the **Next** button. When the processing is complete the *CircuitBreaker.ipa* export dialog is displayed with the signing details for the build. You can now press the **Export** button. This will bring up the file interaction window and you can select a place to export the build folder to.

Plug your iPhone or iPad into your development Mac. In the Finder, select your device in the *Locations* section. You can now drag-and-drop the IPA file from the build folder directly onto the device display in the finder. The file you want to drag to the selected device is the *CircuitBreaker.ipa* file. Dragging and dropping the file will install the CircuitBreaker app on your iPhone or iPad. The Application icon should be showing the diode based image. You should now be able to open the CircuitBreaker app, even though it doesn't actually do anything is is just a blank view. After this You should be able to use the optimized release version of the plugin in any host that supports AUv3 plugins.

## State of the Code

The audio processing code in the AU is a very basic hard clipper with a configurable volume clip level. The GUI is a single slider to set the clipping level. There isn't very much useful to learn from the audio processing code itself. The project is a complete AUv3 plugin though so it does allow for exploring the complete path of an audio unit for iOS.

The code is basically the Xcode template for an audio unit. Some empty files have been deleted. The organization of the template is a bit strange with where the classes for the C++ portion are kept. I've left it as it comes so that it will be easy to see where the changes have been made when compared to the default template. This isn't the way I would normally organize an AU, but it will work fine.


## License
If you use this code or documentation in an article, video, or other educational or demonstration setting, consider the project to be under a Creative Commons cc-by-4.0 license.

You are free to use the source code in a development project in any way you please, without attribution or any other restrictions. But, understand that this code comes with no promises or guarantees of being fit for any purpose other than exploration and discovery.

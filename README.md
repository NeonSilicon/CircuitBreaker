# CircuiBreaker iOS AUv3

CircuitBreaker is a small demonstration project. They primary purpose of the project is to investigate how to solve issues with code signing and project configuration for an open source project developed in Xcode and hosted on GitHub.

The deliverable part of the project is an AUv3 that provides for a safety hard clip at a specified level. The GUI is minimal and the container app for the AUv3 does absolutely nothing. Its only purpose is to allow for the instalation of the audio unit on the device.

## Project Organization 

The Xcode project is in the CircuitBreaker subdirectory of the directory that containes this README.md file.

the *setup.sh* script should be run before openning the Xcode project in Xcode. Setup.sh will build a directory named Xcode_Config that contains a file named DeveloperSettings.xcconfig using information that is provided to the script when it is executed. The Xcode_Config directory is excluded from the Git repository in the .gitignore file. The point of doing this is that it insures that the devloper signing data is not checked into the git repo. The configuration also allows for providing the identifier and the name of the AUv3 and container app.


## How does the project configuration work.
The Xcode_Config/DeveloperSettings.xcconfig file contains definitions for parameters that are needed for signing. This file is included by the xcconfig files in the Xcode project. The parameter definitions are then usable in the xcconfig files to configure the build parameters.

You should not change the build parameters within the normal Xcode configuration screens. Doing so will cause Xcode to add the parameter defs to the main configuration files and these will override the definitions that are made in the xcconfig files.


## State of the Code

The audio processing code in the AU is a very basic hard clipper with a configurable volume level that it will clip at. The GUI is a single slider to set the clipping level. There isn't very much useful to learn from the audio processing code itself. The project is a complete AUv3 plugin though so it does allow for exploring the complete path of an audio unit for iOS.


## License
If you use this code or documentation in an article, video, or other educational or demonstration setting, consider the project to be under a Creative Commons cc-by-4.0 license.

You are free to use the source code in a development project in any way you please, without attribution or any other restrictions. But, understand that this code comes with no promises or guarantees of being fit for any purpose other than exploration and discovery.

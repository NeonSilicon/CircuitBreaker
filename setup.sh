#!/bin/bash

if [ -f "Xcode_Config/DeveloperSettings.xcconfig" ] ; then
   echo The configuration file already exists.
   echo Please edit the Xcode_Config/DeveloperSettings.xcconfig file directly.
   exit 1
fi

echo Configuring developer credentials and plugin name.
echo
echo The answers to these questions will be written to the Xcode configuration
echo for the project in the Xcode_Config directory.
echo
read -p "Press enter/return to begin."

## If you want to control the application name from outside the Xcode build system, uncomment the following two lines
## and add the third line to the file write section below.
## Doing this for an AU complicates things and isn't really need for the purpose of this project.
#echo What name do you want to use for the application?
#read app_name
#PRODUCT_NAME = $app_name

echo What is your developer team ID? This can be left blank for unsigned macOS builds.
echo The information is available at developer.apple.com for registered developers.
read team_id

echo What is your organization identifier, e.g. com.companyname
read org_id

echo What is your four character manufacturer code? Example: DEMO
read manu_code

echo Creating the Xcode_Config directory.
mkdir -p Xcode_Config

echo Creating the shared configuration file.

cat <<file >> Xcode_Config/DeveloperSettings.xcconfig
CODE_SIGN_IDENTITY[sdk=macosx*] = Mac Developer
CODE_SIGN_IDENTITY[sdk=iphoneos*] = iPhone Developer
CODE_SIGN_IDENTITY[sdk=iphonesimulator*] = iPhone Developer
DEVELOPMENT_TEAM = $team_id
CODE_SIGN_STYLE = Automatic
ORGANIZATION_IDENTIFIER = $org_id
DEVELOPER_ENTITLEMENTS = -dev
PROVISIONING_PROFILE_SPECIFIER =
MANUFACTURER_CODE = $manu_code
file

echo Finished configuration.

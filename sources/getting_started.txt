.. include:: feedback_widget.rst

===============
Getting Started
===============

.. contents:: Table of contents
 

Introduction
------------
The Loopy SDK provides a simple set of classes and methods built upon the Loopy REST API.

App developers can elect to use either the pre-defined user interface controls provided in the Loopy UI 
framework, or "roll their own" using direct SDK calls.

All calls to the Loopy SDK are *asynchronous*, meaning that your application will not "block" while 
waiting for a response from the Loopy server.

.. note:: * iOS 6.1 is the minimum version supported by this SDK

Installing the SDK
------------------

If you are upgrading from a previous release, check out the `Upgrading Guide`_.

    .. _Upgrading Guide: upgrading.html


Installing With CocoaPods
-------------------------

CocoaPods is an easy, elegant way to manage library dependencies in iOS. No need to manually import frameworks or deal with compiler flags. After a one-time installation of RubyGems (CocoaPods is Ruby-based), a single command-line operation is all that's needed to install or upgrade Loopy. For more information on CocoaPods, check out the `CocoaPods homepage`_.

  .. _CocoaPods homepage: http://cocoapods.org/

 
Step 1: Install RubyGems & CocoaPods (One-Time Operation)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- Current Macs come preinstalled with Ruby 1.8.7. For the purposes of CocoaPods, **this is the correct version.** However, you may still need to install RubyGems as directed from the `installation page`_.
 

  .. _installation page: https://rubygems.org/pages/download
 

- Verify that you have both Ruby and RubyGems installed by entering the following in the command line:

::

            $ ruby -v
            ruby 1.8.7 (2012-02-08 patchlevel 358) [universal-darwin12.0]
            $ gem -v
            2.1.5
 
- Install CocoaPods by entering the following in the command line:

::

           $ sudo gem install cocoapods
           $ pod setup
 
 
.. note:: Installing RubyGems and/or CocoaPods can take up to a minute, and may appear unresponsive for brief periods during install.
 

Step 2: Install Loopy as a CocoaPod
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- In the root directory of your project, create a Podfile. This file (named "Podfile" with no extension) specifies which CocoaPods will be included in your project. **Your Podfile should contain the following:**

::

            platform :ios
            pod 'Loopy'
 

.. note:: If you already use an Xcode workspace to manage your project files, you will need to customize your Podfile to include CocoaPods for each Xcode project and app target. See this `CocoaPods help page`_ for more information.
 
  .. _CocoaPods help page: https://github.com/CocoaPods/CocoaPods/issues/738

- Once complete, your Podfile should appear in this location in your project directory:

  .. image:: images/podfile_in_directory.png
            :width: 718
            :height: 137
 

- In the command line at the root directory of your project, enter the following:

::

            $ pod install

- After Loopy CocoaPod is created in your project, **you must use the Xcode workspace (YourProject.xcworkspace) to use the CocoaPod.** All your project settings should still be available to you from the workspace. **DO NOT open the .xcodeproj directly.**


If you're having problems please let us know by clicking on the 'Feedback' tab on the right side of the page.   We're here to help.

You can also search or post on our `support forums`_

  .. _support forums: http://support.getsocialize.com

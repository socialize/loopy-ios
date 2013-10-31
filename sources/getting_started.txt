.. include:: feedback_widget.rst

=====================
Getting Started Guide
=====================

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

**There are two options for installing the Loopy SDK:** using CocoaPods, or via manual download and install.

Installing With CocoaPods (Recommended)
---------------------------------------

CocoaPods is an easy, elegant way to manage library dependencies in iOS. No need to manually import frameworks or deal with compiler flags. After a one-time installation of RubyGems (CocoaPods is Ruby-based), a single command-line operation is all that's needed to install or upgrade Loopy. For more information on CocoaPods, check out the `CocoaPods homepage`_.

  .. _CocoaPods homepage: http://cocoapods.org/

 
Step 1: Install RubyGems & CocoaPods (One-Time Operation)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- Macs come preinstalled with Ruby 1.8.7. For the purposes of CocoaPods, **this is the correct version.** However, you may still need to install RubyGems from the `installation page`_.

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

.. note:: Installing gem can take up to a minute, and may appear unresponsive for brief periods during install.
 
Step 2: Install Loopy as a CocoaPod
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- In the root directory of your project, create a Podfile. This file (named "Podfile" with no extension) specifies which CocoaPods will be included in your project. **Your Podflile should contain the following:**

::

            platform :ios
            pod 'Loopy'

- In the command line at the root directory of your project, enter the following:

::

            $ pod install

- After Loopy CocoaPod is created in your project, **you must use the Xcode workspace (YourProject.xcworkspace) to use the CocoaPod.** All your project settings should still be available to you from the workspace. **DO NOT open the .xcodeproj directly.**

- To obtain any updates to Loopy, simply navigate to the root directoy of your project again and enter the following:

::

            $ pod update

 
Installing Loopy as a Framework
---------------------------------------

For those instances where CocoaPod install is not practical or desirable, the Loopy SDK can be installed manually, as follows:

Step 1: Add the Loopy Framework to Your Project
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Download and unzip the lastest iOS SDK release from the website.**  
  You can find it here: http://www.getsocialize.com/sdk/
- **Install the embedded static framework to your application.**

  To do this just drag and drop Loopy.embeddedframework folder from the
  package to your framework section in your project.

.. note:: Be sure to drag the outlying .embeddedframework folder, not just the framework. The .embeddedframework directory contains both the Loopy framework and the Loopy resources.
  If you just add the framework, you will be missing important Socialize images and configuration files.

.. image:: images/drag_and_drop.png
            :width: 639
            :height: 527

- When prompted, check "Copy items into destination group's folder (if needed)" and click finish

.. image:: images/check_copy_items.png

.. note:: Be sure the 'Create groups for any added folders' radio button is selected during the above step. If you select
  'Create folder references for any added folders', a blue folder reference will be added to the project
  and Loopy will not be able to locate its resources.


Step 2: Set Project Linker and Code Generation Flags
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- Add **-ObjC** and **-all_load** flag to the Other Linker Flags in the build settings of your application target. *Please use the flag exactly as it is—the most common mistake here tends to be misspelling or incorrect capitalization.*

    .. image:: images/linker_flags.png
            :width: 700
            :height: 410

- For each of your application targets (or, if preferred, for the entire project), set the Debug setting of "Generate Test Coverage Files" and "Instrument Program Flow" in "Apple LLVM 5.0 - Code Generation" to "Yes":

  .. image:: images/code_gen.png
        :width: 529
        :height: 278

If you're having problems please let us know by clicking on the 'Feedback' tab on the right side of the page.   We're here to help.

You can also search or post on our `support forums`_

  .. _support forums: http://support.getsocialize.com

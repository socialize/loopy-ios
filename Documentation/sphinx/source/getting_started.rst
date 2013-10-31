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

CocoaPods is an easy, elegant way to manage library dependencies in iOS. No need to manually import frameworks or deal with compiler flags. After a one-time installation of RubyGems (CocoaPods is Ruby-based), a single command-line operation is all that's needed to install or upgrade Loopy.
 
Step 1: Install RubyGems & CocoaPods (One-Time Operation)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- Macs come preinstalled with Ruby 1.8.7. For the purposes of CocoaPods, **this is the correct version.** However, you may still need to install RubyGems from the `installation page`_:

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

.. note:: Installing gem can take up to a minute, and may appear unresponsive intermittently during install.
 
Step 2: Install Loopy as a CocoaPod
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~





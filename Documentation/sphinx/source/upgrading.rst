.. include:: feedback_widget.rst

=====================
Upgrading Loopy
=====================

Overview
------------------

As with initial installation, Loopy upgrades are greatly simplified with CocoaPods. Upgrading assumes you have installed Loopy via the `Getting Started page`_.

    .. _Getting Started page: getting_started.html

- **To obtain any updates to Loopy, simply navigate to the root directory of your project in the command line and enter the following:**

::

            $ pod update


Important Notes on Upgrading to v1.0.0-RC7
------------------------------------------------

To allow compliance with Apple's rules on IDFA ("advertisingIdentifier"), the Loopy library offers the option to disable the use of IDFA. **You must disable IDFA if your app does not serve ads or it will be rejected by the App Store.**

To disable IDFA in Loopy, navigate to STDeviceSettings and set the proprocessor macro flag to 0; to enable IDFA, set to 1 (the default):

::

	#define SHOULD_USE_IDFA 1

The macro will remove any references to advertisingIdentifier in the code if so specified, ensuring it will not be detected during App Store submission.

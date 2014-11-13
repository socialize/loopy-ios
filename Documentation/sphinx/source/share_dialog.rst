.. include:: feedback_widget.rst

======================
Using the Share Dialog
======================

.. |br| raw:: html

   <br />

.. container:: block-padded

    If you currently have a share function in your app you are most likely using the default UIActivityViewController provided by the iOS platform.

    The Loopy™ Share Dialog leverages UIActivityViewController but provides important callbacks to allow more sophisticated social analytics.

    To implement the Loopy™ Share Dialog, simply use the **SZAPIClient** and **SZShare** classes, along with the **SZActivity** protocol, to create a trackable URL and display it using the default share dialog.

    As with the iOS default UIActivityViewController, **SZShare** offers Facebook and Twitter sharing, as well as the ability to add additional UIActivity implementations you may have representing additional social networks or other sharing services. 

.. container:: block

    .. image:: images/share-dialog-1.png
        :align: center
        :width: 201
        :height: 405
    |br|

.. container:: clear

    If you don't already have one, add a button to your UIView layout (either in XIB file, pictured below, or programatically):
    |br|

    .. image:: images/share-dialog-button.png
        :width: 685
        :height: 511
    |br|

    Add an event handler for when the button is pressed (in this example, the **Touch Up Inside** event handled by an **IBAction**):

    .. literalinclude:: snippets/share_dialog.m
            :language: objective-c
            :start-after: begin-show-share-dialog-snippet
            :end-before: end-show-share-dialog-snippet

    To add additional **UIActivity** classes to the Loopy™ Share Dialog, create your custom UIActivities (or modify your existing ones) to conform to the **SZActivity** protocol; **your header and implementation files should contain the following:**

    .. literalinclude:: snippets/custom_activity.h
            :language: objective-c
            :start-after: begin-custom-activity-snippet-header
            :end-before: end-custom-activity-snippet-header

    .. literalinclude:: snippets/custom_activity.m
            :language: objective-c
            :start-after: begin-custom-activity-snippet
            :end-before: end-custom-activity-snippet

    Include the custom activity in the NSArray passed in to SZShare's UIActivityViewController, as follows:

    .. literalinclude:: snippets/share_dialog.m
        :language: objective-c
        :start-after: begin-show-custom-activity-snippet
        :end-before: end-show-custom-activity-snippet

           



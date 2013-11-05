.. include:: feedback_widget.rst

======================
Using the Share Dialog
======================

.. container:: block-padded

    If you currently have a share function in your app you are most likely using the default UIActivityViewController provided by the iOS platform.

    The Loopy™ Share Dialog leverages UIActivityViewController but provides important callbacks to allow more sophisticated social analytics.

    To implement the Loopy™ Share Dialog, simply use the **SZAPIClient** and **SZShare** classes to create a trackable URL and display it using the default share dialog.

.. container:: block

    .. image:: images/share-dialog-1.png
        :align: center
        :width: 201
        :height: 405

|

.. container:: clear

    If you don't already have one, add a button to your UIView layout (either in XIB file, pictured below, or programatically):

    |


    .. image:: images/share-dialog-button.png
        :width: 685
        :height: 511

    |

    Add an event handler for when the button is pressed (in this example, the **Touch Up Inside** event handled by an **IBAction**):

    .. literalinclude:: snippets/share_dialog.m
        :start-after: begin-show-share-dialog-snippet
        :end-before: end-show-share-dialog-snippet

    |

    hhh
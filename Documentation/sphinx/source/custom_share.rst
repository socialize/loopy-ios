.. include:: feedback_widget.rst

=======================
Using a Custom Share UI
=======================

If you have your own custom implementation of a share UI you can still benefit from the Loopy™ social analytics platform by creating a trackable URL to be shared, and notifying the analytics platform when the share was successful.

Simply use the **[SZAPIClient shortlink:withCallback:]** method to create a trackable URL for sharing when the user executes a share. Then, once sharing is complete, ensure you call **[SZAPIClient reportShare:withCallback:]** to record the share.

This can be implemented as follows:

.. literalinclude:: snippets/custom_share.m
        :language: objective-c
        :start-after: begin-custom-share-snippet
        :end-before: end-custom-share-snippet

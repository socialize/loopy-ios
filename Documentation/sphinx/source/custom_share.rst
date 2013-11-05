.. include:: feedback_widget.rst

=======================
Using a Custom Share UI
=======================

If you have your own custom implementation of a share UI you can still benefit from the Loopy™ social analytics platform by creating a trackable URL to be shared.

Simply use the **[SZAPIClient shortlink:withCallback:]** method to create a trackable URL for sharing when the user executes a share.

When the user elects to share using your custom UI:

.. literalinclude:: snippets/custom_share.m
        :start-after: begin-custom-share-snippet
        :end-before: end-custom-share-snippet

Development Guidelines
======================

This set of pages holds general guidelines and orientation for the development
of software projects. All projects must follow all the rules from these
guidelines.


.. toctree::
   :caption: Table of Contents
   :numbered:

   general
   processes-and-practices
   apis
   architecture
   monitoring-and-logging
   implementation
   books


Document Conventions
--------------------

We use keywords like "MUST", "MUST NOT", "REQUIRED", "SHOULD", "SHOULD NOT",
"RECOMMENDED", "MAY", and "OPTIONAL" with the same definitions as the
`RFC 2119`_.

Machine-readable text, such as code, URLs, protocols, etc are represented with
monospaced font (eg. HTTP method ``POST``). We use ``{}`` to delimiter template
variables in samples and ``#`` as a comment mark::

    # This is a comment
    https://api.example.com/account/{account-id}


General References
------------------

A list of documents and sites we use to produce our guidelines.

Handbooks
~~~~~~~~~

* `Basecamp Handbook <https://github.com/basecamp/handbook>`_
* `Gitlab Handbook <https://about.gitlab.com/handbook/>`_
* `Valve Handbook <http://www.valvesoftware.com/company/Valve_Handbook_LowRes.pdf>`_


Reference Development Guidelines
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* `Plataformatec <http://guidelines.plataformatec.com.br/>`_
* `Terraform Recommended Practices <https://www.terraform.io/docs/enterprise/guides/recommended-practices/index.html>`_


Culture Books
~~~~~~~~~~~~~

* `Netflix Culture <https://www.slideshare.net/reed2001/culture-1798664) (deprecated>`_
* `Disqus Culture <https://www.dropbox.com/s/u6suqbbk2w1vbwz/Disqus%20Culture%20Book.pdf>`_
* `Loadsmart Culture <https://github.com/loadsmart/culture>`_


.. _RFC 2119: https://www.rfc-editor.org/rfc/rfc2119.txt

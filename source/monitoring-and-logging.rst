.. _chapter-monitoring-and-logging:

Monitoring & Logging
********************

This chapter you will found informations about monitoring and logging.

Monitoring
==========

.. todo:: write it...


.. _section-logging:

Logging
=======

This guildelines were built upon the concepts of `12 Factors App`_ and `Splunk
Logging Best Practices`_.

We generate logging based on the transactions processed by the system. The
definition of *transaction processing* according to `Wikipedia`_:

  Transaction processing is designed to maintain a system's Integrity (typically
  a database or some modern filesystems) in a known, consistent state, by
  ensuring that interdependent operations on the system are either all completed
  successfully or all canceled successfully.

Examples of transactions in diferent contexts:

* Database: database transaction (commit/rollback);
* Web Application/API: request/response cycle;
* Worker: process a message;
* Business Transactions: bill a credit card, cancel a contract.

General practices for logging generation:

* You should use the framework/language tools for logging (eg. python's
  ``logging`` module);
* You should not use ``print()`` or ``echo()`` to produce log messages;
* You must start your log entry with a timestamp using UTC timezone.
* You should use a standard output device to produce log (``stdout`` or
  ``stderr``);
* Errors in code (programming errors) should be handled apart of business
  failures (transactional failures). See :ref:`section-error-reporting`;
* You should not produce multi-line log messages (``\n``) for non-debugging
  logs (see :ref:`section-log-format`).
* It's recommended to take care about the amount and the relevance of log you
  generate to avoid the blindness caused by excess of noise in logs and to
  reduce the costs of storing it.
* No sensitive or private information could be logged. You should mask all
  all informations that need to be protected by the Terms of Service of our
  product or GDPR laws. Informations like secret keys, passwords, financial
  informations, personal informations and implementation details of our system
  or infrastructure (eg. database/database table names, full paths of
  deployments, etc);
* We recommend that you create an unique ID for each transaction and print it on
  logs to make it easy to track all sub-transactions and operations inside of a
  transaction;
* You should use string representations or safely encoded strings in logs to
  avoid encoding & decoding issues with non-ascii caracters;
* Production environments must enable at least ``INFO`` log-level. For staging,
  and local development environments we use ``DEBUG`` level.


Logging Errors
--------------

There are two different kinds of error logs that need to be managed
separatadely. The software errors (see :ref:`section-error-reporting`) must be
reported in a specific system for error tracking and, transactional errors, that
occurs when something goes wrong with the business rules, must be logged as a
regular log with log level ``ERROR`` (see :ref:`section-log-levels`).


.. _section-log-format:

Log Format
----------

The modern systems for log agregation offers a lot of indexing, searching, and
analytics tools to be used by developers.

To make this possible this systems recommends that we generate logs in a
structured way. That's why we recommend you to use JSON-serialized log messages.

* Send the plain JSON-serialized string in a single line for each log record.
* The log structure must contains at least the following information:

  * ``LOGLEVEL``: the level of the log message;
  * ``TIMESTAMP``: Timestamp in ``asctime`` format and UTC timezone;
  * ``GUID`` (optional) - GUID (eg. ``UUIDv4`` string) of transaction (if
    available);
  * ``FILE/FUNCTION:LINENO`` (optional): file, function and line number where
    the log was generated. This information must be included **only** in
    ``DEBUG`` log level.


.. _section-log-levels:

Log Levels
----------

``DEBUG`` and/or ``TRACE``
  Detailed information about the whole transaction and it sub-transactions. You
  can print detailed and verbose information about the internal state of
  transaction like variables, call trace (in cases where of ``TRACE`` is
  supported), etc. It is important to take care of customers' private data and
  sensible informations. By default this log level is not enabled in live
  production servers but, besides that, could be enabled for live production
  debugging purposes.

``INFO`` or ``NOTICE``
  Summarized information about a successfully finished transaction. You should
  put one or more key information that make this transaction trackable inside
  the system and you should describe what transaction executed (eg.
  ``operation=bill credit card (capture), customer_id=XYZ123``). This log level
  should be enabled in live production environments. In cases where the system
  generates a huge amount of data (eg. request/response log) you could agreggate
  the information in batches or route the logs to an specific system that can
  handle these logs in a better way.

``WARNING``
  Something exceptional happened during the transaction processing but the
  system was able to recover from this exception (eg. ``operation=bill credit
  card (capture), customer_id=XYZ123, result=timeout connection (retrying #1 of
  3)``).

``ERROR``
  The transaction failed in a way where the system could not recover itself (eg.
  ``operation=bill credit card (capture), customer_id=XYZ123, result=failed
  after all retry attempts.``). Errors caused by the end user must not be logged
  as a error (eg. Invalid username/password errors).

``CRITICAL``
  The transaction failed and the system breaks completely due to this failure.
  This error shoud be logged in but need to raise an exception to the
  systems that manages error reports (see :ref:`section-error-reporting`).


.. _section-error-reporting:

Error Reporting
===============

Errors in code are caused by some part of the code that is wrongly created by
the developer. Usually it raises a language exception that are not handled by
the code.

You must not send these errors to the transactional logs (see 
:ref:`section-logging`).

.. _section-exception-handling-service:

Exception Handling Service
--------------------------

We use a service to capture, collect, aggregates and monitor this kind of
errors. The system we're currently using for this purpose is Sentry_.


.. _Sentry: https://sentry.io
.. _12 Factors App: http://12factor.net/logs
.. _Splunk Logging Best Practices: http://dev.splunk.com/view/logging-best-practices/SP-CAAADP6
.. _Wikipedia: https://en.wikipedia.org/wiki/Transaction_processing

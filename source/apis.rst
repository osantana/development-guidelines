.. _chapter-apis:

APIs (WIP)
**********

Application Public Interfaces (API) are channels through which multiple software
components communicate. A good API provides efficient communication between
components and is easy to be used by the developers that create these components.

This chapter provides guidelines for creating APIs with these characteristics
for services. If you need more informations about APIs in the context of
libraries take a look at chapter :ref:`section-libraries-and-apis`.

This chapter is based mostly on guidelines created by `PayPal`_, `Google`_, and
`Microsoft`_. If you have some question about one subject not covered here, we
recommend these documents as a further reference.

.. todo::

   This chapter contains only the Table of Contents with the topics that will
   be covered.


Design
======

* Design First (required)

* Aspects:

  * Ease of use
  * Single Responsability (loose coupling, encapsulation, cohesion etc)
  * Robustness (consistent, stable, contract-based etc)
  * Security

* Design Methodology

  * Top-Down (from client to API) (recommended)

    * Use the client use cases to guide your API design. When you create a
      client interface you will see what informations must be shown. Therefore, you
      can provide an API that returns this information in one request.

  * Bottom-Up (from data models to API)

* Architectural Styles for Service APIs

  * REST (recommended)
  * CQRS
  * RPC (XML-RPC, SOAP etc)
  * GraphQL

* Hypermedia (optional)
* Naming Conventions and Standards
* Resource

  * Resource is more than a data model
  * A list of resources is one resource

* Resource Representations (serializers, Content-Types etc)
* Resource Location (URL)

  * Schema
  * Flat is better than nested

* Versioning

  * API Lifecycle
  * Deprecation policy
  * Future proof APIs

    * Designing extensible APIs

      * When you decide to create a boolean "flag" on your resource, stop and
        think again. Is it possible to change this binary parameter on a
        variable parameter?
        Eg. free_shipping=True. Free shipping does not exist. There is someone
        paying for this shipping. Why not model configuration like::

            {
              ...
              "shipping_payment": [
                {
                  "payer_type": "seller",
                  "rate": 0.5
                }, {
                  "payer_type": "carrier",
                  "rate": 0.2
                }
              ]
              ...
            }

        to tell application that seller will pay 50%, carrier will pay 20% and
        buyer will pay 30% for the shipping.

    * Backward compatible modifications
    * Backward incompatible modifications

  * Multiversion selection and management

* Company-specific API Philosophy

  * HTTP shines! Use it.
  * Postel's Law of Robustness
  * Reactive APIs

    * Create APIs that "reacts" to events. Eg. If we set the field "approved_at"
      with a timestamp in one order it's clear that it must be transitioned to
      "approved" status. Same for "invoiced_number" -> "invoiced". Do not allow
      forced transitions like PATCH /order/id {"status": "invoiced"} or pass
      multiple arguments to do this transition like PATCH /order/id {"status":
      "invoiced", "invoiced_at": ..., "invoice_number": "..."} (this use case is
      extremely error prone).

  * Future proof
  * Check, recheck, double check and check again for every "status" and state
    machines on resources. There are lots of "gotchas" on state names and
    transitions.


Specification and Documentation
===============================

  * Specification Tools

    * Swagger
    * Pactum

  * Documentation

    * Types of documentations

      * Usage Manual
      * Tutorials
      * Use Cases
      * Reference
      * Implementation Documents (private)

    * Tools

      * Pactum Documentation toolchain
      * Sphinx


HTTP, REST and Web
==================

We love the Web and HTTP protocol. The simplicity of the concepts like
Resource/Document, Resource references hyperlinking (through URL), and the
stateless model of Request/Response forces the result of solutions design to
be simple (but not simplistic). We believe that RESTful APIs embraces this
simplicity.

* Resource Representations

  * JSON
  * Protobuf
  * HTML (required for "Web APIs")

* Resource Locators

  * No trailing slash at URL path: /resources instead of /resources/ (backward
    incompatible, support HTTP 307/308 redirects on server and clients)
  * Resource names on path must use plural for collections and singular for
    single resources. (backward incompatible)

* Web is an API, Web as an API
* Request

  * Methods
  * HTTP Headers
  * Data model and representation (serialization)

    * Data types (date, timestamp, status enum, nil/null etc)

  * Company "way of REST"

    * Path version selector
    * Filtering (querystrings)
    * Searching (querystrings)
    * Pagination (querystrings)

      * Always set a default and a max limit for limit and page size
      * limit/offset (required)
      * page/pagesize (required for "Web APIs")
      * Hypermedia links to "next" and "previous" pages

    * Fetch control (querystrings)
    * Bulk Requests support with multipart content
    * PUT As Create
    * Asynchronous Request/Response
    * Custom HTTP Headers support

      * ``X-HTTP-Method-Override``
      * ``X-Request-Id``

    * Idempotent POST, PUT and PATCH (303/304)
    * JSON PATCH support

* Response

  * Status Code

    * Ranges
    * Allowed Status Codes and their Usage
    * Method x Status Code Mapping

  * HTTP Headers
  * Error response data model
  * i18n & l10n

    * Error messages must be returned based on ``Accept-Language`` request
      header for error messages or resource data translation (eg. Product name
      translation). It's recommended to return the original message template
      string and error data inside separated object to allow client developers
      to create custom translations::

          # No Accept-Language or unknown language
          400 Bad Request
          {
              "length": [
                  {
                      "message": "Invalid minimum length 6.3in",
                      "error": {
                          "message_template": "Invalid minimum length {size}{unit}",
                          "data": {
                              "size": "6.3",
                              "unit": "in"
                          }
                      }
                  }
              ]
          }

          # Accept-Language: pt-br
          400 Bad Request
          {
              "length": [
                  {
                      "message": "Comprimento mínimo inválido 16cm",
                      "error": {
                          "message_template": "Invalid minimum length {size}{unit}",
                          "data": {
                              "size": "6.3",
                              "unit": "in"
                          }
                      }
                  }
              ]
          }


          # Accept-Language: [weighted list of languages]
          ... most weighted language available ...

  * Hypermedia

    * Link description and relations
    * Links Array

  * Company-specific standards

    * Asynchronous Request/Response

      * Sync vs Async with state control to keep response time low

    * Not Found instead of Forbidden for anonymous access


Implementation
==============

* Response time

  * Fast is better than slow
  * Execute performance and load testing in all endpoints of API before every
    deployment
  * Default maximum response time constantly checked on monitoring
  * Avoid caches. Again, avoid caches. If it's required your app must also work
    without it (slow response time instead of errors)

* Security (SSL, auth&auth etc)
* Protection (throttling, DDoS protection etc)
* Implementation details protection (hide database sequential pk from URLs,
  don't return database errors on error messages, never run debug mode on
  production environment etc)
* Event triggering
* Deployment checklist


.. _section-denormalization-and-data-sync:

Denormalization and Data Sync
-----------------------------

.. todo:: write this topic...


Common Solutions
================

Standard techniques to solve common problems:

* Use PUT-as-create with an client-side generated ID to fix duplicated resource
* creation caused by double-clicked issues on client web application.
* Use status fields to manage workflows of objects that need to be processed on
  multiple steps.


References
==========


API Design Guidelines
---------------------

* `PayPal API Standards`__
* `Google Platform API Design Guide`__
* `Microsoft API Guidelines`__
* `Zalando RESTful API Guidelines`__
* `PayPal security guidelines and best practices <https://developer.paypal.com/docs/classic/lifecycle/info-security-guidelines/>`_
* `Interagent / Heroku API Guidelines`__

__ PayPal_
__ Google_
__ Microsoft_
__ Zalando_
__ Heroku_

.. _PayPal: https://github.com/paypal/api-standards
.. _Google: https://cloud.google.com/apis/design/
.. _Microsoft: https://github.com/Microsoft/api-guidelines/blob/vNext/Guidelines.md
.. _Zalando: https://opensource.zalando.com/restful-api-guidelines/
.. _Robustness_principle: https://en.wikipedia.org/wiki/Robustness_principle
.. _Heroku: https://github.com/interagent/http-api-design

Articles
--------

* `The definitive guide for building REST APIs
  <https://medium.com/clebertech-en/the-definitive-guide-for-building-rest-apis-f70d37b1d656>`_

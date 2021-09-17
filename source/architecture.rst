.. _chapter-architecture:

Architecture
************

.. important:: Ready for revision.

Good architecture is a important subject. This section will describe some
guidelines that must be followed when architecting a product or solution.


.. _section-general-rules:

General Rules
=============


.. _section-minimal-dependencies:

Minimal Dependencies
--------------------

* Reduce the number of requirements and components for a project. Less "moving
  parts", less complexity. Less complexity, less bugs.
* Resist the temptation to add another element to the solution stack.
* Limit the use of new tools to occasions where current tools are insufficient.
* Adopt new tools only when they are beneficial to the project.
* Prefer third party (managed) tools in cases where the solution is not part of
  our core business. Example: if you need a solution for message queueing prefer
  using AWS SQS instead of make a RabbitMQ deployment.


.. _section-auditability:

Auditability
------------

* All transactions need to be traceable. We need to know *When* (timestamp),
  *Who* (user), and *Where* (source) started *What* (transaction).
* Transactions must be uniquely identified (``transaction_id``) through all
  components of platform.
* Transaction identifier must be present in all logs (see
  :ref:`section-logging`).
* It's important to make a distinction between Transaction ID that relates with
  a business transaction (eg. product approved by moderation) and Request ID
  that relates with a implementation detail (HTTP request).


.. _section-microservices-architecture:

Microservices (or SOA) Architecture
===================================

We deploy products and solutions as a bunch of highly specialized and reliable
services that communicate each other using messages.

After some time deploying this kind of service we have detected some building
blocks and patterns for architecture.


.. _section-building-blocks:

Building Blocks
---------------


.. _section-message:

Message
^^^^^^^

Messages are the base building block of our architecture. Every service
communicate with each other using messages.

.. uml::
   :align: center

   left to right direction
   skinparam handwritten true

   file message

Messages follows a common contract and must be serialized using a open-standard
serializer like JSON or Protobuf. You can wrap this messages with some metadata.


.. _section-component:

Component
^^^^^^^^^

Component is a service or API that receive, processes and triggers events.
It's implemented and deployed as software processes.

.. uml::
   :align: center

   left to right direction
   skinparam handwritten true

   agent component


.. _section-topic:

Topic
^^^^^

Our architecture use topic as a location where components send messages
(Publishers) that would be listened by other components that subscribes to it
(Subscribers).

.. uml::
   :align: center

   left to right direction
   skinparam handwritten true
   skinparam agent {
     BorderColor #808080
     BackgroundColor #ffffff
     FontColor #808080
   }

   () topic
   agent component
   component --> topic

Topics belongs to the platform, ie, any component can post messages because they
are public (to the platform) and global.


.. _section-queue:

Queue
^^^^^

Every component that needs to listen for messages published on topic (see
:ref:`section-topic`) must use a queue as a topic subscriber.

.. uml::
   :align: center

   left to right direction
   skinparam handwritten true
   skinparam agent {
     BorderColor #808080
     BackgroundColor #ffffff
     FontColor #808080
   }

   skinparam interface {
     BorderColor #808080
     BackgroundColor #ffffff
     FontColor #808080
   }

   agent component
   interface topic
   topic -(0)-> component: queue\n

Queues belongs to the component (eg. :ref:`section-service` or
:ref:`section-broker`) that subscribes a topic. Unlike topics, queues are
private and local to the component that consume its messages.

It is very common that different components listen to the same topic.
Assigning one queue to each component and knowing that each queue receives a
copy of the published message we can guarantee that one component won't process
other components messages.


.. _section-storage:

Storage
^^^^^^^

Storage is the location where we store validated and consistent data.

.. uml::
   :align: center

   left to right direction
   skinparam handwritten true
   skinparam agent {
     BorderColor #808080
     BackgroundColor #ffffff
     FontColor #808080
   }

   agent component
   database storage
   component --> storage

We usually use relational databases (see :ref:`section-database`) to store data
at our platform.

We ❤️ PostgreSQL, a lot (you should not use anything different).


.. _section-patterns:

Patterns
--------

We can connect the building blocks above to create patterns with specific
responsabilities in our architecture.


.. _section-api:

API
^^^

The APIs are the channels which data is inserted and retrieved from our
platform.

.. uml::
   :align: center

   skinparam handwritten true

   cloud data
   agent API
   database db
   interface topic

   data -right-> API
   API -down-> db
   API -right-> topic

The responsabilities of an API are:


.. _section-data-input-and-recovery:

Data input and recovery
"""""""""""""""""""""""

Our APIs are made available mostly using the REST model with JSON serialization
using the HTTP protocol.


.. _section-data-validation:

Data validation (including state transitions)
"""""""""""""""""""""""""""""""""""""""""""""

All data sent to our APIs must be valid and APIs need to be able to validate
data autonomously, ie, APIs cannot request informations to other APIs (see
:ref:`section-denormalization-and-data-sync`) to validate data.

Some resources of our APIs provides fields that stores status/state info. It is
responsibility of API validate these status and their transitions.


.. _section-data-persistence:

Data persistence
""""""""""""""""

The persistence/storage of data is also a responsibility of the APIs.

As we already mentioned, we use a relational database in all cases where it is
not absolutely necessary to use another type of storage.

This persistence must be wrapped by a transaction with (see
:ref:`section-event-triggering`) and rolled back in case of failures. API must
return an error in these cases. Like in the following pseudocode:

.. code::

  transaction = begin_transaction()
  try:
    persist(object)
    trigger_event(object)
  except:
    transaction.rollback()
  transaction.commit()


.. _section-event-triggering:

Event triggering
""""""""""""""""

Once the data is persisted APIs need to trigger an event reporting this fact by
posting a message on a specific topic (see :ref:`section-topic`).

The payload of the event must include the content of the persisted object or, at
least, a reference to the object at an API.

You can use the following payload as an example for the content of the event
message:

.. code-block:: JSON

  {
    "transaction_id": "deadbeef",
    "object_type": "order",
    "object_id": "bb654446-22d4-4f28-ab3e-e72bebb89a8c",
    "href_template": "https://api.example.com/{object_type}/{object_id}"
    "href": "https://api.example.com/order/bb654446-22d4-4f28-ab3e-e72bebb89a8c",
    "action": {
      "type": "update",
      "changes": [
        {
          "field": "status",
          "value": "invoiced",
          "old_value": "new"
        }
      ]
    },
    "embedded": {
      "order_id": "bb654446-22d4-4f28-ab3e-e72bebb89a8c",
      "seller_id": "9d054c45-a72e-4878-a932-f131e92e2bf7",
      "status": "invoiced"
    }
  }

* ``transaction_id``: used to make transaction traceable (see
  :ref:`section-auditability`);
* ``object_type``: the type of the object that received the action that
  triggered the event;
* ``object_id``: the ID of the object that received the action that triggered
  the event;
* ``href_template``: the template that you can use to generate the hyperlink
  reference to the object. You can use it to generate custom URLs to access an
  specific objects;
* ``href``: the hyperlink reference to the object (for convenience);
* ``action``: the action that triggered the event. In the example we can see a
  change (``update``) in the order. Based on the list of changes we can also see
  that the order's status transitioned from ``new`` to ``invoiced``;
* ``embedded``: some fields of the object that could be directly used by other
  services. These fields could be used to reduce the amount of requests to the
  APIs but can also increase the payload of the messages. Use it wisely.


.. _section-idempotency-handling:

Idempotency Handling
""""""""""""""""""""

In cases where one of our services make a duplicated request to our APIs it must
handle this correctly. A duplicated `POST` request must receive a `303 See
other` response and other request methods must receive a `304 Not Modified`
response.

The implementation of this handling depends on specific business rules. But
let's look for some examples.

Sending the same `POST` that creates a transaction twice:

.. code-block:: shell

   $ curl -i -X POST https://api.example.com/transaction/ \\
          -d '{"transaction_id": "deadbeef"}'
   HTTP/1.1 201 Created

   $ curl -i -X POST https://api.example.com/transaction/ \\
          -d '{"transaction_id": "deadbeef"}'
   HTTP/1.1 303 See other
   Location: https://api.example.com/transaction/deadbeef

Change an order status that is already in `invoiced` status:

.. code-block:: shell

   $ curl -i -X PATCH https://api.example.com/order/XYZ/ \\
          -d '{"status": "invoiced"}'
   HTTP/1.1 304 Not modified


.. _section-webhook-handler:

Webhook Handler
^^^^^^^^^^^^^^^

A webhook handler resembles an API except that it does not persist data and is
not required to adhere to the :ref:`chapter-apis` guidelines.

.. uml::
   :align: center

   skinparam handwritten true

   cloud data
   agent API
   interface topic

   data -right-> API
   API -right-> topic

Webhook handlers exists to receive notifications from external partners. It is
important that all webhook handlers work together with a scheduled job service
that retrieves notification data that was lost due to failure on notification
handling.


.. _section-service:

Service
^^^^^^^

Services (also called as Workers or Consumers) are components that process
(consume) messages. These messages are sent to queues that subscribe to topics.
You can also read this as "the services listen and process messages from
topics".

One service consumes messages from one queue, as an input data, processes these
data and then generates an output as a publication on topic or an API request.

The simplest type of service are the 'de-queuers' that basically process
messages from a single queue (that subscribe a single topic).

So a service works following the steps below:

1. Get *one* message from a queue (that subscribes a topic);
2. Process this message (following/applying business rules);
3. Get extra informations requesting them to APIs (optional);
4. Send the result publishing it in a topic or posting *one* request to an API.

.. uml::
   :align: center

   left to right direction
   skinparam handwritten true

   agent service
   agent API
   interface source
   interface target

   source -(0)-> service: queue\n
   service --> API
   service --> target: or...

The only reponsibility of a service is: **Business Logic**.

We implement most of the business logic of our platform in services. This
design allows us to keep API agnostic about specific business rules.

This approach allow our APIs to be used by other market players, and also allow
us to build services with different business rules for other markets.


.. _section-broker:

Broker
^^^^^^

Broker is a special kind of service that consumes more than one queue. We use
brokers basically to make code maintenance easier grouping several services that
interacts with, eg, one API in a single code base/deploy.

.. uml::
   :align: center

   left to right direction
   skinparam handwritten true

   agent broker
   interface source1
   interface source2
   interface source3
   interface sourceN...

   interface target1
   interface target2
   interface target3
   interface targetN...

   source1 -(0)-> broker: queue1
   source2 -(0)-> broker: queue2
   source3 -(0)-> broker: queue3
   sourceN... -(0)-> broker: queueN...

   broker --> target1
   broker --> target2
   broker --> target3
   broker --> targetN...


.. _section-scheduled-job:

Scheduled Job
^^^^^^^^^^^^^

Scheduled Jobs are services triggered by the clock (usually in a regular cycle)
to make some kind of batch action and publish the results in one topic (eg. get
all orders lost by webhook handler and publish one-by-one in a topic).

.. uml::
   :align: center

   left to right direction
   skinparam handwritten true

   agent job
   control clock
   interface topic

   clock --> job
   job --> topic


.. _section-client-application:

Client Application
^^^^^^^^^^^^^^^^^^

Client Applications are web (or mobile) applications which provides the means by
which users interacts with our platform.

.. uml::
   :align: center

   left to right direction
   skinparam handwritten true

   actor user
   agent client
   agent API

   user --> client
   client --> API


.. _section-integrations:

Integrations
============

We've two kinds of integrations at our platform:

1. **Internal integrations:** when one of our components must interact with
   other component of our platform (eg. service makes a request to an API) and;
2. **External integrations:** when one of our components must interact with
   a component of other platform (eg. service makes a request to one of our
   partner's API).

On both integration scenarios we need to start from the following premisse:

  No matter if a system is internal or external it eventually...

  * ... goes **offline**...
  * ... **crashes**...
  * ... or **change their behaviour without notice**.

So, to make an integration work in a reliable fashion we need to follow some
rules and procedures:

* Be prepared for the worst;
* Create a SLA for all integrations;
* Monitor (see :ref:`chapter-monitoring-and-logging`) all aspects of integration
  (eg. errors, performance, availability, etc);
* Always use a `Circuit Breaker
  <https://martinfowler.com/bliki/CircuitBreaker.html>`_ pattern for
  integration;
* Set a (small) timeout for requests to avoid that the client becomes blocked;
* Create a retry policy based on defined SLAs or based on informations at error
  response (eg. `Retry-After:` HTTP header in `503 Service Unavailable`
  responses);
* Remember that, depending on the context, some errors are recoverable and
  others are not recoverable. Handle error responses appropriately: retrying,
  rolling back, logging, etc;
* All these rules and procedures must be implemented out-of-box in all services.
  No code deployment must be required to handle unavailability scenarios.


.. _section-architecture-references:

References
==========

* `Some Guidelines For Deciding Whether To Use A Rules Engine
  <http://herzberg.ca.sandia.gov/guidelines.shtml>`_

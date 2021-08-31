Architecture
============

Good architecture is a important subject at Olist. This section will describe
some guidelines that must be followed when architecting a product or solution.


.. _general-rules:

General Rules
-------------


.. _minimal-dependencies:

Minimal Dependencies
~~~~~~~~~~~~~~~~~~~~

* Reduce the number of requirements and components for a project.
  Less "moving parts", less complexity. Less complexity, less
  bugs.
* Resist the temptation to add another element to the solution
  stack.
* Limit the use of new tools to occasions where current tools are
  insufficient.
* Adopt new tools only when they are beneficial to the project.
* Prefer third party (managed) tools in cases where the solution
  is not part of our core business. Example: if you need a
  solution for message queueing choose AWS SQS instead of make a
  RabbitMQ deployment.


.. _auditability:

Auditability
~~~~~~~~~~~~

* All transactions need to be traceable. We need to know When (timestamp), Who
  (user), Where (source) and What (operation) started a transaction.
* Transactions must be uniquely identified (``transaction_id``)
  through all components of platform.
* Transaction identifier must be present in all logs (see
  `logging`_).
* It's important to make a distinction between Transaction ID that relates with
  a business transaction (eg. product approved by moderation) and Request ID
  that relates with a implementation detail (HTTP request).


## Microservices (or SOA)

We deploy products and solutions as a bunch of highly specialized and reliable
services that communicate each other using messages.

After some time deploying this kind of service we have detected some building
blocks and patterns for architecture.


## Building Blocks


### Message

Messages are the base building block of our architecture. Every service
communicate with each other using messages.

.. uml::
   :align: center

   left to right direction
   skinparam handwritten true

   file message

Messages follows a common contract and are serialized as a JSON payload. Our
current PubSub implementation wrap this messages with metadata.


### Component

Component is a service or API that receive, processes and triggers events.
It's implemented and deployed as software processes.

.. uml::
   :align: center

   left to right direction
   skinparam handwritten true

   agent component


### Topic

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


### Queue

Every component that needs to listen for messages published on [topics](#topic)
must use a queue as a topic subscriber.

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

Queues belongs to the component (eg. [service](#service) or [broker](#broker))
that subscribes a topic. Unlike topics, queues are private and local to the
component that consume its messages.

It is very common that different components listen to the same topic.
Assigning one queue to each component and knowing that each queue receives a
copy of the published message we can guarantee that one component won't process
other components messages.


### Persistence

Persistence is the location where we store validated and consistent data.

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
   database persistence
   component --> persistence

We usually use relational [databases](database.md) (PostgreSQL) to store data at
our platform.


## Patterns

We can connect the building blocks above to create patterns with specific
responsabilities in our architecture.


### API

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


**1. Data input and recovery**

Our APIs are made available mostly using the REST model with JSON serialization
using the HTTP protocol.


**2. Data validation (including state transitions)**

All data sent to our APIs must be valid and APIs need to be able to validate
data autonomously, ie, APIs cannot request informations to other APIs to
validate data.

Some resources of our APIs provides fields that stores status/state info. It is
responsibility of API validate these status and their transitions.


**3. Data persistence**

The persistence/storage of data is also a responsibility of the APIs.

We use a relational database in all cases where it is not absolutely necessary
to use another type of storage.

This persistence must be wrapped by a transaction with
[event triggering](#4-event-triggering) and rolled back in case of failures.
API must return an error in these cases.


**4. Event triggering**

Once the data is persisted APIs need to trigger an event reporting this fact by
posting a message on a specific [topic](#topic).


**5. Idempotency Handling**

In cases where one of our services make a duplicated request to our APIs it must
handle this correctly. A duplicated `POST` request must receive a `303 See
other` response and other request methods must receive a `304 Not Modified`
response.

The implementation of this handling depends on specific business rules. But
let's look for some examples.

Sending the same `POST` that creates a transaction twice:

.. code-block::

    $ curl -i -X POST https://api.example.com/transaction/ -d '
      {"transaction_id": "03001629-463b-470b-a6aa-3fac82d5291c"}'
    HTTP/1.1 201 Created

    $ curl -i -X POST https://api.example.com/transaction/ -d '
      {"transaction_id": "03001629-463b-470b-a6aa-3fac82d5291c"}'
    HTTP/1.1 303 See other
    Location: https://api.example.com/transaction/03001629-463b-470b-a6aa-3fac82d5291c/

Change an order status that is already invoiced to `invoiced`:

.. code-block::
    $ curl -i -X PATCH https://api.example.com/order/XYZ/ -d '{"status": "invoiced"}'
    HTTP/1.1 304 Not modified


#### Webhook Handler

A webhook handler resembles an API except that it does not persist data and is
not required to adhere to the [API design guidelines](apis.md).

.. uml::
   :align: center

   skinparam handwritten true

   cloud data
   agent API
   interface topic

   data -right-> API
   API -right-> topic

Webhook handlers exists to receive notifications from external partners. Its
important that all webhook handlers work together with a scheduled job service
that retrieves notification data that was lost due to failure on notification
handling.


### Service

Services are components that process (consume) messages. These messages are
sent to queues that subscribe to topics. You can also read this as "the services
listen and process messages from topics".

One service consumes messages from one queue, as an input data, processes these
data and then generates an output as a publication on topic or an API request.

The simplest type of service are the 'de-queuers' that basically process
messages from a single queue (that subscribe a single topic).

So a service works following the steps below:

1. Get *one* message from a queue (that subscribes a topic);
2. Process this message (following/applying business rules);
3. Get extra informations requesting them to APIs (optional);
4. Send the result publishing it in a topic or posting *one*
request to an API.

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

The only reponsibility of a service is:

**1. Business Logic**

We implement most of the business logic of our platform in services. This design
allows us to keep API agnostic about Olist's specific business rules.

This approach allow our APIs to be used by other market players, and also allow
us to build services with different business rules for other markets.


#### Broker

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


### Scheduled Job

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


### Client Application

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


## Integrations

We've two kinds of integrations at our platform:

1. **Internal integrations:** when one of our components must interact with
   other component of our platform (eg. service makes a request to an API) and;
2. **External integrations:** when one of our components must interact with
   a component of other platform (eg. service makes a request to one of our
   partner's API).

On both integration scenarios we need to start from the following premisse:

> No matter if a system is internal or external it eventually...
> * ... goes **offline**...
> * ... **crashes**...
> * ... or **change their behaviour without notice**.

So, to make an integration work in a reliable fashion we need to follow some
rules and procedures:

* Be prepared for the worst;
* Create a SLA for all integrations;
* [Monitor](monitoring.md) all aspects of integration (eg. errors, performance,
  availability, etc);
* Always use a [Circuit Breaker](https://martinfowler.com/bliki/CircuitBreaker.html)
  pattern for integration;
* Set a (small) timeout for requests;
* Create a retry policy based on defined SLAs or based on informations at error
  response (eg. `Retry-After:` HTTP header in `503 Service Unavailable`
  responses);
* Handle error responses appropriately: retrying, rolling back, logging, etc;
* All these rules and procedures must be implemented out-of-box in all services.
  No code deployment must be required to handle unavailability scenarios.


## References

* [Some Guidelines For Deciding Whether To Use A Rules Engine](http://herzberg.ca.sandia.gov/guidelines.shtml)

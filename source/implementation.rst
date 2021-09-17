Implementation
==============

E-Mail
------

.. todo:: write this


.. _section-database:

Database
--------

.. todo:: write this

   non-sequential ids, strings instead of enums


.. _section-code:

Code
----

.. todo::

   good code > good doc, early optimization trap, early abstraction trap,
   exception handling the "right way"

Code guidelines and best practices.


General advices
~~~~~~~~~~~~~~~

* Always KISS - Keep It Super Simple.
* All source files must be written in English (variables, functions, classes,
  docstrings and etc). Only strings submitted to our brazilian customers/users
  should be in Portuguese with i18n.
* A code well written is self documented.
* Pay attention to the quality of your code using some indicators like
  cyclomatic complexity or the presence of some `Bad Smell`_.


.. _section-coding-style:

Coding Style
~~~~~~~~~~~~

Coding style is a complex subject with lots of personal preferences and we
believe that this preferences must be respected until the limit where it causes
readability issues to other developers in our team and to keep some level of
consistency on our code base.

Usually we use the coding style proposed by the community of an specific
programming language, eg:

* Python - `PEP-8 – Style Guide for Python Code`_ but also consider important
  writing pythonic code as in `Beyond PEP-8`_ with some customizations (see
  below).
* Go – we use the coding style applied by `gofmt`_ in our Go code
* Elixir - we use the coding styled applied by `_mix_format`_ in our Elixir code


PEP-8 Customizations
""""""""""""""""""""

We use most of the rules defined by PEP-8 except the rules that define the
maximun line length. Instead of 80 characters we define a soft-limit in 120
characters. You are allowed to use more than 120 characters but use it with
moderation.


Tests
~~~~~

.. todo:: expand this session (or move to a new chapter), describe some test
   patterns?

* Unit test every function, method and class.
* Integration tests should assert each part called using mocks or return checks.
* Avoid using VCR-like mocking system. VCR-like libraries store credentials used
  for tests in fixture files and it creates a security breach. The fixtures
  created by them are strongly dependent of the API state, making it hard to
  update the test in the future.
* We don't use test coverage as a metric, but as a way to find use cases not
  tested.
* Features with multiple layers should be tested on all layers (an API endpoint
  should have tests in the manager level (focused in the data) and API level
  (focused in correct HTTP usage)


Configuration
~~~~~~~~~~~~~


.. note:: move this session to other chapter?


* Configuration through environment variables: `12-factor`_ configuration.
* Avoid different configurations for each environment.
* Decouple configurations with libraries like prettyconf.
* Configurations should control only the software behaviour. Business logic
  configurations must be handled like system data; database-stored and
  configured through an administrative interface.
* Configurations that frequently change are good candidates to leave
  configuration files.


Security
~~~~~~~~


.. note:: create a chapter specific for security?


* Sensible and secret data must not be versioned with the code.
* Always follow and apply security patches.
* Dependencies must be kept up to date.
* Only use known and tested security methods and systems.
* Security measures shouldn't be entangled with infrastructure.
* Handle HTTP errors with static pages to avoid exploits.


.. _PEP-8 – Style Guide for Python Code: https://www.python.org/dev/peps/pep-0008/
.. _Beyond PEP-8: https://www.youtube.com/watch?v=wf-BqAjZb8M
.. _gofmt: https://golang.org/cmd/gofmt/
.. _Bad Smell: https://blog.codinghorror.com/code-smells/
.. _\_mix_format: https://hexdocs.pm/mix/master/Mix.Tasks.Format.html
.. _12-factor: https://12factor.net


.. _section-libraries-and-apis:

Libraries and APIs
~~~~~~~~~~~~~~~~~~

.. todo:: move all libraries-API related topics from API chapter here.

.. warning:: **Informations are temporarily in Portuguese but it will be
   rewritten in English in final version of the document.**

* Devem ter changelog.
* Mudar a versão (major) sempre que houver quebra de compatibilidade retroativa.
* Manter a versão anterior dentro de um plano de “deprecation” definido
  previamente em cada projeto.
* O modelo de versionamento deve ser adotado consistentemente em todas as APIs
  de um mesmo projeto.
* Documentação
* Todas as bibliotecas devem ser versionadas segundo as diretrizes de
  versionamento semântico http://semver.org/ ignorando apenas os sufixos como:
  pre, rc, alpha.

  * Formato major.minor.patch;
  * Todas as alterações devem ser acompanhadas pela atualização da versão.

* Manutenção de Changelog atualizado.

  * Podemos usar como referência as `Definições do Projeto GNU`_.

.. _Definições do Projeto GNU: https://www.gnu.org/prep/standards/html_node/Change-Logs.html

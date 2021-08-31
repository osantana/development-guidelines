Integrations
============

.. todo::

   * Create topic structure based on topics at `Parking Lot`_
   * Start writing sections


Parking Lot
-----------


 .. warning:: **Informations are temporarily in Portuguese but it will be
   rewritten in English in final version of the document.**

* Bibliotecas devem gerar logs de comunicação (desligados por padrão).

  * Ver tópico de Logging deste documento.

* Toda comunicação precisa definir um timeout levando em consideração o SLA e as
  integrações das quais este serviço depende. Exemplo::

   Serviço B acessa sincronamente serviço C para atender uma requisição do
   serviço A. O Timeout de A deve ser superior ao timeout de B ao acessar C.

* Preferencialmente as bibliotecas não devem tratar cenários de retentativa.

  * Elas podem levantar exceções indicando que é possível retentar (ex. erros
    5XX) ou não (ex. erros 4XX).
  * Retentativas e circuit breaking são responsabilidade da aplicação que usa a
    biblioteca.

* Tratar exceção em vários níveis:

  * APIError(Exception) - qualquer tipo de erro;
  * CommunicationError(APIError) - erros de Comunicação com API (Timeout, SSLError, Unknown Host, ...);
  * ServerError(APIError) - classe base para erros no servidor;
  * RecoverableError(ServerError) - erros no servidor (ex. erros 5XX);

    * Caso a resposta tenha um Retry-After deve-se preencher o atributo
      retry_after da exceção.

  * ParserError(ServerError) - erro de Parsing (ex. JSON deserialization error);
  * ClientError(APIError) - erros de acesso à API (ex. erros 4XX);
  * {ModelError}(ClientError) - erros específicos da API (ex.UserNotFound(ClientError)).

* Sugestão de API mínima para bibliotecas cliente de webservices (pode-se criar
  camadas extras de abstração às libs mas seria bom ter essa API mínima):

.. code-block:: python

    client = APIClient(credentials=...)  # never throw exception
    client.connect()  # optional method for queue APIs
    try:
       response = client.method(arguments)
    except ...APIErrors...:
       ...
    print(type(response))  # unserialized JSON object as list or dict

* Recomenda-se a proteção contra uso abusivo das APIs Privadas e de parceiros.

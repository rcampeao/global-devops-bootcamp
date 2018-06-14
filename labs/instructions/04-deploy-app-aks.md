# Deploy do Aplicativo de Super-Heróies para o AKS

## Revisar/Editar os arquivos de configuração YAML

1. Em uma sessão do terminal de sua VM, edite o arquivo `heroes-db.yaml` usando `vi`:

    ```bash
    cd ~/global-devops-bootcamp/labs/helper-files

    vi heroes-db.yaml
    ```

    * Revise o arquivo yaml e aprenda como são usadas as configurações e como são setadas as diversas propriedades.
    * Atualize o arquivo yaml para contemplar o nome correto da imagem de nossos containers. Para isso, você deverá substituir o texto `<login server>` com o login server do ACR, criado no laboratório 2.
    * Exemplo:

        ```yaml
        spec:
        containers:
        - image: mycontainerregistry.azurecr.io/azureworkshop/rating-db:v1
            name:  heroes-db-cntnr
        ```

2. Em uma sessão do terminal de sua VM, edite o arquivo  `heroes-web-api.yaml` usando `vi`:

    ```bash
    cd ~/global-devops-bootcamp/labs/helper-files

    vi heroes-web-api.yaml
    ```

    * Revise o arquivo yaml e aprenda como são usadas as configurações e como são setadas as diversas propriedades. Note as variáveis de ambiente que permitem que os serviços se conectem.
    * Atualize o arquivo yaml para contemplar o nome correto da imagem de nossos containers. Para isso, você deverá substituir o texto `<login server>` com o login server do ACR, criado no laboratório 2.
        > Nota: Você atualizará o nome da imagem **DUAS VEZES** neste arquivo (web app e web api).

    * Exemplo:

        ```yaml
        spec:
        containers:
        - image: mycontainerregistry.azurecr.io/azureworkshop/rating-web:v1
            name:  heroes-web-cntnr
        ```

## Configure o AKS para ter acesso ao Azure Container Registry

Existem algumas maneiras de fazer com que clusters do AKS tenham acesso ao seu Azure Container Registry privado. Geralmente, um service account que o kubernetes utiliza terá os direitos necessários para acessar o registry baseado em suas credenciais do Azure. Em nosso laboratório, nós devemos criar um secret para permitir esse acesso.

```bash
# coloque seus valores
ACR_SERVER=
ACR_USER=
ACR_PWD=

kubectl create secret docker-registry acr-secret --docker-server=$ACR_SERVER --docker-username=$ACR_USER --docker-password=$ACR_PWD --docker-email=superman@heroes.com
```

> Nota: Você pode verificar que tanto em `heroes-db.yaml` quanto em `heroes-web-api.yaml` é possível ver que o campo `imagePullSecrets` estão configurados para um secret chamado `acr-secret`.

## Deploy do banco de dados como container no AKS

* Use o CLI do kubectl para fazer o deploy de cada app

    ```bash
    cd ~/global-devops-bootcamp/labs/helper-files

    kubectl apply -f heroes-db.yaml
    ```

* Pegue o nome do pod do mongodb

    ```bash
    $ kubectl get pods

    NAME                                 READY     STATUS    RESTARTS   AGE
    heroes-db-deploy-2357291595-k7wjk    1/1       Running   0          3m

    $ MONGO_POD=$(kubectl get pods --output=jsonpath={.items..metadata.name})
    ```

* Importe os dados para o MongoDB usando o script

    ```bash
    # Assim que rodar o exec dentro do pod, execute o script import.sh

    $ kubectl exec -it $MONGO_POD bash

    root@heroes-db-deploy-2357291595-xb4xm:/# ./import.sh
    2018-01-16T21:38:44.819+0000	connected to: localhost
    2018-01-16T21:38:44.918+0000	imported 4 documents
    2018-01-16T21:38:44.927+0000	connected to: localhost
    2018-01-16T21:38:45.031+0000	imported 72 documents
    2018-01-16T21:38:45.040+0000	connected to: localhost
    2018-01-16T21:38:45.152+0000	imported 2 documents
    root@heroes-db-deploy-2357291595-xb4xm:/# exit

    # não se esqueça de sair do container (exit)
    ```

## Deploy dos containers do web app e web api para o AKS

* Use o CLI do kubectl para fazer o deploy de cada app

    ```bash
    cd ~/global-devops-bootcamp/labs/helper-files

    kubectl apply -f heroes-web-api.yaml
    ```

## Confirmar

* Confirme se todos os pods estão rodando em seu cluster

    ```bash
    $ kubectl get pods

    NAME                                 READY     STATUS    RESTARTS   AGE
    heroes-api-deploy-1140957751-2z16s   1/1       Running   0          2m
    heroes-db-deploy-2357291595-k7wjk    1/1       Running   0          3m
    heroes-web-1645635641-pfzf9          1/1       Running   0          2m
    ```

* Confirme se todos os serviços estão ativos em seu cluster

    ```bash
    kubectl get services

    NAME         TYPE           CLUSTER-IP    EXTERNAL-IP      PORT(S)          AGE
    api          LoadBalancer   10.0.20.156   52.176.104.50    3000:31416/TCP   5m
    kubernetes   ClusterIP      10.0.0.1      <none>           443/TCP          12m
    mongodb      ClusterIP      10.0.5.133    <none>           27017/TCP        5m
    web          LoadBalancer   10.0.54.206   52.165.235.114   8080:32404/TCP   5m
    ```

* Visite o IP externo da sua aplicação web (na porta 8080) e teste o aplicativo!

> Nota: O IP público do Load Balancer pode levar alguns minutos para ser criado e adicionado junto ao seu novo cluster. Se quiser, enquanto espera, essa é a hora de publicar algo legal sobre o DevOps Bootcamp no Facebook! :)
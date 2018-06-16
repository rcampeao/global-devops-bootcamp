# Dockerizando Aplicações

## Buildar as images dos Containers

Para o primeiro container, nós vamos criar um Dockerfile do zero. Para os outros containers, os Dockerfiles serão fornecidos.

### Web Container

1. Crie um Dockerfile

    * Acesse a VM
    * Dentro do diretório `~/global-devops-bootcamp/app/web`, adicione um arquivo chamado 'Dockerfile'.
        * Se você está numa sessão SSH, use VI como seu editor, por exemplo.
        * Se está em sua máquina ou via RDP, você pode usar o Visual Studio Code

    * Adicione as seguintes linhas e salve o 'Dockerfile':

        ```Dockerfile
        FROM node:9.4.0-alpine

        ARG VCS_REF
        ARG BUILD_DATE
        ARG IMAGE_TAG_REF

        ENV GIT_SHA $VCS_REF
        ENV IMAGE_BUILD_DATE $BUILD_DATE
        ENV IMAGE_TAG $IMAGE_TAG_REF

        WORKDIR /usr/src/app
        COPY package*.json ./
        RUN npm install

        COPY . .
        RUN apk --no-cache add curl
        EXPOSE 8080

        CMD [ "npm", "run", "container" ]
        ```

2. Crie uma imagem do container para o web app em node.js, a partir de uma sessão do terminal:

    ```bash
    cd ~/global-devops-bootcamp/app/web

    docker build --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` --build-arg VCS_REF=`git rev-parse --short HEAD` --build-arg IMAGE_TAG_REF=v1 -t rating-web .
    ```

3. Valique que a imagem foi criada com o comando:

    ```bash
    docker images
    ```

### API Container

Nesse passo, o Dockerfile já foi criado para você.

1. Crie a imagem do container para a API do app em node.js:

    ```bash
    cd ~/global-devops-bootcamp/app/api

    docker build -t rating-api .
    ```

2. Valique que a imagem foi criada com o comando:

    ```bash
    docker images
    ```

### MongoDB Container

1. Crie uma imagem do MongoDB com os arquivos de dados pré-carregados:

    ```bash
    cd ~/global-devops-bootcamp/app/db

    docker build -t rating-db .
    ```

2. Valique que a imagem foi criada com o comando:

    ```bash
    docker images
    ```

## Rodar os Containers

### Setup da Rede do Docker

Crie uma bridge na rede do Docker para permitir que os containers possam se comunicar internamente/localmente.

```bash
docker network create --subnet=172.18.0.0/16 my-network
```

### MongoDB Container

1. Rode o container do Mongo

    ```bash
    # Pare o serviço local:
    sudo service mongod stop
    # Suba o container:
    docker run -d --name db --net my-network --ip 172.18.0.10 -p 27017:27017 rating-db
    ```

2. Valide que está rodando

    ```bash
    docker ps -a
    ```

3. Importe os dados em seu banco de dados:

    ```bash
    docker exec -it db bash
    ```

    Neste momento você estará dentro de uma sessão do container do Mongo. Agora, você deverá rodar o script de importação (`./import.sh`):

    ```bash
    $ ./import.sh

    2018-01-10T19:26:07.746+0000	connected to: localhost
    2018-01-10T19:26:07.761+0000	imported 4 documents
    2018-01-10T19:26:07.776+0000	connected to: localhost
    2018-01-10T19:26:07.787+0000	imported 72 documents
    2018-01-10T19:26:07.746+0000	connected to: localhost
    2018-01-10T19:26:07.761+0000	imported 2 documents
    ```

4. Escreva `exit` para sair do container:

    ```bash
    $ exit
    ```

### API Container

1. Suba o container da API:

    ```bash
    docker run -d --name api -e "MONGODB_URI=mongodb://172.18.0.10:27017/webratings" --net my-network --ip 172.18.0.11 -p 3000:3000 rating-api
    ```

    > Note que que as variáveis de ambiente aqui são usadas para conectar a API diretamente ao Mongo.

2. Valide que está rodando

    ```bash
    docker ps -a
    ```

3. Teste a API com curl

    ```bash
    curl http://localhost:3000/api/heroes
    ```

### Web Container

1. Rode o container do web app:

    ```bash
    docker run -d --name web -e "API=http://172.18.0.11:3000/" --net my-network --ip 172.18.0.12 -p 8080:8080 rating-web
    ```

2. Valide que está rodando

    ```bash
    docker ps -a
    ```

3. Teste o web app

    Você pode testar via curl

    ```bash
    curl http://localhost:8080
    ```

    Lembre-se que você também está usando uma VM com IP público, o qual está com a porta 8080 aberta.
    Você pode ir em seu browser e verificar que o aplicativo está rodando através do link: http://xyz.xyz.xyz.xyz:8080 

    > Acesse:  http://IP-DA-SUA-VM:8080

## Publicar no Azure Container Registry (ACR)

Agora que nós temos as imagens dos containers para os componentes da nossa aplicação, nós precisamos guardá-los em um local seguro e centralizado. Neste laboratório nós usaremos o Azure Container Registry para isso.

### Criar instância do Azure Container Registry

1. No seu browser, logue-se no portal do Azure em https://portal.azure.com.
2. Clique em "Create a resource" (Criar um recurso) e selecione "Container Registry"
3. Dê um nome para o seu registry (ele deve ser único)
4. Use o Resource Group existente
5. Habilite o Admin user
6. Use o SKU 'Standard' (padrão)

    > O registry Standard oferece as mesmas capacidades que o Basic, mas com limites de armazenamento e throughput de imagens aumentados. O registry Standard deve satisfazer a maioria dos ambientes em produção.

### Logar em seu ACR com Docker

1. Vá até o seu Container Registry no Portal do Azure
2. Clique em "Access keys"
3. Guarde em um bloco de notas os valores de "Login server", "Username" e "password"
4. Em sua sessão do terminal da VM, atribua cada valor a respectiva variavel abaixo, conforme abaixo:

    ```bash
    # coloque seus valores
    ACR_SERVER=
    ACR_USER=
    ACR_PWD=

    docker login --username $ACR_USER --password $ACR_PWD $ACR_SERVER
    ```

### Coloque Tags nas imagens com o servidor ACR e seu repositório

```bash
docker tag rating-db $ACR_SERVER/azureworkshop/rating-db:v1
docker tag rating-api $ACR_SERVER/azureworkshop/rating-api:v1
docker tag rating-web $ACR_SERVER/azureworkshop/rating-web:v1
```

### Faça o Push das imagens para o registry

```bash
docker push $ACR_SERVER/azureworkshop/rating-db:v1
docker push $ACR_SERVER/azureworkshop/rating-api:v1
docker push $ACR_SERVER/azureworkshop/rating-web:v1
```

O output do comando `docker push` com sucesso deverá ser similar a abaixo:

```
The push refers to a repository [mycontainerregistry.azurecr.io/azureworkshop/rating-db]
035c23fa7393: Pushed
9c2d2977a0f4: Pushed
d7b18f71e002: Pushed
ec41608c0258: Pushed
ea882d709aca: Pushed
74bae5e77d80: Pushed
9cc75948c0bd: Pushed
fc8be3acfc2d: Pushed
f2749fe0b821: Pushed
ddad740d98a1: Pushed
eb228bcf2537: Pushed
dbc5f877c367: Pushed
cfce7a8ae632: Pushed
v1: digest: sha256:f84eba148dfe244f8f8ad0d4ea57ebf82b6ff41f27a903cbb7e3fbe377bb290a size: 3028
```

### Validar imagens no Azure

1. Retorne ao Portal do Azure em seu browser e valide que as images aparecem em seu Container Registry dentro da aba 'Repositories'.
2. Na parte de tags, você verá "v1" listado.

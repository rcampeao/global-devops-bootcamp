# Configurar e Rodar o App Localmente

## Clonar Repo no Github do Lab

Uma vez que você acesse sua VM, você deve clonar o repositório deste bootcamp em sua máquina.

1. Abra o terminal em sua VM.
2. Clone o Github repo via a linha de comando

```bash
git clone https://github.com/CSELATAM/global-devops-bootcamp.git
```

## Subir Aplicações

### Camada do Banco de dados - MongoDB

A camada de persistência dos dados para o app é um [MongoDB](https://www.mongodb.com/ "MongoDB Homepage"). Já foi tudo preparado, você deve apenas importar os dados para a nossa aplicação.

1. Importe os dados (previamente em arquivos json) usando uma sessão do terminal em sua VM

    ```bash
    cd ~/global-devops-bootcamp/app/db

    mongoimport --host localhost:27017 --db webratings --collection heroes --file ./heroes.json --jsonArray && mongoimport --host localhost:27017 --db webratings --collection ratings --file ./ratings.json --jsonArray && mongoimport --host localhost:27017 --db webratings --collection sites --file ./sites.json --jsonArray
    ```

### Camada de API da Aplicação - Node.js

A API para o app foi escrito em javascript, rodando em [Node.js](https://nodejs.org/en/ "Node.js Homepage") e [Express](http://expressjs.com/ "Express Homepage")

1. Atualize as dependências e rode o app usando o node em uma sessão do terminal em sua VM

    ```bash
    cd ~/global-devops-bootcamp/app/api

    npm install && npm run localmachine
    ```

2. Abra uma nova sessão do terminal em sua VM e teste a API com curl

    ```bash
    curl http://localhost:3000/api/heroes
    ```

    > Ou acesse:  http://IP-DA-SUA-VM:3000/api/heroes

### Camada da Web da Aplicação - Vue.js, Node.js

O front-end web deste app foi escrito em [Vue.js](https://vuejs.org/Vue "Vue.js Homepage"), rodando em [Node.js](https://nodejs.org/en/ "Node.js Homepage") com [Webpack](https://webpack.js.org/ "Webpack Homepage")

1. Abra uma **nova** sessão do terminal em sua VM
2. Atualize as dependências e rode o app usando o node

    ```bash
    cd ~/global-devops-bootcamp/app/web

    npm install && npm run localmachine
    ```
3. Teste o front-end web

    > Acesse:  http://IP-DA-SUA-VM:8080

    Você também pode estar de uma nova sessão do terminal em sua VM
    ```bash
    curl http://localhost:8080
    ```

## Limpeza

Feche a sessão web e a api no terminal usando a combinação `ctrl-c` em cada terminal correspondente.
# Global DevOps Bootcamp

*Entregando aplicações modernas nativas de cloud com tecnologias open source no Azure​*

## Visão Geral

Esse workshop irá guiá-lo através de uma migração de uma aplicação "on-premise" para containers rodando em um serviço de Kubernetes no Azure.

Os labs são baseados em uma aplicação node.js que permite a votação de super heróis da Liga da Justiça. A camada de dados é persistida em MongoDB.

> Nota: Os labs foram desenhados para rodar em uma VM Linux Ubuntu no Azure junto com Azure Cloud Shell. Eles devem rodar sem problemas localmente em um Mac ou Windows, mas as instruções não foram escritas exatamente para eles, portando você provavelmente terá que fazer pequenas adaptações. Isso pode prejudicar sua experiência no evento.

## Hands-On-Labs
  0. [Setup do Ambiente do Lab](labs/instructions/00-lab-environment.md)
  1. [Run app locally to test components](labs/instructions/01-setup-app-local.md)
  2. [Create Docker images for apps and push to Azure Container Registry](labs/instructions/02-dockerize-apps.md)
  3. [Create an Azure Kubernetes Service (AKS) cluster](labs/instructions/03-create-aks-cluster.md)
  4. [Deploy application to Azure Kubernetes Service](labs/instructions/04-deploy-app-aks.md)
  5. [Kubernetes UI Overview](labs/instructions/05-kubernetes-ui.md)
  6. [CI/CD Automation](labs/instructions/06-cicd-brigade.md)
  
## Licença

This software is covered under the MIT license. You can read the license [here][license].

This software contains code from Heroku Buildpacks, which are also covered by the MIT license.

This software contains code from [Helm][], which is covered by the Apache v2.0 license.

You can read third-party software licenses [here][Third-Party Licenses].
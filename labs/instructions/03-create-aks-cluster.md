# Criacão do Azure Kubernetes Service (AKS)

## Criar AKS cluster

1. Logue seu cliente no Azure,

```bash
az login
```

> Abra o link https://microsoft.com/devicelogin e entre com o código apresentado no bash.

2. Verifique que a subscrição selecionada por padrão é a correta:

```bash
az account list
```

3. Crie um Resource Group

```bash
location='eastus'
resourcegroup='devops-bootcamp-aks'
az group create --name $resourcegroup --location $location
```

4. Crie o seu cluster de AKS no Resource Group criado acima. Ele terá 2 nós e usará o Kubernetes versão 1.7.7.

> Atenção: O comando abaixo pode levar entre 5 e 25 minutos.

```bash
clustername='myakscluster'

az aks create \
    -n $clustername \
    -g $resourcegroup \
    -l $location \
    -c 2 \
    -k 1.7.7 \
    -s Standard_D2_v2 \
    --generate-ssh-keys
```

5. Verifique o status do seu cluster. O `ProvisioningState` deverá ser `Succeeded`, após completado.

```bash
$ az aks list -o table

Name                 Location    ResourceGroup         KubernetesVersion    ProvisioningState    Fqdn
-------------------  ----------  --------------------  -------------------  -------------------  -------------------------------------------------------------------
ODLaks-v2-gbb-16502  centralus   ODL_aks-v2-gbb-16502  1.7.7                Succeeded             odlaks-v2--odlaks-v2-gbb-16-b23acc-17863579.hcp.centralus.azmk8s.io
```

6. Pegue os arquivos de configuração para o seu novo cluster de AKS

```bash
az aks get-credentials -n $clustername -g $resourcegroup
```

7. Verifique que você tem acesso a API do seu novo cluster de AKS

> Nota: Pode demorar até 5 minutos para que os seus nós aparecem no estado `READY`. Você pode continuamente monitorá-los usando `watch kubectl get nodes`.

```bash
$ kubectl get nodes

NAME                       STATUS    ROLES     AGE       VERSION
aks-nodepool1-20004257-0   Ready     agent     4m        v1.7.7
aks-nodepool1-20004257-1   Ready     agent     4m        v1.7.7
```

Para ver mais detalhes sobre o seu cluster:

```bash
$ kubectl cluster-info

Kubernetes master is running at https://odlaks-v2--odlaks-v2-gbb-11-b23acc-115da6a3.hcp.centralus.azmk8s.io:443
Heapster is running at https://odlaks-v2--odlaks-v2-gbb-11-b23acc-115da6a3.hcp.centralus.azmk8s.io:443/api/v1/namespaces/kube-system/services/heapster/proxy
KubeDNS is running at https://odlaks-v2--odlaks-v2-gbb-11-b23acc-115da6a3.hcp.centralus.azmk8s.io:443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
kubernetes-dashboard is running at https://odlaks-v2--odlaks-v2-gbb-11-b23acc-115da6a3.hcp.centralus.azmk8s.io:443/api/v1/namespaces/kube-system/services/kubernetes-dashboard/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

Você deve ter um cluster de Kubernetes rodando com 2 nós. Você não vê os masters por que eles são gerenciados pela Microsoft.
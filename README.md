# oficina-wagyu-infra-k8s

Infraestrutura como código (Terraform) do cluster Kubernetes da **Oficina
Mecânica Wagyu** — Tech Challenge Fase 3.

## O que este repositório provisiona

- Uma instância **EC2** (Ubuntu 22.04) rodando **K3s** (distribuição leve de
  Kubernetes — inclui `metrics-server` por padrão, necessário para o HPA)
- Security Group liberando SSH (22), API do Kubernetes (6443) e a porta da
  aplicação (30080, via NodePort)
- Os manifestos Kubernetes da aplicação ficam em `/manifests`

## Por que K3s em uma EC2 (em vez de EKS)?

Ver [ADR correspondente](../OficinaMecanicaWagyu/docs/adr/) no repositório da
aplicação: dado o prazo da fase e o escopo do desafio ("cluster Kubernetes
com escalabilidade", sem exigir um serviço gerenciado específico), K3s
atende ao requisito com bem menos custo e complexidade operacional que EKS,
mantendo Deployments, Services, ConfigMaps/Secrets e HPA — os mesmos
recursos que seriam usados em qualquer cluster Kubernetes "de verdade".

## Pré-requisitos

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.6
- Um **Key Pair EC2** já criado na sua conta AWS (Console → EC2 → Key Pairs)
- Credenciais AWS configuradas (ver nota sobre AWS Academy no README do
  repositório `oficina-wagyu-infra-database`)

## Como provisionar

```bash
cp example.tfvars terraform.tfvars
# edite terraform.tfvars com o nome do seu Key Pair

terraform init
terraform plan
terraform apply
```

## Depois de provisionado

1. Busca o kubeconfig (o comando exato aparece no output do Terraform):
   ```bash
   terraform output -raw fetch_kubeconfig_command
   # copie e rode o comando que aparecer
   export KUBECONFIG=./kubeconfig
   kubectl get nodes
   ```

2. Aplica o namespace e o ConfigMap:
   ```bash
   kubectl apply -f manifests/00-namespace.yaml
   kubectl apply -f manifests/01-configmap.yaml
   ```

3. Cria o Secret com os dados reais (connection string do RDS, segredo do
   webhook, segredo JWT compartilhado com a Lambda) — **nunca commitar
   valores reais**, veja `manifests/02-secret.example.yaml` para o formato:
   ```bash
   kubectl create secret generic oficina-api-secret -n oficina-wagyu \
     --from-literal=ConnectionStrings__DefaultConnection="COLE_AQUI_O_OUTPUT_DO_REPO_DE_BANCO" \
     --from-literal=EmailWebhook__Secret='...' \
     --from-literal=Jwt__Secret='...'
   ```

4. Aplica o Deployment/Service/HPA (a imagem correta é publicada pelo
   pipeline do repositório da aplicação — ajuste a URI da imagem no
   manifesto antes, ou deixe que a pipeline de CD faça isso automaticamente):
   ```bash
   kubectl apply -f manifests/03-api-deployment.yaml
   kubectl apply -f manifests/04-hpa.yaml
   ```

5. Acessa a API:
   ```bash
   terraform output api_url
   ```

## Diagrama

```
Internet
   │
   ▼
┌─────────────────────────────────────────┐
│  EC2 (Ubuntu 22.04) — Security Group     │
│  ┌─────────────────────────────────┐    │
│  │            K3s                   │    │
│  │  ┌─────────────┐                 │    │
│  │  │ oficina-api  │  x2 pods (HPA) │    │
│  │  │  Deployment  │────────────────┼────┼──► RDS SQL Server
│  │  └──────┬──────┘                 │    │    (repo infra-database)
│  │         │ Service (NodePort 30080)│   │
│  └─────────┼─────────────────────────┘   │
└────────────┼───────────────────────────────┘
             ▼
     http://<ip-da-ec2>:30080
```

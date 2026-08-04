# Entrega do Projeto Final - Módulo Docker - Aplicação em Docker

---

## Delivery - Projeto Final

Status: Finalizado

Projeto: Curso ADA - Docker 



## Playground (Ferramentas utilizadas)

 Flask - Postegres - Doker - GitHub - Minikube - Drawio - Notion - Gemini - Claude - Adapta One

 

## Arquitetura
<img width="721" height="412" alt="arquitetura" src="https://github.com/user-attachments/assets/2dfbbc41-2df1-438f-8b05-18ad70996a1c" />


---

# Lista dos arquivos

- app.py

- app.dockerfile

Manifesto  Pod (declarativo)

- postgres.yaml
- api-produtos-v2.yaml
- api-produtos-v2-rollingupdate.yaml
- api-produtos-v2-recreate.yaml

Sripts

- abrir-tunel.sh

Testes - CRUD

- crud-1.sh
- crud-2-roll.sh
- crud-3-recre.sh

---

# ::: Subida dos ambientes :::

- Subir o docker desktop

- Subir o minikube - dentro do VS Code

   `minikube start`

# ::: Build e push da imagem no docker hub :::

## Construção da imagem :
`$ docker build . -f app.dockerfile -t andrearms/api-produtos:v2`



## Publicação da imagem no Docker Hub:
`$ docker push andrearms/api-produtos:v2`



## Imagem `api-produtos` publicada no Docker Hub

<img width="1262" height="732" alt="image" src="https://github.com/user-attachments/assets/926952d7-65ac-4e40-910c-6498f4054218" />



# ::: Deploy no cluster (colocando a aplicação no ar) :::

## Criando namespace delivery

`kubectl create ns delivery` 



## Deployment do Pod Banco** (dentro da declaração namespace: delivery)

`kubectl apply -f postgres.yaml`

<img width="570" height="57" alt="image 1" src="https://github.com/user-attachments/assets/398953b1-7221-4cfb-83a8-6215b6b8aabc" />



#  Verificar  o pod no namespace (delivery)

`kubectl get po -n delivery` 

<img width="508" height="57" alt="image 2" src="https://github.com/user-attachments/assets/cfcdab46-3ac1-41ed-8451-21bca9ee13e3" />



## Deployment do Pod APP   (dentro da declaração namespace: delivery)

`kubectl apply -f api-produtos-v2.yaml`

<img width="590" height="122" alt="image 3" src="https://github.com/user-attachments/assets/a59a3411-824e-4c37-8a07-d08f1c43a452" />



##  Verificar  o pod no namespace (delivery)

`kubectl get po -n delivery` 

<img width="510" height="103" alt="image 4" src="https://github.com/user-attachments/assets/506aa788-f33f-418e-be8d-af35ee74ea09" />



---

# ::: Como saber a url para chegar no cluster :::

**Services**

Pods dentro do cluster são **isolados**. Sem um Service, ninguém de fora consegue acessar
O Service é a "porta de entrada" que permite acesso externo.

`kubectl get svc -n delivery`

<img width="602" height="107" alt="image 5" src="https://github.com/user-attachments/assets/2b5ee545-d28a-4d63-93c6-8cf1ea647cf3" />




Com os services acima,  pedi ao Minikube para dar a URL pública:

`minikube service api-service-1 -n delivery --url`

<img width="676" height="41" alt="image 6" src="https://github.com/user-attachments/assets/5884f07e-24ad-4d0a-af63-73107dd44717" />

<img width="672" height="38" alt="image 7" src="https://github.com/user-attachments/assets/0360d7c3-2fc9-4693-baeb-2fc284cff667" />

<img width="632" height="40" alt="image 8" src="https://github.com/user-attachments/assets/20fab3e5-f30e-45a1-aa74-8054e5e64d75" />


---

`http://127.0.0.1`

---

MAs para funcionar foi necessário abri um túnel da minha máquina até o POD para tanto utilizei o **port-forward** 

`kubectl port-forward -n delivery svc/api-service-1 5000:5000 &

kubectl port-forward -n delivery svc/api-service-2 5001:5000 &

kubectl port-forward -n delivery svc/api-service-3 5002:5000 &`

> Que é o script - abrir-tunel.sh
>
> 

# ::: Requisições - Cada operação do CRUD vira um comando curl:::

O `curl` é a ferramenta que simula um cliente usando sua API. Você manda um comando, a API processa, e devolve a resposta em JSON.

📝 Create  - api-produtos-1 → POD  1

`curl -X POST [http://127.0.0.1:5000/produtos](http://127.0.0.1:5000/produtos) -H "Content-Type: application/json" -d '{"nome": "Chocovelvet"}'`

📝 Create  - api-produtos-2 → POD  2

`curl -X POST http://127.0.0.1:5001/produtos -H "Content-Type: application/json" -d '{"nome": "Laranjeira"}'`

📝 Create  - api-produtos-3 → POD  3

`curl -X POST http://127.0.0.1:5002/produtos -H "Content-Type: application/json" -d '{"nome": "Chocomelo"}'`

📖 Read (Listar todos produtos) - api-produtos-2 → POD  2

`curl http://127.0.0.1:5001/produtos`

**📖 Read (Pede a API o produto ID 1) -** api-produtos-3 → POD  3

`curl http://127.0.0.1:5002/produtos/1`

🔄 Update (Atualizar - Pede pra atualizar o produto 1, trocando o nome para "cafe-termo".) - api-produtos-1 → POD  1

`curl -X PUT http://127.0.0.1:5000/produtos/1 -H "Content-Type: application/json" -d '{"nome": "cafe-termo"}'`

❌ Delete (Deletar o ID 1) -  api-produtos-2 → POD  2

`curl -X DELETE http://127.0.0.1:5001/produtos/1`

# ::: Rolling Update:::

Fechar o túnel

Terminal 2: Monitorar Pods

`kubectl get pods -n delivery -w`

Deploy

`kubectl apply -f api-produtos-v2-rollingupdate.yaml`

Acompanhar o processo de deployment

Registro dos pods - para fazer comparação de pods antes e depois do deploy - exibido status / restars / age

`kubectl get po -n delivery`

Abrir o túnel

Teste CRUD

`./crud-2-roll.sh`

# ::: Recreate:::

> Quando você não quer múltiplas versões rodando simultaneamente!
> 

Fechar o túnel

Terminal 2: Monitorar o deploy nos Pods

`kubectl get pods -n delivery -w`

Deploy

`kubectl apply -f api-produtos-v2-recreate.yaml`

Acompanhar o processo de deployment

Registro dos pods - para fazer comparação de pods antes e depois do deploy - exibido status / restars / age

`kubectl get po -n delivery`

Abrir o túnel

Teste CRUD

`./crud-3-recre.sh`

# ::: Logs::

Após as requisições

# Confira os logs dos containers:
`$ kubectl logs -n delivery <nome-do-pod>`

# ::: Status e Histórico do Deploy :::

# status do rollout

 `kubectl rollout status -w deployment/api-produtos-1 -n delivery`

# histórico de revisões

 `kubectl rollout history deployment/api-produtos-1 -n delivery`

![image.png](image%209.png)

# Explicação do port-forward

explique esse comando de minikube kubectl port-forward -n delivery svc/api-service-1 5000:5002

Esse comando **serve para criar um túnel de acesso entre o seu computador local e um serviço rodando dentro do cluster Kubernetes** (Minikube).

Ele permite que você teste ou consuma a API diretamente da sua máquina sem precisar expor o serviço para a internet pública.

**Breakdown do Comando**

- **`kubectl port-forward`**: Inicia o redirecionamento de portas do Kubernetes. [[1](https://kubernetes.io/pt-br/docs/tasks/access-application-cluster/port-forward-access-application-cluster/)]
- **`n delivery`**: Especifica o **Namespace** chamado `delivery` onde o serviço está rodando.
- **`svc/api-service-1`**: Indica o **Serviço** alvo (`svc` é a abreviação de Service) com o nome `api-service-1`.
- **`5000:5002`**: Define as portas no formato **`PortaLocal:PortaNoCluster`**.
    - **`5000`**: A porta que será aberta na sua máquina local (`localhost:5000`).
    - **`5002`**: A porta interna na qual o serviço `api-service-1` está ouvindo dentro do Kubernetes.

**Na Prática**

Após rodar esse comando, você pode abrir o seu navegador ou usar o Postman e acessar:`http://localhost:5000`

O Kubernetes vai pegar todas as requisições enviadas para essa porta e mandar diretamente para a porta `5002` do seu serviço dentro do Minikube. O comando precisa continuar rodando no terminal para o túnel funcionar.

---

💡 Se você quiser avançar no teste dessa API, me avise se prefere que eu ajude a:

- Criar uma requisição **cURL** para testar o funcionamento desse túnel.
- Verificar os **logs** desse serviço caso a conexão falhe.
- Listar outros **serviços ativos** nesse mesmo namespace.

**A IA pode cometer erros. Por isso, cheque as respostas**

- 
    
    [](https://encrypted-tbn3.gstatic.com/faviconV2?url=https://kubernetes.io&client=AIM&size=128&type=FAVICON&fallback_opts=TYPE,SIZE,URL)
    
    Kubernetes
    
    **Use o redirecionamento de porta para acessar aplicativos em um cluster.**
    
    25 de mai. de 2023 — Use o redirecionamento de porta para acessar aplicativos em um cluster. Esta página mostra como usar o kubectl port-forward para s...
    

para que serve o targetport abaixo

apiVersion: v1
kind: Service
metadata:
  name: api-service-3
  namespace: delivery
spec:
  selector:
    app: api-produtos
    instance: "3"
  ports:
    - port: 5002
      targetPort: 5000
  type: NodePort

O **`targetPort`** serve **para definir a porta real onde a sua aplicação (o Pod) está rodando e ouvindo os acessos dentro do contêiner**.

Em termos simples: o Serviço funciona como um "guardador de trânsito". O `targetPort` diz para ele exatamente para qual porta interna ele deve direcionar os acessos que recebe.

**Entendendo a diferença entre `port` e `targetPort`**

Com base no seu arquivo YAML:

- **`port: 5002`**: É a porta **do Serviço**. Outros componentes de dentro do cluster Kubernetes usam essa porta para conversar com o seu serviço `api-service-3`.
- **`targetPort: 5000`**: É a porta **do Pod (da sua aplicação)**. O serviço vai pegar tudo o que chegar na porta `5002` e repassar para a porta `5000` dentro do seu contêiner.

**O Fluxo da Requisição**

Como o tipo do seu serviço é `NodePort`, o caminho que o trânsito faz é o seguinte:

1. A requisição chega em uma porta aleatória do nó (NodePort).
2. O nó envia para a **`port: 5002`** do Serviço.
3. O Serviço redireciona para a **`targetPort: 5000`** do Pod (onde sua aplicação `api-produtos` realmente responde).

Se o seu código da aplicação (em Node.js, Python, Java, etc.) estiver configurado para rodar na porta `5000`, o `targetPort` precisa ser obrigatoriamente `5000`.

---

💡 Se quiser garantir que tudo funcione, me avise se você prefere:

- Ver como mapear isso no **Deployment** dos seus Pods.
- Descobrir qual **porta externa (NodePort)** o Kubernetes gerou para esse serviço.
- Ajustar o comando **port-forward** anterior para usar essa nova configuração de portas.

tenho 3 pods rodando na porta 5000 mas esses pods tem porta de serviços diferentes, é isso?

Sim, **é exatamente isso!** Essa é uma arquitetura muito comum no Kubernetes.

Todos os seus Pods (os contêineres com o código da aplicação) podem rodar internamente na porta **5000**. Quem diferencia o acesso a eles do lado de fora são os **Serviços**, que usam portas ou nomes diferentes.

**Por que isso funciona?**

Cada Pod no Kubernetes funciona como se fosse uma "máquina virtual" isolada. Ele ganha um endereço de IP próprio e exclusivo. [[1](https://alysonsilva.dev/blog/pods-executando-containers-no-kubernetes), [2](https://www.ionos.com/pt-br/digitalguide/servidor/configuracao/kubernetes-pod/)]

- O **Pod 1** tem seu próprio IP e usa a porta 5000.
- O **Pod 2** tem outro IP e também usa a porta 5000.
- O **Pod 3** tem outro IP e também usa a porta 5000. [[1](https://alysonsilva.dev/blog/pods-executando-containers-no-kubernetes), [2](https://alysonsilva.dev/blog/pods-executando-containers-no-kubernetes)]

Como eles estão isolados em IPs diferentes, as portas deles não entram em conflito. [[1](https://alysonsilva.dev/blog/pods-executando-containers-no-kubernetes)]

**O papel dos Serviços**

Como os IPs dos Pods mudam toda vez que eles reiniciam, você cria os **Serviços** como uma porta de entrada fixa. [[1](https://www.reddit.com/r/kubernetes/comments/o6kmpa/ip_of_database_change_every_time_the_pod_restart/?tl=pt-br)]

Você pode perfeitamente criar a seguinte estrutura no seu cluster:

- **Serviço 1**: Ouve na porta `5001` → joga para o **Pod 1** na porta `5000`.
- **Serviço 2**: Ouve na porta `5002` → joga para o **Pod 2** na porta `5000`.
- **Serviço 3**: Ouve na porta `5003` → joga para o **Pod 3** na porta `5000`.

O Kubernetes usa as regras de **`selector`** (como o `instance: "3"` que você mostrou no exemplo anterior) para saber exatamente qual serviço conversa com qual pod.

---

apiVersion: v1
kind: Service
metadata:
  name: api-service-3
  namespace: delivery
spec:
  selector:
    app: api-produtos
    instance: "3"
  ports:
    - port: 5002
      targetPort: 5000
  type: NodePort

Com base no arquivo YAML que você enviou, aqui está a explicação detalhada de como o Kubernetes vai encontrar o Pod específico para este serviço.

O Kubernetes usa o bloco **`spec.selector`** para fazer o mapeamento. Para este serviço funcionar, você deve ter um Pod (ou um Deployment) configurado exatamente com as mesmas etiquetas (**labels**).

**Como deve ser o YAML do seu Pod ou Deployment**

Para o `api-service-3` encontrar o seu terceiro Pod, o arquivo de configuração daquele Pod precisa ter essas labels no campo `metadata.labels`. Veja o exemplo prático:

**yaml**

```
apiVersion: apps/v1kind: Deploymentmetadata:name: api-produtos-v3namespace: deliveryspec:replicas:1selector:matchLabels:app: api-produtosinstance:"3"template:metadata:labels:app: api-produtos# <--- Bate com o selector do seu Serviçoinstance:"3"# <--- Bate com o selector do seu Serviçospec:containers:
        -name: api-containerimage: sua-imagem-aquiports:
            -containerPort:5000# <--- Bate com o targetPort do seu Serviço
```

Use o código com cuidado.

**O que acontece nos bastidores?**

1. O Serviço `api-service-3` varre o namespace `delivery` procurando por Pods.
2. Ele ignora os Pods com `instance: "1"` ou `instance: "2"`.
3. Ele se conecta **apenas** ao Pod que possui simultaneamente as labels `app: api-produtos` E `instance: "3"`.
4. Ele envia o tráfego recebido na porta `5002` para a porta `5000` desse Pod específico.

---

💡 Para garantir que a comunicação está funcionando agora, me avise se prefere:

- Ver o comando para **listar as labels** dos seus Pods atuais e checar se estão certas.
- Aprender o comando para ver os **Endpoints** e confirmar se o Serviço achou o Pod.
- Entender como atualizar o comando **port-forward** usando os dados desse novo YAML.

veja o código completo
apiVersion: v1
kind: Service
metadata:
  name: api-service-1
  namespace: delivery
spec:
  selector:
    app: api-produtos
    instance: "1"
  ports:
    - port: 5000
      targetPort: 5000
  type: NodePort
---
apiVersion: v1
kind: Service
metadata:
  name: api-service-2
  namespace: delivery
spec:
  selector:
    app: api-produtos
    instance: "2"
  ports:
    - port: 5001
      targetPort: 5000
  type: NodePort
---
apiVersion: v1
kind: Service
metadata:
  name: api-service-3
  namespace: delivery
spec:
  selector:
    app: api-produtos
    instance: "3"
  ports:
    - port: 5002
      targetPort: 5000
  type: NodePort

Análise perfeita. Esse arquivo YAML resume exatamente toda a lógica que discutimos e está 100% correto para a estratégia que você desenhou.

Cada um dos três serviços funciona como uma "ponte exclusiva" para um Pod específico, mesmo que todas as suas aplicações rodem internamente na porta **5000**.

**O Mapa de Conexões do seu Cluster**

O Kubernetes vai interpretar o seu arquivo exatamente desta forma:

- **`api-service-1`**: Ouve na porta do cluster **5000** → Direciona para o Pod com a etiqueta `instance: "1"` na porta **5000**.
- **`api-service-2`**: Ouve na porta do cluster **5001** → Direciona para o Pod com a etiqueta `instance: "2"` na porta **5000**.
- **`api-service-3`**: Ouve na porta do cluster **5002** → Direciona para o Pod com a etiqueta `instance: "3"` na porta **5000**.

**Por que essa configuração é útil?**

Esse modelo (um serviço por instância) é muito utilizado quando você precisa de **comunicação direcionada estável**. Por exemplo:

1. **Sharding/Particionamento**: Onde cada Pod cuida de uma parte específica dos dados (ex: Pod 1 cuida de clientes de A-F, Pod 2 de G-M, etc.).
2. **Ambientes de Teste/A/B**: Onde você quer testar versões ligeiramente diferentes da API de forma isolada antes de juntar tudo.

**Conectando com sua primeira pergunta**

Agora que você tem o mapa completo, repare como os comandos de `port-forward` fariam sentido na sua máquina para testar cada um deles individualmente:

- Para testar a instância 1: `kubectl port-forward -n delivery svc/api-service-1 5000:5000`
- Para testar a instância 2: `kubectl port-forward -n delivery svc/api-service-2 5000:5001`
- Para testar a instância 3: `kubectl port-forward -n delivery svc/api-service-3 5000:5002`

---

💡 Sabendo disso, me avise se prefere prosseguir para:

- Descobrir como o **Minikube** abre o acesso externo via navegador usando o comando `minikube service`.
- Ver como criar um **quarto serviço** que distribua o peso de forma igual entre os 3 pods ao mesmo tempo (Load Balancer).
- Validar se a configuração dos **Deployments** correspondentes a esses serviços está correta.

o meu forward está assim

!/bin/bash

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}    ABRINDO TUNNEL - PORT-FORWARD${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

echo -e "${GREEN}✓ Abrindo port-forward Container 1 (porta 5000)${NC}"
kubectl port-forward -n delivery svc/api-service-1 5000:5000 &
echo ""

echo -e "${GREEN}✓ Abrindo port-forward Container 2 (porta 5001)${NC}"
kubectl port-forward -n delivery svc/api-service-2 5001:5001 &
echo ""

echo -e "${GREEN}✓ Abrindo port-forward Container 3 (porta 5002)${NC}"
kubectl port-forward -n delivery svc/api-service-3 5002:5002 &
echo ""

echo ""
echo -e "${GREEN} === ✅ TUNNEL ABERTO COM SUCESSO! === ${NC}"
echo ""

echo ""
echo -e "${GREEN}Containers disponíveis em:${NC}"
echo -e "  - http://127.0.0.1:5000 (Container 1)"
echo -e "  - http://127.0.0.1:5001 (Container 2)"
echo -e "  - http://127.0.0.1:5002 (Container 3)"
echo ""
echo -e "${GREEN}Pressione CTRL+C para fechar o tunnel${NC}"
echo ""

#

O seu script Bash está muito bem estruturado e a lógica visual está excelente, mas ele tem **um pequeno erro de configuração nas portas** que vai impedir o acesso ao Container 2 e ao Container 3.

O problema está no formato do mapeamento do `port-forward` (`PortaLocal:PortaNoCluster`).

**⚠️ O que está errado e por que vai falhar?**

Olhando para os seus comandos atuais no script:

1. `kubectl port-forward ... svc/api-service-2 5001:5001`
2. `kubectl port-forward ... svc/api-service-3 5002:5002`

Se olharmos o seu arquivo YAML anterior:

- O `api-service-2` foi configurado com a porta interna **`5001`**. Portanto, o comando está correto.
- O `api-service-3` foi configurado com a porta interna **`5002`**. Portanto, o comando também está correto.

**Onde está a pegadinha?** No seu primeiro comando do script anterior, você usou:`kubectl port-forward -n delivery svc/api-service-1 5000:5002` (Local 5000 acessando a porta 5002 do cluster).

Se você alterou o YAML do `api-service-1` para a porta **5000** (como enviou no último código completo), o seu script atual vai funcionar perfeitamente. Mas se o YAML do `api-service-1` ainda estiver usando a porta antiga, você precisará ajustar a linha dele.

**🛠️ Script Corrigido e Otimizado**

Aqui está o script ajustado assumindo que você está usando as portas oficiais do seu último arquivo YAML (`5000`, `5001` e `5002` respectivamente).

Também adicionei um comando `wait` no final. Sem ele, como os processos rodam em segundo plano (`&`), o script terminaria imediatamente e o comando `CTRL+C` não fecharia os túneis automaticamente.

**bash**

```
#!/bin/bash# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'# Função para matar todos os port-forwards em segundo plano quando der CTRL+C
trap'echo -e "\n${BLUE}Fechando túneis...${NC}"; kill $(jobs -p); exit' SIGINT

echo -e"${BLUE}========================================${NC}"
echo -e"${BLUE}    ABRINDO TUNNEL - PORT-FORWARD${NC}"
echo -e"${BLUE}========================================${NC}"
echo""

echo -e"${GREEN}✓ Abrindo port-forward Container 1 (porta local 5000 -> svc 5000)${NC}"
kubectl port-forward -n delivery svc/api-service-15000:5000 > /dev/null2>&1 &

echo -e"${GREEN}✓ Abrindo port-forward Container 2 (porta local 5001 -> svc 5001)${NC}"
kubectl port-forward -n delivery svc/api-service-25001:5001 > /dev/null2>&1 &

echo -e"${GREEN}✓ Abrindo port-forward Container 3 (porta local 5002 -> svc 5002)${NC}"
kubectl port-forward -n delivery svc/api-service-35002:5002 > /dev/null2>&1 &

echo""
echo -e"${GREEN} === ✅ TUNNEL ABERTO COM SUCESSO! === ${NC}"
echo""

echo -e"${GREEN}Containers disponíveis em:${NC}"
echo -e"  - http://127.0.0.1:5000 (Container 1)"
echo -e"  - http://127.0.0.1:5001 (Container 2)"
echo -e"  - http://127.0.0.1:5002 (Container 3)"
echo""
echo -e"${GREEN}Pressione CTRL+C para fechar todos os túneis com segurança${NC}"
echo""# Mantém o script rodando para o TRAP capturar o CTRL+C
wait
```

Use o código com cuidado.

**O que mudou aqui?**

1. **`> /dev/null 2>&1`**: Esconde o texto padrão do Kubernetes ("*Forwarding from 127.0.0.1...*"). Isso deixa a saída do seu script limpa e bonita como você planejou.
2. **`trap ... SIGINT` e `wait`**: Garante que quando você apertar `CTRL+C`, o script capture o comando e mate os 3 port-forwards que ficaram rodando escondidos em segundo plano, evitando portas presas na sua máquina.

---

💡 Se precisar de mais ajustes no ambiente, escolha como quer prosseguir:

- Aprender como testar se as rotas estão respondendo usando um comando **curl** direto no script.
- Ver o que fazer caso dê o erro de **porta já em uso** (Address already in use).
- Configurar uma verificação prévia para saber se o **Minikube está ativo** antes de abrir o túnel.

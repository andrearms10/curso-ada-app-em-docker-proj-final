# Projeto Final - Módulo Docker - Aplicação em Docker

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



## Deployment do Pod Banco (dentro da declaração namespace: delivery)

`kubectl apply -f postgres.yaml`

<img width="570" height="57" alt="image 1" src="https://github.com/user-attachments/assets/398953b1-7221-4cfb-83a8-6215b6b8aabc" />



##  Verificar  o pod no namespace (delivery)

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

Pods dentro do cluster são **isolados**. Sem um Service, ninguém de fora consegue acessar.
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

**Mas para funcionar foi necessário abrir um túnel da minha máquina até o POD para tanto utilizei o** **port-forward** **

`kubectl port-forward -n delivery svc/api-service-1 5000:5000 &

kubectl port-forward -n delivery svc/api-service-2 5001:5000 &

kubectl port-forward -n delivery svc/api-service-3 5002:5000 &`

> Que é o script - abrir-tunel.sh

 

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

- Fechar o túnel

- Terminal 2: Monitorar Pods

   `kubectl get pods -n delivery -w`

- Deploy

   `kubectl apply -f api-produtos-v2-rollingupdate.yaml`

- Acompanhar o processo de deployment

- Registro dos pods - para fazer comparação de pods antes e depois do deploy - exibido status / restars / age

   `kubectl get po -n delivery`

- Abrir o túnel

- Teste CRUD

   `./crud-2-roll.sh`

  

# ::: Recreate:::

> Quando você não quer múltiplas versões rodando simultaneamente!
 

- Fechar o túnel

- Terminal 2: Monitorar o deploy nos Pods

   `kubectl get pods -n delivery -w`

- Deploy

   `kubectl apply -f api-produtos-v2-recreate.yaml`

- Acompanhar o processo de deployment

- Registro dos pods - para fazer comparação de pods antes e depois do deploy - exibido status / restars / age

   `kubectl get po -n delivery`

- Abrir o túnel

- Teste CRUD

   `./crud-3-recre.sh`


  ---
  

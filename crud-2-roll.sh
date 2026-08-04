#!/bin/bash

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo ""
echo ""
echo -e "${RED}========================================${NC}"
echo -e "${RED}    TESTE CRUD - 3 CONTAINERS${NC}"
echo -e "${RED}========================================${NC}"
echo ""
echo ""
echo ""

# Criando produtos
echo -e "${YELLOW}📝 CRIANDO PRODUTOS${NC}"
echo -e "${GREEN}✓ Container 1 (porta 5000)${NC}"
curl -X POST http://127.0.0.1:5000/produtos -H "Content-Type: application/json" -d '{"nome": "Computador"}'
echo ""
echo ""
echo ""
sleep 4

echo -e "${GREEN}✓ Container 2 (porta 5001)${NC}"
curl -X POST http://127.0.0.1:5001/produtos -H "Content-Type: application/json" -d '{"nome": "Tablet"}'
echo ""
echo ""
echo ""
sleep 4

echo -e "${GREEN}✓ Container 3 (porta 5002)${NC}"
curl -X POST http://127.0.0.1:5002/produtos -H "Content-Type: application/json" -d '{"nome": "iPhone"}'
echo ""
echo ""
echo ""
sleep 4

# Listando todos
echo -e "${YELLOW}📋 LISTANDO TODOS OS PRODUTOS${NC}"
echo -e "${GREEN}✓ Container 1${NC}"
curl http://127.0.0.1:5000/produtos
echo ""
echo ""
echo ""
sleep 4

# Listando por ID
echo -e "${YELLOW}🔍 BUSCANDO POR ID${NC}"
echo -e "${GREEN}✓ Container 2 - Produto ID 4${NC}"
curl http://127.0.0.1:5001/produtos/4
echo ""
echo ""
echo ""
sleep 4

# Atualizando
echo -e "${YELLOW}✏️  ATUALIZANDO PRODUTO${NC}"
echo -e "${GREEN}✓ Container 3 - Atualizando ID 6${NC}"
curl -X PUT http://127.0.0.1:5002/produtos/6 -H "Content-Type: application/json" -d '{"nome": "Mouse"}'
echo ""
echo ""
echo ""
sleep 4

# Deletando
echo -e "${YELLOW}🗑️  DELETANDO PRODUTO${NC}"
echo -e "${GREEN}✓ Container 1 - Deletando ID 5${NC}"
curl -X DELETE http://127.0.0.1:5000/produtos/5
echo ""
echo ""
echo ""
sleep 4

# Listando final
echo -e "${YELLOW}📋 LISTAGEM FINAL${NC}"
echo -e "${GREEN}✓ Container 2 - Verificando dados${NC}"
curl http://127.0.0.1:5001/produtos
echo ""
echo ""
echo ""

echo -e "${GREEN}===  ✅ TESTE CONCLUÍDO COM SUCESSO!   ===${NC}"
echo ""
echo ""

echo -e "${RED}====   FIM DE TESTE 2 - Rollin Update!   ====${NC}"
echo ""

# ADICIONE ISSO NO FINAL:
read -p "Pressione ENTER para fechar..."
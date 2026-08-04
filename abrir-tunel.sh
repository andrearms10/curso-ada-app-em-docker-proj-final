#!/bin/bash

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Função para matar todos os port-forwards em segundo plano quando der CTRL+C
trap 'echo -e "\n${BLUE}Fechando túneis...${NC}"; kill $(jobs -p); exit' SIGINT

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}    ABRINDO TUNNEL - PORT-FORWARD${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

echo -e "${GREEN}✓ Abrindo port-forward Container 1 (porta 5000)${NC}"
kubectl port-forward -n delivery svc/api-service-1 5000:5000 > /dev/null 2>&1 &
echo ""

echo -e "${GREEN}✓ Abrindo port-forward Container 2 (porta 5001)${NC}"
kubectl port-forward -n delivery svc/api-service-2 5001:5001 > /dev/null 2>&1 &
echo ""

echo -e "${GREEN}✓ Abrindo port-forward Container 3 (porta 5002)${NC}"
kubectl port-forward -n delivery svc/api-service-3 5002:5002 > /dev/null 2>&1 &
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

# Espera infinito (mantém tunnel aberto)
wait
#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Testing LLM Deployment${NC}"
echo "=================================="

# Get service endpoint
echo -e "\n${YELLOW}1. Getting service endpoint...${NC}"
LLM_IP=$(kubectl get service llm-inference -n llm-inference -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)

if [ -z "$LLM_IP" ]; then
    echo -e "${RED}Error: Service not ready yet. External IP not assigned.${NC}"
    echo "Run: kubectl get svc -n llm-inference"
    exit 1
fi

echo -e "${GREEN}Service IP: $LLM_IP${NC}"
LLM_ENDPOINT="http://$LLM_IP"

# Test health endpoint
echo -e "\n${YELLOW}2. Testing health endpoint...${NC}"
if curl -s -f "$LLM_ENDPOINT/health" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Health check passed${NC}"
else
    echo -e "${RED}✗ Health check failed${NC}"
    exit 1
fi

# List available models
echo -e "\n${YELLOW}3. Listing available models...${NC}"
MODELS=$(curl -s "$LLM_ENDPOINT/v1/models" 2>/dev/null)
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Models endpoint accessible${NC}"
    echo "$MODELS" | jq '.' 2>/dev/null || echo "$MODELS"
else
    echo -e "${RED}✗ Models endpoint failed${NC}"
fi

# Test text generation
echo -e "\n${YELLOW}4. Testing text generation...${NC}"
RESPONSE=$(curl -s "$LLM_ENDPOINT/v1/completions" \
    -H "Content-Type: application/json" \
    -d '{
        "model": "mistralai/Mistral-7B-Instruct-v0.2",
        "prompt": "What is Kubernetes?",
        "max_tokens": 50,
        "temperature": 0.7
    }' 2>/dev/null)

if [ $? -eq 0 ] && [ ! -z "$RESPONSE" ]; then
    echo -e "${GREEN}✓ Text generation successful${NC}"
    echo -e "\nResponse:"
    echo "$RESPONSE" | jq '.choices[0].text' 2>/dev/null || echo "$RESPONSE"
else
    echo -e "${RED}✗ Text generation failed${NC}"
    exit 1
fi

# Performance test
echo -e "\n${YELLOW}5. Running quick performance test...${NC}"
echo "Sending 5 requests..."
TOTAL_TIME=0
for i in {1..5}; do
    START_TIME=$(date +%s.%N)
    curl -s "$LLM_ENDPOINT/v1/completions" \
        -H "Content-Type: application/json" \
        -d '{
            "model": "mistralai/Mistral-7B-Instruct-v0.2",
            "prompt": "Hello",
            "max_tokens": 10,
            "temperature": 0.7
        }' > /dev/null 2>&1
    END_TIME=$(date +%s.%N)
    REQUEST_TIME=$(echo "$END_TIME - $START_TIME" | bc)
    TOTAL_TIME=$(echo "$TOTAL_TIME + $REQUEST_TIME" | bc)
    echo "  Request $i: ${REQUEST_TIME}s"
done

AVG_TIME=$(echo "scale=2; $TOTAL_TIME / 5" | bc)
echo -e "${GREEN}Average response time: ${AVG_TIME}s${NC}"

echo -e "\n${GREEN}=================================="
echo -e "All tests passed! ✓${NC}"
echo -e "=================================="
echo -e "\nLLM Endpoint: $LLM_ENDPOINT"
echo -e "API Documentation: $LLM_ENDPOINT/docs"


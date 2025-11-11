#!/bin/bash

BASE_URL="http://localhost:8080"

echo "🧪 Testing Cafecitos API - POST and GET"
echo "========================================"
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Test 1: Health Check
echo -e "${BLUE}📊 Test 1: Health Check${NC}"
curl -s "$BASE_URL/health" | jq '.'
echo ""
echo ""

# Test 2: GET all modules (antes de crear)
echo -e "${BLUE}📚 Test 2: GET all modules (before creating)${NC}"
curl -s "$BASE_URL/api/modules" | jq '.'
echo ""
echo ""

# Test 3: POST - Create a new module
echo -e "${BLUE}✨ Test 3: POST - Create new module${NC}"
NEW_MODULE=$(curl -s -X POST "$BASE_URL/api/modules" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Técnicas Avanzadas de Barista",
    "description": "Aprende técnicas profesionales de café de especialidad",
    "sort_order": 3,
    "is_active": true
  }')

echo "$NEW_MODULE" | jq '.'
MODULE_ID=$(echo "$NEW_MODULE" | jq -r '.id')
echo ""
echo -e "${GREEN}✅ Module created with ID: $MODULE_ID${NC}"
echo ""
echo ""

# Test 4: GET all modules (después de crear)
echo -e "${BLUE}📚 Test 4: GET all modules (after creating)${NC}"
curl -s "$BASE_URL/api/modules" | jq '.'
echo ""
echo ""

# Test 5: GET specific module by ID
echo -e "${BLUE}🔍 Test 5: GET module by ID: $MODULE_ID${NC}"
curl -s "$BASE_URL/api/modules/$MODULE_ID" | jq '.'
echo ""
echo ""

# Test 6: PUT - Update module
echo -e "${BLUE}✏️ Test 6: PUT - Update module${NC}"
curl -s -X PUT "$BASE_URL/api/modules/$MODULE_ID" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Técnicas Avanzadas de Barista - Actualizado",
    "description": "Aprende técnicas profesionales de café de especialidad con métodos modernos"
  }' | jq '.'
echo ""
echo ""

# Test 7: POST - Create a lesson for the module
echo -e "${BLUE}✨ Test 7: POST - Create lesson for module${NC}"
NEW_LESSON=$(curl -s -X POST "$BASE_URL/api/lessons" \
  -H "Content-Type: application/json" \
  -d "{
    \"module_id\": \"$MODULE_ID\",
    \"title\": \"Latte Art Básico\",
    \"content_url\": \"https://example.com/latte-art-basics\",
    \"sort_order\": 1,
    \"is_active\": true
  }")

echo "$NEW_LESSON" | jq '.'
LESSON_ID=$(echo "$NEW_LESSON" | jq -r '.id')
echo ""
echo -e "${GREEN}✅ Lesson created with ID: $LESSON_ID${NC}"
echo ""
echo ""

# Test 8: GET lessons for module
echo -e "${BLUE}📖 Test 8: GET lessons for module $MODULE_ID${NC}"
curl -s "$BASE_URL/api/modules/$MODULE_ID/lessons" | jq '.'
echo ""
echo ""

# Test 9: GET specific lesson
echo -e "${BLUE}🔍 Test 9: GET lesson by ID: $LESSON_ID${NC}"
curl -s "$BASE_URL/api/lessons/$LESSON_ID" | jq '.'
echo ""
echo ""

# Test 10: DELETE lesson (optional - uncomment to delete)
# echo -e "${BLUE}🗑️ Test 10: DELETE lesson${NC}"
# curl -s -X DELETE "$BASE_URL/api/lessons/$LESSON_ID" -w "\nHTTP Status: %{http_code}\n"
# echo ""
# echo ""

# Test 11: DELETE module (optional - uncomment to delete)
# echo -e "${BLUE}🗑️ Test 11: DELETE module${NC}"
# curl -s -X DELETE "$BASE_URL/api/modules/$MODULE_ID" -w "\nHTTP Status: %{http_code}\n"
# echo ""
# echo ""

echo -e "${GREEN}✅ All tests completed!${NC}"
echo ""
echo "📝 Created Resources:"
echo "  Module ID: $MODULE_ID"
echo "  Lesson ID: $LESSON_ID"
echo ""
echo "💡 To delete the test data, uncomment the DELETE tests in this script"

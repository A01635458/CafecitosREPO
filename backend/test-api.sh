#!/bin/bash

# Script para probar todos los endpoints de la API

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

API_URL="http://localhost:8080"

echo -e "${BLUE}╔════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Cafecitos API Test Suite        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════╝${NC}"
echo ""

# Test 1: Health Check
echo -e "${YELLOW}[TEST 1]${NC} Health Check..."
RESPONSE=$(curl -s "${API_URL}/health")
if [[ $RESPONSE == *"ok"* ]]; then
    echo -e "${GREEN}✓ API is running${NC}"
else
    echo -e "${RED}✗ API is not responding${NC}"
    exit 1
fi

# Test 2: Crear un usuario
echo -e "${YELLOW}[TEST 2]${NC} Creating user..."
USER_RESPONSE=$(curl -s -X POST "${API_URL}/api/users" \
    -H "Content-Type: application/json" \
    -d '{
        "name": "Test User",
        "email": "test@cafecitos.com",
        "description": "Usuario de prueba"
    }')

USER_ID=$(echo $USER_RESPONSE | grep -o '"id":"[^"]*' | cut -d'"' -f4)

if [ ! -z "$USER_ID" ]; then
    echo -e "${GREEN}✓ User created with ID: ${USER_ID}${NC}"
else
    echo -e "${RED}✗ Failed to create user${NC}"
    echo "Response: $USER_RESPONSE"
fi

# Test 3: Crear un módulo
echo -e "${YELLOW}[TEST 3]${NC} Creating module..."
MODULE_RESPONSE=$(curl -s -X POST "${API_URL}/api/modules" \
    -H "Content-Type: application/json" \
    -d '{
        "title": "Introducción a la Fotografía",
        "description": "Aprende los conceptos básicos de fotografía",
        "sortOrder": 1,
        "isActive": true
    }')

MODULE_ID=$(echo $MODULE_RESPONSE | grep -o '"id":"[^"]*' | cut -d'"' -f4)

if [ ! -z "$MODULE_ID" ]; then
    echo -e "${GREEN}✓ Module created with ID: ${MODULE_ID}${NC}"
else
    echo -e "${RED}✗ Failed to create module${NC}"
    echo "Response: $MODULE_RESPONSE"
fi

# Test 4: Crear una lección
echo -e "${YELLOW}[TEST 4]${NC} Creating lesson..."
LESSON_RESPONSE=$(curl -s -X POST "${API_URL}/api/lessons" \
    -H "Content-Type: application/json" \
    -d "{
        \"module\": {\"id\": \"${MODULE_ID}\"},
        \"title\": \"Lección 1: Exposición\",
        \"contentUrl\": \"https://example.com/lesson1\",
        \"sortOrder\": 1,
        \"isActive\": true
    }")

LESSON_ID=$(echo $LESSON_RESPONSE | grep -o '"id":"[^"]*' | cut -d'"' -f4)

if [ ! -z "$LESSON_ID" ]; then
    echo -e "${GREEN}✓ Lesson created with ID: ${LESSON_ID}${NC}"
else
    echo -e "${RED}✗ Failed to create lesson${NC}"
    echo "Response: $LESSON_RESPONSE"
fi

# Test 5: Listar lecciones del módulo
echo -e "${YELLOW}[TEST 5]${NC} Fetching module lessons..."
LESSONS=$(curl -s "${API_URL}/api/modules/${MODULE_ID}/lessons")
if [[ $LESSONS == *"$LESSON_ID"* ]]; then
    echo -e "${GREEN}✓ Lessons retrieved successfully${NC}"
else
    echo -e "${RED}✗ Failed to retrieve lessons${NC}"
fi

# Test 6: Actualizar progreso
echo -e "${YELLOW}[TEST 6]${NC} Updating user progress..."
PROGRESS_RESPONSE=$(curl -s -X POST "${API_URL}/api/progress" \
    -H "Content-Type: application/json" \
    -d "{
        \"user\": {\"id\": \"${USER_ID}\"},
        \"lesson\": {\"id\": \"${LESSON_ID}\"},
        \"status\": \"in_progress\"
    }")

if [[ $PROGRESS_RESPONSE == *"in_progress"* ]]; then
    echo -e "${GREEN}✓ Progress updated successfully${NC}"
else
    echo -e "${RED}✗ Failed to update progress${NC}"
fi

# Test 7: Crear una foto
echo -e "${YELLOW}[TEST 7]${NC} Creating photo..."
PHOTO_RESPONSE=$(curl -s -X POST "${API_URL}/api/photos" \
    -H "Content-Type: application/json" \
    -d "{
        \"user\": {\"id\": \"${USER_ID}\"},
        \"url\": \"https://example.com/photo.jpg\",
        \"caption\": \"Mi primera foto de prueba\",
        \"visibility\": \"public\"
    }")

PHOTO_ID=$(echo $PHOTO_RESPONSE | grep -o '"id":"[^"]*' | cut -d'"' -f4)

if [ ! -z "$PHOTO_ID" ]; then
    echo -e "${GREEN}✓ Photo created with ID: ${PHOTO_ID}${NC}"
else
    echo -e "${RED}✗ Failed to create photo${NC}"
fi

# Test 8: Listar fotos del usuario
echo -e "${YELLOW}[TEST 8]${NC} Fetching user photos..."
PHOTOS=$(curl -s "${API_URL}/api/users/${USER_ID}/photos")
if [[ $PHOTOS == *"$PHOTO_ID"* ]]; then
    echo -e "${GREEN}✓ Photos retrieved successfully${NC}"
else
    echo -e "${RED}✗ Failed to retrieve photos${NC}"
fi

# Test 9: Crear una nota
echo -e "${YELLOW}[TEST 9]${NC} Creating note..."
NOTE_RESPONSE=$(curl -s -X POST "${API_URL}/api/notes" \
    -H "Content-Type: application/json" \
    -d "{
        \"user\": {\"id\": \"${USER_ID}\"},
        \"lesson\": {\"id\": \"${LESSON_ID}\"},
        \"title\": \"Nota de prueba\",
        \"body\": \"Esta es una nota sobre la lección de exposición\"
    }")

NOTE_ID=$(echo $NOTE_RESPONSE | grep -o '"id":"[^"]*' | cut -d'"' -f4)

if [ ! -z "$NOTE_ID" ]; then
    echo -e "${GREEN}✓ Note created with ID: ${NOTE_ID}${NC}"
else
    echo -e "${RED}✗ Failed to create note${NC}"
fi

# Test 10: Obtener progreso del usuario
echo -e "${YELLOW}[TEST 10]${NC} Fetching user progress..."
USER_PROGRESS=$(curl -s "${API_URL}/api/users/${USER_ID}/progress")
if [[ $USER_PROGRESS == *"$LESSON_ID"* ]]; then
    echo -e "${GREEN}✓ User progress retrieved successfully${NC}"
else
    echo -e "${RED}✗ Failed to retrieve user progress${NC}"
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     All tests completed! 🎉        ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Created Resources:${NC}"
echo "User ID:    ${USER_ID}"
echo "Module ID:  ${MODULE_ID}"
echo "Lesson ID:  ${LESSON_ID}"
echo "Photo ID:   ${PHOTO_ID}"
echo "Note ID:    ${NOTE_ID}"
echo ""
echo -e "${YELLOW}View in browser:${NC}"
echo "All modules: ${API_URL}/api/modules"
echo "All lessons: ${API_URL}/api/lessons"
echo "User photos: ${API_URL}/api/users/${USER_ID}/photos"
echo ""
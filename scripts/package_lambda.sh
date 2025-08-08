#!/bin/bash
set -e
GREEN='\033[0;32m'
RESET='\033[0m'  # Reset color

SRC_DIR="lambda_src"
ZIP_FILE="lambda.zip"

# Cleanup
echo "${GREEN}Removing old zip if exists...${RESET}"
rm -f "$ZIP_FILE"

# Install deps
echo "${GREEN}Installing Python dependencies...${RESET}"
pip install -r "$SRC_DIR/requirements.txt" -t "$SRC_DIR/"

# Zip everything
echo "${GREEN}Creating deployment package...${RESET}"
cd "$SRC_DIR"
zip -r "../$ZIP_FILE" ./*
cd ..

echo "${GREEN}[✓] Done: created $ZIP_FILE${RESET}"

#!/bin/bash

# ============================================================================
# Headless Batch Fix Script
# Usage: ./scripts/batch-fix.sh "description of pattern to fix"
#
# Examples:
#   ./scripts/batch-fix.sh "Find all Swift files handling SQLite data and fix literal \\n characters"
#   ./scripts/batch-fix.sh "Find all JSON field name mismatches between frontend and backend"
#   ./scripts/batch-fix.sh "Find all missing localization string handling in iOS code"
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ -z "$1" ]; then
    echo -e "${RED}Error:${NC} Please provide a description of the pattern to fix."
    echo ""
    echo "Usage: $0 \"description of pattern to fix\""
    echo ""
    echo "Examples:"
    echo "  $0 \"Find all Swift files handling SQLite data and fix literal \\\\n characters\""
    echo "  $0 \"Find all JSON field name mismatches between frontend and backend\""
    echo "  $0 \"Find all missing localization string handling in iOS code\""
    exit 1
fi

PROMPT="$1"

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}  Batch Fix: ${PROMPT}${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

claude -p "${PROMPT}. Only edit files that need it. After all changes, run a build check to verify nothing is broken. Show me a summary of all changes made." \
    --allowedTools "Read,Edit,Bash" \
    --model claude-sonnet-4-20250514

echo ""
echo -e "${GREEN}Done!${NC}"

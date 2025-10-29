#!/bin/bash

# Web Deployment Script for GitHub Pages
# This script builds the Flutter web app and deploys it to gh-pages branch
#
# Usage: ./deploy_web.sh

set -e  # Exit on any error

echo "🚀 Starting web deployment..."

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo -e "${BLUE}📍 Current branch: $CURRENT_BRANCH${NC}"

# Warning if not on dev branch
if [ "$CURRENT_BRANCH" != "dev" ]; then
    echo -e "${YELLOW}⚠️  Warning: You're deploying from '$CURRENT_BRANCH' branch (usually we deploy from 'dev')${NC}"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Deployment cancelled."
        exit 1
    fi
fi

# Check for uncommitted changes
if [[ -n $(git status -s) ]]; then
    echo -e "${RED}⚠️  You have uncommitted changes:${NC}"
    git status -s
    echo -e "${YELLOW}Please commit or stash them first.${NC}"
    exit 1
fi

# Clean previous build
echo -e "${BLUE}🧹 Cleaning previous build...${NC}"
flutter clean > /dev/null 2>&1

# Get dependencies
echo -e "${BLUE}📦 Getting dependencies...${NC}"
flutter pub get > /dev/null 2>&1

# Build web app
echo -e "${BLUE}🔨 Building web app (this may take 30-60 seconds)...${NC}"
flutter build web --release --base-href "/countdown-app/" --target lib/main_web.dart

# Check if build was successful
if [ ! -d "build/web" ]; then
    echo -e "${RED}❌ Build failed - build/web directory not found${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Build successful!${NC}"

# Create a temporary directory for gh-pages content
TEMP_DIR=$(mktemp -d)
echo -e "${BLUE}📁 Copying build to temporary directory...${NC}"

# Copy build files to temp directory
cp -r build/web/* "$TEMP_DIR/"

# Add .nojekyll file (tells GitHub Pages not to use Jekyll)
touch "$TEMP_DIR/.nojekyll"

echo -e "${BLUE}📋 Build files copied to: $TEMP_DIR${NC}"

# Switch to gh-pages branch
echo -e "${BLUE}🔀 Switching to gh-pages branch...${NC}"
git checkout gh-pages

# Remove ALL old files except .git directory
echo -e "${BLUE}🗑️  Cleaning gh-pages branch...${NC}"
find . -maxdepth 1 ! -name '.git' ! -name '.' ! -name '..' -exec rm -rf {} +

# Copy new build files from temp to gh-pages
echo -e "${BLUE}📥 Copying new build files...${NC}"
cp -r "$TEMP_DIR"/* .
cp "$TEMP_DIR"/.nojekyll .

# Add all files
git add -A

# Check if there are changes to commit
if git diff --staged --quiet; then
    echo -e "${YELLOW}ℹ️  No changes detected - deployment skipped${NC}"
    git checkout "$CURRENT_BRANCH"
    rm -rf "$TEMP_DIR"
    exit 0
fi

# Commit with timestamp
COMMIT_MSG="deploy: web app from $CURRENT_BRANCH ($(date '+%Y-%m-%d %H:%M:%S'))"
echo -e "${BLUE}💾 Committing: $COMMIT_MSG${NC}"
git commit -m "$COMMIT_MSG"

# Push to remote gh-pages
echo -e "${BLUE}⬆️  Pushing to GitHub...${NC}"
git push origin gh-pages

# Switch back to original branch
echo -e "${BLUE}🔙 Switching back to $CURRENT_BRANCH...${NC}"
git checkout "$CURRENT_BRANCH"

# Clean up temp directory
rm -rf "$TEMP_DIR"

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║          ✅ DEPLOYMENT SUCCESSFUL! ✅                  ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}🌐 Your web app is deployed to:${NC}"
echo -e "${BLUE}   https://dashwhiz.github.io/countdown-app/${NC}"
echo ""
echo -e "${YELLOW}⏳ GitHub Pages may take 1-2 minutes to update${NC}"
echo -e "${YELLOW}   Refresh the page if you don't see changes immediately${NC}"
echo ""

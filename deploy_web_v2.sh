#!/bin/bash

# Web Deployment Script for GitHub Pages (v2 - Safe)
# This version NEVER switches branches, so it won't delete gitignored files
#
# Usage: ./deploy_web_v2.sh

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

# Create a temporary git directory for gh-pages
TEMP_GIT_DIR=$(mktemp -d)
echo -e "${BLUE}📁 Creating temporary git directory...${NC}"

# Initialize a new git repo in temp directory
cd "$TEMP_GIT_DIR"
git init
git remote add origin $(git -C "$OLDPWD" config --get remote.origin.url)

# Fetch only gh-pages branch
echo -e "${BLUE}📥 Fetching gh-pages branch...${NC}"
git fetch origin gh-pages --depth=1 || echo "No existing gh-pages branch"

# Create orphan gh-pages branch or checkout existing
if git ls-remote --heads origin gh-pages | grep -q gh-pages; then
    git checkout gh-pages
else
    git checkout --orphan gh-pages
fi

# Remove all files in temp repo
rm -rf *

# Copy build files from main project
echo -e "${BLUE}📋 Copying build files...${NC}"
cp -r "$OLDPWD/build/web/"* .

# Add .nojekyll file
touch .nojekyll

# Check if there are changes to commit
if git diff --staged --quiet 2>/dev/null && git diff --quiet 2>/dev/null && [ -z "$(git ls-files --others --exclude-standard)" ]; then
    echo -e "${YELLOW}ℹ️  No changes detected - deployment skipped${NC}"
    cd "$OLDPWD"
    rm -rf "$TEMP_GIT_DIR"
    exit 0
fi

# Add all files
git add -A

# Commit with timestamp
COMMIT_MSG="deploy: web app from $CURRENT_BRANCH ($(date '+%Y-%m-%d %H:%M:%S'))"
echo -e "${BLUE}💾 Committing: $COMMIT_MSG${NC}"
git commit -m "$COMMIT_MSG" || echo "No changes to commit"

# Push to remote gh-pages
echo -e "${BLUE}⬆️  Pushing to GitHub...${NC}"
git push -f origin gh-pages

# Go back to original directory
cd "$OLDPWD"

# Clean up temp directory
rm -rf "$TEMP_GIT_DIR"

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

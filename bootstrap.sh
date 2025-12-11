#!/usr/bin/env zsh

set -e

SKILLS_DIR="${HOME}/.claude/skills"
SCRIPT_DIR="${0:A:h}"

git -C "$SCRIPT_DIR" pull origin main

function doIt() {
    mkdir -p "$SKILLS_DIR"

    rsync \
        --exclude ".git/" \
        --exclude ".gitignore" \
        --exclude ".DS_Store" \
        --exclude "bootstrap.sh" \
        --exclude "README.md" \
        --exclude "LICENSE*.txt" \
        -avh --no-perms "$SCRIPT_DIR/" "$SKILLS_DIR/"

    echo "Skills installed to $SKILLS_DIR"
}

if [[ "$1" == "--force" || "$1" == "-f" ]]; then
    doIt
else
    read -q "REPLY?This may overwrite existing files in $SKILLS_DIR. Are you sure? (y/n) "
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        doIt
    fi
fi

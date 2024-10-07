#!/bin/bash -e

GH=gh
GIT=git
if [[ -n "$GITHUB_ACTIONS" ]]; then
  # Ensure that we're starting from a clean state
  git reset --hard origin/main
elif [[ "$1" != "-f" ]]; then
  # Do a dry-run when script it executed locally, unless the
  # force flag is specified (-f).
  echo "Doing a dry-run when run locally. Use -f as the first argument to force execution."
  GH="echo > DRY RUN: gh "
  GIT="echo > DRY RUN: git "
else
  # Local execution with -f flag (force real vs. dry run)
  shift
fi

LATEST_TAG=$(git describe --tags --always --abbrev=0)
REPOSITORY="JamieDanielson/test-actions-2"
FOLDER="bin/$REPOSITORY"
BRANCH_NAME="update-docs-to-$LATEST_TAG"

# Clone the remote repository and change working directory to the
# folder it was cloned to.
git clone --depth=1 --branch=main https://JamieDanielson:$GH_PAT@github.com/$REPOSITORY.git $FOLDER

cd $FOLDER

# Setup the committers identity.
git config user.email "jamieedanielson@gmail.com"
git config user.name "Jamie Danielson"

# Create a new feature branch for the changes.
$GIT checkout -b $BRANCH_NAME

# Update the script files to the latest version.
echo $pwd
cp -R ../../../docs/heygirl.md docs/heygirl.md

# Commit the changes and push the feature branch to origin
$GIT add .
$GIT commit -m "chore: update docs to $LATEST_TAG"
$GIT push origin $BRANCH_NAME

# Store the PAT in a file that can be accessed by the
# GitHub CLI.
echo "$GH_PAT" > token.txt

# Authorize GitHub CLI for the current repository and
# create a pull-requests containing the updates.
$GH auth login --with-token < token.txt
$GH pr create --body "update docs" --title "chore: update docs to $LATEST_TAG"

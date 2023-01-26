#!/bin/bash

echo "GITHUB_TOKEN: ${GITHUB_TOKEN}"

# github login
echo ${GITHUB_TOKEN} | gh auth login --with-token

# clonando repositorio
gh repo clone ${GITHUB_REPOSITORY}

cd $(echo ${GITHUB_REPOSITORY} | cut -d "/" -f2)/

GITHUB_TAGS=$(gh release list)

if [ "$(gh release list | grep Latest | awk '{print $9 " " $2}')" == " Latest" ]
then
  MAJOR_VERSION=$(gh release list | grep Latest | awk '{print $9 " " $1}' | cut -d "v" -f2 | cut -d "." -f1)
  MINOR_VERSION=$(gh release list | grep Latest | awk '{print $9 " " $1}' | cut -d "v" -f2 | cut -d "." -f2)
  PATCH_VERSION=$(gh release list | grep Latest | awk '{print $9 " " $1}' | cut -d "v" -f2 | cut -d "." -f3)
  PATCH_VERSION=$((PATCH_VERSION+1))
  gh release create v${MAJOR_VERSION}.${MINOR_VERSION}.${PATCH_VERSION} --generate-notes
else
  gh release create v0.0.1 --generate-notes
fi
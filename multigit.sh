#!/bin/bash
## changelog
# v1.0 added automatic PR creation using bitbucket-cli

## README
# have pip installed
# run: sudo python -m pip install bitbucket-cli
# see - https://bitbucket.org/zhemao/bitbucket-cli/src/master/

## SETTINGS
# bitbucket credentials down below for automatic PR creation
BB_USERNAME='secret'
BB_PASSWORD='secret'
BB_OWNER='dynalean'
BB_REPO='vfde-ose'

# colors
NOCOLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'

# target branches
BRANCHES=(
develop-wave5-6.3-ftcr
release/6.2.0
release/6.2.1
release/6.3.0
release/6.3.1
release/7.0.0
develop-wave5
)

## SCRIPT STARTS HERE
read -p "desired target branch basename: "  TARGETBRANCHNAME
echo -e "${BLUE} $TARGETBRANCHNAME-xxxxx chosen ${NOCOLOR}"
read -p "commit to be cherry-picked: " CHERRYCOMMIT
echo -e "${BLUE}commit = ${CHERRYCOMMIT} ${NOCOLOR}"
for BRANCH in "${BRANCHES[@]}";
do
    echo -e "${BLUE}checking out branch $BRANCH ${NOCOLOR}"
    git checkout $BRANCH;
    echo -e "${BLUE}pulling latest changes ${NOCOLOR}"
    git pull > /dev/null 2>&1;
    echo -e "${BLUE}checking out branch ${TARGETBRANCHNAME}-${BRANCH: -5} ${NOCOLOR}"
    git checkout -B ${TARGETBRANCHNAME}-${BRANCH: -5}
    echo -e "${BLUE}cherry picking ${CHERRYCOMMIT} ${NOCOLOR}"
    if git cherry-pick ${CHERRYCOMMIT}; then
        echo -e "${GREEN}cherry picking succesfull, pushing to remote for branch ${BRANCH}"
        git push;
        bitbucket pull_request ${TARGETBRANCHNAME}-${BRANCH: -5} ${BRANCH} --username ${BB_USERNAME} --password ${BB_PASSWORD} --reponame ${BB_REPO} --owner ${BB_OWNER} --title "PR for ${TARGETBRANCHNAME}-${BRANCH: -5}"
        echo -e "${GREEN}PR created${BRANCH}"
    else
        echo -e "${RED}failed automatic cherry-picked without conflicts on branch ${BRANCH} please fix this manually ${NOCOLOR}";
        git status;
        exit 1;
    fi
done

echo -e "${GREEN}multi git successfull ${NOCOLOR}"

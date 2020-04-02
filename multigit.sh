#!/bin/bash

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
function run() {
    if command -v jq > /dev/null; then 
        read -p "desired target branch basename: "  TARGETBRANCHNAME
        echo -e "${BLUE} $TARGETBRANCHNAME-xxxxx chosen ${NOCOLOR}"
        read -p "commit to be cherry-picked: " CHERRYCOMMIT
        echo -e "${BLUE}commit = ${CHERRYCOMMIT} ${NOCOLOR}"
        COMMITMSG="$(git log --format=%B -n 1 ${CHERRYCOMMIT})"
        setDefaultRepoReviewers
        echo ${DEFAULT_REVIEWERS}

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
                createPullRequest;
                echo -e "${GREEN}PR created for branch ${BRANCH}"
            else
                echo -e "${RED}failed automatic cherry-picked without conflicts on branch ${BRANCH} please fix this manually ${NOCOLOR}";
                git status;
                exit 1;
            fi
        done

        echo -e "${GREEN}multi git successfull ${NOCOLOR}"
    else
        echo -e "${RED}jq is not installed exiting...${NOCOLOR}";
        exit1;
    fi
}

function createPullRequest() {
    curl https://api.bitbucket.org/2.0/repositories/${BB_OWNER}/${BB_REPO}/pullrequests \
    -u ${BB_USERNAME}:${BB_PASSWORD} \
    --request POST \
    --header 'Content-Type: application/json' \
    --data '{"title": "'"${COMMITMSG}"'","source": {"branch": {"name": "'"${TARGETBRANCHNAME}-${BRANCH: -5}"'"}},"destination": {"branch": {"name": "'"${BRANCH}"'"}},"reviewers": ['"${DEFAULT_REVIEWERS}"']}'
}

function setDefaultRepoReviewers() {
    DEFAULT_REVIEWERS_RAW="$(curl https://api.bitbucket.org/2.0/repositories/${BB_OWNER}/${BB_REPO}/default-reviewers\?pagelen\=100 -u ${BB_USERNAME}:${BB_PASSWORD} --request GET | jq '[.values[] | {uuid: .uuid}]' | jq 'del(.[0])')"
    DEFAULT_REVIEWERS_CUT=${DEFAULT_REVIEWERS_RAW:2}
    DEFAULT_REVIEWERS=${DEFAULT_REVIEWERS_CUT%??}
}

run

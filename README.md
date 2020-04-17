# Multigit
Script to create multiple matching PR to target-branches

# Prerequisites
 * curl 
 * jq - https://stedolan.github.io/jq/download/
 * see https://developer.atlassian.com/bitbucket/api/2/reference/resource/ for bb api doc


# Changelog
 * v1.0 added automatic PR creation using bitbucket-cli
 * v2.0 changed to curl and bb api to have default reviewers.

# How to use
* setup credentials for automatic PR creation
* choose your targetbranches by editing the script.
* execute using `./multigit.sh`
* provide targetbranch name
* provide commit hash to be cherry-picked

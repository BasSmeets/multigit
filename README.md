# Multigit
Script to create multiple matching PR to target-branches

# Prerequisites
 * python3, pip 
 * `pip install bitbucket-cli`
 * uses : https://bitbucket.org/zhemao/bitbucket-cli/src/master/


# Changelog
 * v1.0 added automatic PR creation using bitbucket-cli

# How to use
* setup credentials for automatic PR creation
* choose your targetbranches by editing the script.
* execute using `./multigit.sh`
* provide targetbranch name
* provide commit hash to be cherry-picked

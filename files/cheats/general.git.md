# Git useful commands

## git push and create ( if required )

    git push orign HEAD

- Push the current local branch
- Create the remote branch on origin if it doesn’t exist
- Does not rely on any local/global Git config

Equivalent to:

    git push origin $(git branch --show-current)

both resolve to
    
    current-local-branch → origin/current-local-branch

Or you can set the global config and use `git push` all provide the same outcome

    git config --global push.autoSetupRemote true
    git push

## git push and update orign 

Use this if you have renamed a branch that was already pushed.

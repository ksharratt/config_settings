# Git rebase steps

## Update repos

    git checkout master
    git pull --all


# Rebase your repo

    git checkout <your branch name>
    git rebase -i master


# Rebase continue (after fixing merge conficts, editor is easier here)

    git rebase --continue


# Verify 

    git log


# Modify commit message if its not as expected

    git commit --amend

# Rebase to squash commits - last 2 commits in this example

    git rebase -i HEAD~2
    git push --force-with-lease


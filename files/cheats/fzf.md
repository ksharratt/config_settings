# Default Keybindings for fzf

CTRL-T:
    Opens fzf to search for files and directories in the current working directory.

    Example: Quickly find and insert file paths into your command.

---

CTRL-R:
    Searches through your shell history using fzf.

    Example: Retrieve and reuse previous commands efficiently.

---

ALT-C:
    Opens fzf to search for directories and changes to the selected directory.
    
    Example: Navigate to a directory without typing the full path.


# Customizing Keybindings

You can customize these keybindings by editing your shell configuration file (e.g., .bashrc, .zshrc). For example:
Bash# Example: Custom keybinding for fzf

    export FZF_CTRL_T_COMMAND='find . -type f'
    export FZF_ALT_C_COMMAND='find . -type d'


# Shell Integration

To enable these keybindings, ensure you have the fzf shell integration set up. You can do this by running:

    Bash$(fzf --install)



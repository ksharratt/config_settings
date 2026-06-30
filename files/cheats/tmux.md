# tmux quick reference (prefix = Ctrl+Space)

# Sessions
tmux                     # start new session
tmux new -s <name>       # start named session
tmux ls                  # list sessions
tmux attach -t <name>    # attach to session
tmux kill-session -t <name>   # kill session
Prefix d                 # detach
Prefix s                 # list/switch sessions
Prefix $                 # rename session

# Windows (tabs)
Prefix c                 # new window
Prefix n                 # next window
Prefix p                 # previous window
Prefix w                 # list windows
Prefix 0-9               # jump to window number
Prefix ,                 # rename window
Prefix &                 # kill window

# Panes (splits)
Prefix %                 # split vertical
Prefix "                 # split horizontal
Prefix x                 # close pane
Prefix o                 # cycle panes
Prefix q                 # show pane numbers
Prefix z                 # zoom/unzoom pane
Prefix {                 # swap pane left
Prefix }                 # swap pane right
Prefix ←/→/↑/↓           # move between panes

# Copy mode
Prefix [                 # enter copy mode
q                        # exit copy mode
Space                    # start selection (in copy mode)
Enter                    # copy selection
Prefix ]                 # paste

# Misc
Prefix ?                 # help / list keybinds
Prefix :                 # command prompt
Prefix r                 # reload config (if bound)

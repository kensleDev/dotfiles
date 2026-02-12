# __     __         _       _     _           
# \ \   / /_ _ _ __(_) __ _| |__ | | ___  ___ 
#  \ \ / / _` | '__| |/ _` | '_ \| |/ _ \/ __|
#   \ V / (_| | |  | | (_| | |_) | |  __/\__ \
#    \_/ \__,_|_|  |_|\__,_|_.__/|_|\___||___/

source ~/.config/zsh/variables

#  ____  _             _           
# |  _ \| |_   _  __ _(_)_ __  ___ 
# | |_) | | | | |/ _` | | '_ \/ __|
# |  __/| | |_| | (_| | | | | \__ \
# |_|   |_|\__,_|\__, |_|_| |_|___/
#                |___/             

source ~/.config/zsh/plugins


#  _____                 _   _                 
# |  ___|   _ _ __   ___| |_(_) ___  _ __  ___ 
# | |_ | | | | '_ \ / __| __| |/ _ \| '_ \/ __|
# |  _|| |_| | | | | (__| |_| | (_) | | | \__ \
# |_|   \__,_|_| |_|\___|\__|_|\___/|_| |_|___/

source ~/.config/zsh/functions
source ~/.config/zsh/fzf_functions

#     _    _ _                     
#    / \  | (_) __ _ ___  ___  ___ 
#   / _ \ | | |/ _` / __|/ _ \/ __|
#  / ___ \| | | (_| \__ \  __/\__ \
# /_/   \_\_|_|\__,_|___/\___||___/
                                 
source ~/.config/zsh/aliases


theme=agnoster

# eval "$(mise activate zsh)"


# OpenClaw Completion
# source <(openclaw completion --shell zsh)
source <(NODE_NO_WARNINGS=1 openclaw completion --shell zsh 2>/dev/null)


# opencode
export PATH=/home/kd/.opencode/bin:$PATH

# # This file must be used with "source <venv>/bin/activate.fish" *from fish*
# # (https://fishshell.com/). You cannot run it directly.

# function deactivate -d "Exit virtual environment and return to normal shell environment"
#     # reset old environment variables
#     if test -n "$_OLD_FISH_PROMPT_OVERRIDE"
#         set -e _OLD_FISH_PROMPT_OVERRIDE
#         # prevents error when using nested fish instances (Issue #93858)
#         if functions -q _old_fish_prompt
#             functions -e fish_prompt
#             functions -c _old_fish_prompt fish_prompt
#             functions -e _old_fish_prompt
#         end
#     end
#     set -e NIX_ENV
#     if test "$argv[1]" != nondestructive
#         # Self-destruct!
#         functions -e deactivate
#     end
# end

# # Unset irrelevant variables.
# deactivate nondestructive

# set -gx NIX_ENV foo
# # Save the current fish_prompt function as the function _old_fish_prompt.
# functions -c fish_prompt _old_fish_prompt

# # With the original prompt function renamed, we can override with our own.
# function fish_prompt
#     # Save the return status of the last command.
#     set -l old_status $status

#     # Output the venv prompt; color taken from the blue of the Nix logo.
#     printf "%s%s%s " (set_color 7CB5E0)  (set_color normal)

#     # Restore the return status of the previous command.
#     echo "exit $old_status" | .
#     # Output the original/"old" prompt.
#     _old_fish_prompt
# end

# set -gx _OLD_FISH_PROMPT_OVERRIDE "$NIX_ENV"

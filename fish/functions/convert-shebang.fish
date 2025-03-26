function convert-shebang
    set -l file "$argv[1]"
    if test -z "$file"
        echo "Usage: convert-shebang <file>"
        return 1
    end
    sed -i '1s|^#!.*bash|#!/usr/bin/env bash|' "$file"
end

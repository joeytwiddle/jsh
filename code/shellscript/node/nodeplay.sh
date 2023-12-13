#!/usr/bin/env bash
set -e

# Alternatively, just run node and then use: .load <module>
#
# https://stackoverflow.com/questions/8425102/how-do-i-load-my-script-into-the-node-js-repl

# Despite loading ts-node, this could still produce errors: Unexpected token 'export'
#node -r "ts-node" -r "$module"
# So later we just run ts-node directly

my_script="
global.loadModule = function (filename) {
    console.log('Loading module:', filename);
    var exports = require(filename);
    if (!exports) {
        console.warn('Failed to load:', filename);
        return
    }
    for (var key in exports) {
        var value = exports[key];
        global[key] = value;
        console.log('  Got:', key, value);
    }
}
"

newline="
"
for module in "$@"
do my_script="${my_script}${newline}loadModule('${module}');"
done

# Load the modules, and start the REPL
npx ts-node -e "${my_script}" -i


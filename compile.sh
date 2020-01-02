#!/bin/bash

OUT="p2.love"
IGNORE=(".git/\*" ".github/\*" ".gitignore" ".vscode/\*" "compile.sh" "README.md")

FLAGS="-r $OUT ."
for ignored in ${IGNORE[@]}; do
    FLAGS="$FLAGS -x $ignored"
done

zip $FLAGS

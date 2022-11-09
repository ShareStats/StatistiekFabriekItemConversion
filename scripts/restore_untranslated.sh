#!/bin/bash

# run from base folder

git checkout untranslated
cp MultipleChoice /tmp -ra
git checkout translate
rm MultipleChoice -rf
mv /tmp/MultipleChoice .
gitc -m "restore untranslated"


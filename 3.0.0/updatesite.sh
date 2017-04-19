#! /bin/bash
git pull
mkdocs build
rm -rf alpha/
mv site/ alpha/
echo -n "Enter task Performed >"
read text
echo "Entered Task: $text"

git add -A
git commit -m "updated site & - $text"
git push origin 3.0.0
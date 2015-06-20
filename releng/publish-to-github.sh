#! /bin/bash

set -o errexit

mvn clean package

git fetch origin gh-pages
github_head=$(git rev-parse origin/gh-pages)
github_url=$(git config remote.origin.url)

temp=$(mktemp -d)
trap 'rm -rf -- "$temp"' EXIT
cd $temp
git init . # git clone --shared --branch gh-pages --single-branch "$OLDPWD" .
echo $OLDPWD/.git/objects > .git/objects/info/alternates
git checkout --detach $github_head
rsync -v --exclude .git -a --delete "$OLDPWD"/p2.repository/target/repository/ .

for i in content artifacts; do
   # cmp fails to discover some differences...
   if diff -u \
      <(git show $github_head:$i.jar | zcat - | grep -F -v "<property name='p2.timestamp' value=") \
      <(zcat $i.jar | grep -F -v "<property name='p2.timestamp' value=")
   then
      git checkout $i.jar
   fi      
done

cat >p2.index <<EOF
version = 1
metadata.repository.factory.order = content.xml,\!
artifact.repository.factory.order = artifacts.xml,\!
EOF
git add --all
git commit --allow-empty-message -m '' || true
git push $github_url HEAD:gh-pages

cd $OLDPWD
git fetch origin gh-pages

echo done

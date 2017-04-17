#! /bin/bash

set -o errexit

# fetch newest version into original repository
git fetch origin gh-pages

github_head=$(git rev-parse origin/gh-pages)
github_url=$(git config remote.origin.url)

temp=$(mktemp -d)
trap 'rm -rf -- "$temp"' EXIT HUP

# checkout current state
(
  cd $temp
  git init .
  echo $OLDPWD/../.git/objects > .git/objects/info/alternates
  git -c advice.detachedHead=false checkout --detach $github_head
)

# build and deploy
mvn -Dtppt.deploymentTarget=file:/$(cygpath -m -a $temp) \
    clean package tppt:deploy tppt:create-deployment-index \
    clean

# commit changes
(
  cd $temp
  chmod -R a-x+rwX $temp
  git add --all
  git commit --allow-empty-message -m '' || true
  git push $github_url HEAD:gh-pages
)

# update original repository
git fetch origin gh-pages

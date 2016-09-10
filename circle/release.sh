
#!/bin/sh

set -e

git config --global user.email $GIT_USER_EMAIL
git config --global user.name $GIT_USER_NAME

CI_RELEASE_VERSION=`date +"v%Y/%m/%d:%H:%M:%S"`
touch build_dummy
git add -A
git checkout -b $1
git commit -m "[auto] release branch (${CI_RELEASE_VERSION})"
git push -f origin $1
#!/bin/bash
set -euxo pipefail

# cd .data
# if [[ ! -d taiko-web ]]
# then
# 	git clone https://github.com/bui/taiko-web
# fi
# cd taiko-web
# git checkout master
# git pull
# tools/get_version.sh
# cd ../..
# cp -r .data/taiko-web/public/src .
# 
# sed -i "s/$(jq -r ._version.commit api/config.json)/$(jq -r .commit .data/taiko-web/version.json)/g" index.html
# sed -i "s/$(jq -r ._version.commit_short api/config.json)/$(jq -r .commit_short .data/taiko-web/version.json)/g" index.html
# sed -i "s/$(jq -r ._version.version api/config.json)/$(jq -r .version .data/taiko-web/version.json)/g" index.html
# 
# jq -sc '.[0] * {"_version": .[1]}' api/config.json .data/taiko-web/version.json > config.json
# mv config.json api/config.json

cd plugins
git pull
cd ..

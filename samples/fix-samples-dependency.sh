#!/bin/sh

# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# @fileoverview Some of our repositories have both `package.json` and
# `samples/package.json`. This script, being fed to `apply-change.js`,
# will verify that versions in those two files match, and fix it if not.
# Requires `jq` tool to be installed (https://stedolan.github.io/jq/).

if ! test -f samples/package.json ; then
  echo "No samples, all good here."
  exit 0
fi

main_name=`jq -r .name package.json`
main_version=`jq -r .version package.json`
samples_dependency=`jq -r ".dependencies.\"$main_name\"" samples/package.json`
if [ "$main_version" == "$samples_dependency" ]; then
    echo "All good here."
    exit 0
fi

echo "Making changes! Current version of $main_name is $main_version, samples depend on version $samples_dependency."
jq -r ".dependencies.\"$main_name\"=\"$main_version\"" samples/package.json > samples/package.json.new
mv samples/package.json.new samples/package.json
npm install
npm link
cd samples
npm link ../
npm install
cd ..
npm run lint

echo "Git status:"
git status
echo "Done!"
exit 0

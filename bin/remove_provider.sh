#!/usr/bin/env sh
###########################################
# Because we're consuming templates that
# were designed to be root templates
# as modules, we end up in difficulty
# when trying to delete the content of a
# module. More info here:
# https://www.terraform.io/docs/configuration-0-11/modules.html#passing-providers-explicitly
#
# To get around this we will use this hack to
# disable the template provider after terraform init


# Get name of cluster (aws, ibmcloud or azure)
tmpl=$1

echo "Processing $tmpl"
# Get ref from modules.json
tmplroot=$(cat .terraform/modules/modules.json | jq -r '.Modules[] | select(.Source | test("'$tmpl'.")) | .Dir + "/" + .Root' )

if [[ -z ${tmplroot} ]]; then
  echo "Could not find template root for ${tmpl}"
else
  # Find filename that has provider declaration
  providerfile=$(grep -l -E "^provider" ${tmplroot}/*.tf)
fi

# If file is found patch to remove the provider declaration
if [[ ! -z ${providerfile} ]]; then
  echo "Found provider declaration in ${providerfile}"
  # If this is a single file declaration, the provider can be overwritten by root
  grep  -d skip -E "^provider.*}" ${providerfile} && {
    echo "${tmpl} has placeholder declaration. No need to modify"
  } || {
    sed -i.bak '/^provider /,/^}/s/^/#/' "${providerfile}"
  }
fi

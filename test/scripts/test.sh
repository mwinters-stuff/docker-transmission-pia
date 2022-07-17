#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${SCRIPTDIR}/yaml.sh"


curl -s -o sections.xml -k "https://192.168.10.17:32400/library/sections/?X-Plex-Token=ZxEsWCWy31yM71w9xhCJ"  || exit 1

result=$(xq "/MediaContainer/Directory[@allowSync=\"1\"]/@key" sections.xml)
for line in ${result}
do
  if [[ "$line" =~ \<result\>[0-9]\</\result\> ]]
  then
    sectionid=$(cut -d "<" -f 2 <<< "${line}" | cut -d ">" -f 2)
    curl -s -k "https://192.168.10.17:32400/library/sections/${sectionid}/refresh?X-Plex-Token=ZxEsWCWy31yM71w9xhCJ"
  fi
done
# echo "${result}"
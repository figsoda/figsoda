#!/usr/bin/env bash

set -e

curl -LSso .user.json "https://api.github.com/users/$1"
curl -LSso .repos.json "https://api.github.com/users/$1/repos"
curl -LSso .commits.json "https://api.github.com/search/commits?q=author:$1&per_page=1"\
    -H "Accept: application/vnd.github.cloak-preview"
curl -LSso .issues.json "https://api.github.com/search/issues?q=author:$1+is:issue&per_page=1"
curl -LSso .prs.json "https://api.github.com/search/issues?q=author:$1+is:pr&per_page=1"

name=$(jq -er .name .user.json)
repos=$(jq -e .public_repos .user.json)
gists=$(jq -e .public_gists .user.json)
stars=$(jq -e "map(.stargazers_count) | add" .repos.json)
forks=$(jq -e "map(.forks) | add" .repos.json)
commits=$(jq -e .total_count .commits.json)
issues=$(jq -e .total_count .issues.json)
prs=$(jq -e .total_count .prs.json)
followers=$(jq -e .followers .user.json)

jq -e ".[] | select(.fork == false) | .languages_url" .repos.json | xargs curl -LSs | jq -ecs . > .langs.json
langs=$(python3 langs.py)

date=$(date -u "+%F %T UTC")

cat > README.md << EOF
# $name


## Statistics

<table>
    <tr>
        <td>Repositories</td>
        <td><a href="https://github.com/$1?tab=repositories">$repos</a></td>
    </tr>
    <tr>
        <td>Gists</td>
        <td><a href="https://gist.github.com/$1">$gists</a></td>
    </tr>
    <tr>
        <td>Total stars</td>
        <td>$stars</td>
    </tr>
    <tr>
        <td>Total forks</td>
        <td>$forks</td>
    </tr>
    <tr>
        <td>Commits</td>
        <td>$commits</td>
    </tr>
    <tr>
        <td>Issues</td>
        <td>$issues</td>
    </tr>
    <tr>
        <td>Pull requests</td>
        <td>$prs</td>
    </tr>
    <tr>
        <td>Followers</td>
        <td><a href="https://github.com/$1?tab=followers">$followers</a></td>
    </tr>
</table>


## Most used languages

<table>
$langs
</table>


<sub>Last updated: $date</sub>
EOF

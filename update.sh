#!/bin/bash

set -e

get() {
    curl -LSso "$@"
}

fetch() {
    val="$(jq -e "${@:2}")"
    declare -g "$1=$val"
}

get .user.json "https://api.github.com/users/$1"
get .repos.json "https://api.github.com/users/$1/repos"
get .commits.json "https://api.github.com/search/commits?q=author:$1&per_page=1"\
    -H "Accept: application/vnd.github.cloak-preview"
get .issues.json "https://api.github.com/search/issues?q=author:$1+is:issue&per_page=1"
get .prs.json "https://api.github.com/search/issues?q=author:$1+is:pr&per_page=1"

fetch name -r .name .user.json
fetch repos .public_repos .user.json
fetch gists .public_gists .user.json
fetch stars "map(.stargazers_count) | add" .repos.json
fetch forks "map(.forks) | add" .repos.json
fetch commits .total_count .commits.json
fetch issues .total_count .issues.json
fetch prs .total_count .prs.json
fetch followers .followers .user.json

jq -ecr .[].languages_url .repos.json | xargs curl -LSs | jq -ecs > .langs.json
langs="$(python3 langs.py)"

date="$(date -u "+%F %T UTC")"

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

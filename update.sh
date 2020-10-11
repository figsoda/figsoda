#!/bin/bash

get() {
    curl -LSso "$@" || exit
}

fetch() {
    val="$(jq -e "${@:2}")" || exit
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

cat > README.md << EOF
# $name

|||
-|-
Repositories | [$repos](https://github.com/$1?tab=repositories)
Gists | [$gists](https://gist.github.com/$1)
Total stars | $stars
Total forks | $forks
Commits | $commits
Issues | $issues
Pull requests | $prs
Followers | [$followers](https://github.com/$1?tab=followers)

<sub>Last updated: $(date -u "+%F %T UTC")</sub>
EOF

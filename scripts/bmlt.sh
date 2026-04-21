#!/usr/bin/env bash
# bmlt.sh — thin curl wrapper for the BMLT Semantic API
#
# Usage:
#   bmlt.sh servers                                     # list all known root servers
#   bmlt.sh call <ROOT> <endpoint> [query]              # json call, pretty-printed
#   bmlt.sh call <ROOT> <endpoint> [query] --format csv # csv/tsml/jsonp
#
# Examples:
#   bmlt.sh servers
#   bmlt.sh call https://bmlt.sezf.org/main_server/ GetServiceBodies
#   bmlt.sh call https://bmlt.sezf.org/main_server/ GetSearchResults "services=5&recursive=1&venue_types=2"
#   bmlt.sh call https://bmlt.sezf.org/main_server/ GetNAWSDump "sb_id=5" --format csv

set -euo pipefail

SERVER_LIST_URL="https://raw.githubusercontent.com/bmlt-enabled/aggregator/refs/heads/main/serverList.json"

cmd=${1:-help}

case "$cmd" in
  servers)
    curl -sSL "$SERVER_LIST_URL" | jq -r '.[] | "\(.id)\t\(.name)\t\(.url)"' | column -t -s $'\t'
    ;;

  call)
    root=${2:?"root URL required (e.g. https://bmlt.sezf.org/main_server/)"}
    endpoint=${3:?"endpoint required (e.g. GetSearchResults)"}
    query=${4:-}
    format=json
    # parse --format flag if present anywhere after arg 3
    for arg in "${@:4}"; do
      case "$arg" in
        --format=*) format="${arg#--format=}" ;;
      esac
    done
    if [[ "$*" =~ --format[[:space:]]+([a-z]+) ]]; then
      format="${BASH_REMATCH[1]}"
    fi

    # trim trailing slash, then rebuild
    root="${root%/}"
    url="${root}/client_interface/${format}/?switcher=${endpoint}"
    [[ -n "$query" ]] && url="${url}&${query}"

    echo "→ GET $url" >&2
    if [[ "$format" == "json" ]]; then
      curl -sSL "$url" | jq .
    else
      curl -sSL "$url"
    fi
    ;;

  help|-h|--help|"")
    sed -n '1,15p' "$0" | sed 's/^# \{0,1\}//'
    ;;

  *)
    echo "Unknown command: $cmd" >&2
    echo "Run: $0 help" >&2
    exit 2
    ;;
esac

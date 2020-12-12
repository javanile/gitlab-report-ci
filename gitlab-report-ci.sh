#!/usr/bin/env bash

##
# gitlab-report-ci.sh
#
# Copyright (c) 2020 Francesco Bianco <bianco@javanile.org>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
##

set -e

VERSION=0.1.0
GITLAB_PROJECT_API_URL="https://gitlab.com/api/v4/projects"

usage () {
    echo "Usage: ./gitlab-report-ci.sh [OPTION]... [COMMAND] [ARGUMENT]..."
    echo ""
    echo "Support your CI workflow with useful macro."
    echo ""
    echo "List of available commands"
    echo "  create:branch NAME REF            Create new branch with NAME from REF"
    echo "  create:file NAME CONTENT BRANCH   Create new file with NAME and CONTENT into BRANCH"
    echo ""
    echo "List of available options"
    echo "  -h, --help               Display this help and exit"
    echo "  -v, --version            Display current version"
    echo ""
    echo "Documentation can be found at https://github.com/javanile/lcov.sh"
}

options=$(getopt -n gitlab-knock.sh -o vh -l version,help -- "$@")

eval set -- "${options}"

while true; do
    case "$1" in
        -v|--version) echo "GitLab Report CI [0.0.1] - by Francesco Bianco <bianco@javanile.org>"; exit ;;
        -h|--help) usage; exit ;;
        --) shift; break ;;
    esac
    shift
done

##
#
##
error() {
    echo "ERROR --> $1"
    exit 1
}

## curl -fsSL ...
upload_file() {
    curl --request POST \
         --form "branch=master" \
         --form "commit_message=New report" \
         --form "start_branch=master" \
         --form "actions[][action]=$1" \
         --form "actions[][file_path]=report/${CI_PROJECT_PATH:-ci}/${CI_COMMIT_BRANCH:-main}/$(basename "$2")" \
         --form "actions[][content]=<$2" \
         --header "PRIVATE-TOKEN: ${GITLAB_PRIVATE_TOKEN}" \
         -fsSL "${GITLAB_PROJECT_API_URL}/${GITLAB_REPORT_STORE//\//%2F}/repository/commits"
}

##
##
upload_report() {
    upload_file update "$1" || upload_file create "$1"
}

##
# Main function
##
main() {
    [[ -z "${GITLAB_REPORT_STORE}" ]] && error "Missing or empty GITLAB_REPORT_STORE variable."
    [[ -z "${GITLAB_PRIVATE_TOKEN}" ]] && error "Missing or empty GITLAB_PRIVATE_TOKEN variable."
    [[ -z "$1" ]] && error "Missing report file"

    upload_report "$1"

    echo ""
}

## Entrypoint
main "$@"

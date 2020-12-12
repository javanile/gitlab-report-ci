#!/usr/bin/env bash
set -o allexport

source .env

bash gitlab-report-ci.sh test/fixtures/report.txt

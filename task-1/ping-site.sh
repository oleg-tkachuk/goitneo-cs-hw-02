#!/usr/bin/env bash
set -o errexit

declare -a sites=("https://google.com" "https://facebook.com" "https://twitter.com" "https://localhost")
declare -r self_name=$(basename "$0" .sh)
declare -r log_file="${self_name}.log"
declare -r curl_timeout=5

function is_curl_installed(){
    local command=curl

    if ! command -v ${command} &> /dev/null; then
        echo "* ${command} is not installed. Please install curl"
        exit 1
    fi
}

function ping_sites(){
    local var="$1[@]"

    for site in "${!var}"; do
        curl  -IsL ${site} --connect-timeout ${curl_timeout} \
	| awk '$0~/^HTTP\/2/' \
        | grep -q -E '200|403' \
	&& echo "+ $(date) : ${site} is UP" \
        || echo "- $(date) : ${site} is DOWN" \
        | tee -a ${log_file}
    done | tee -a ${log_file}
}

function main(){
    is_curl_installed
    ping_sites sites

    echo "* The path to the log file: $(pwd)/${log_file}"
}

main

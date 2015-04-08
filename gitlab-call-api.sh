callGitlabAPI() {
	local method="$1"
	local resource="$2"
	local jsonData="$3"
	local filter="$4"
	if [[ -z "$filter" ]]; then
		filter="."
	fi
	curl \
		 -H "Content-Type: application/json" \
		 -H "PRIVATE-TOKEN: $TIDEXA_GITLAB_TOKEN" \
		 -d "$jsonData"\
		 -X $method \
		  $TIDEXA_GITLAB_API_URL/$resource | jq "$filter"
}
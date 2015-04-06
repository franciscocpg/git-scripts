callGitlabAPI() {
	local method="$1"
	local resource="$2"
	local jsonData="$3"
	curl \
		 -H "Content-Type: application/json" \
		 -H "PRIVATE-TOKEN: $TIDEXA_GITLAB_TOKEN" \
		 -d "$jsonData"\
		 -X $method \
		  $TIDEXA_GITLAB_API_URL/$resource
}
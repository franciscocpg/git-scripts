callGitlabAPI() {
	local resource="$1"
	local jsonData="$2"
	curl \
		 -H "Content-Type: application/json" \
		 -H "PRIVATE-TOKEN: $TIDEXA_GITLAB_TOKEN" \
		 -d "$jsonData"\
		 -X POST \
		  $TIDEXA_GITLAB_API_URL/$resource
}
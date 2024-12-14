#!/bin/sh

set -eu

echo 'Retrieving Flake information' >&2
flake_info=$(nix flake show --json 2>/dev/null)
packages=$(
	jq --raw-output '.packages."x86_64-linux" | keys[]' <<-EOF
		$flake_info
	EOF
)
echo "Packages:" >&2
echo "$packages" >&2
configurations=$(
	jq --raw-output '.nixosConfigurations | keys[]' <<-EOF
		$flake_info
	EOF
)
echo "NixOS Configurations:" >&2
echo "$configurations" >&2

package_size_table() {
	table='| Installable | NAR Size | Closure Size |
|-------------|---------:|-------------:|
'
	for package in $packages; do
		echo "Building $package" >&2
		path=$(nix build --print-out-paths ".#$package" 2>/dev/null)
		echo "Calculating size of $package" >&2
		row=$(nix path-info --size --closure-size --human-readable "$path" 2>/dev/null |
			sed "s/^\(\S\+\)\(\s\+\)\(\S\+\)\(\s\+\)\(\S\+\)$/| \`$package\` | \3 | \5 |/")
		table="$table$row
"
	done

	printf '%s' "$table"
}

configuration_size_table() {
	table='| NixOS Configuration | NAR Size | Closure Size |
|-------------|---------:|-------------:|
'
	for config in $configurations; do
		echo "Building $config" >&2
		path=$(nix build --print-out-paths ".#nixosConfigurations.$config.config.system.build.toplevel" 2>/dev/null)
		echo "Calculating size of $config" >&2
		row=$(nix path-info --size --closure-size --human-readable "$path" 2>/dev/null |
			sed "s/^\(\S\+\)\(\s\+\)\(\S\+\)\(\s\+\)\(\S\+\)$/| \`$config\` | \3 | \5 |/")
		table="$table$row
"
	done

	printf '%s' "$table"
}

markdown() {
	cat <<-EOF
		## Outputs' size

		### NixOS Configurations sizes

		$(configuration_size_table)


		### Package sizes

		$(package_size_table)
	EOF
}

if [ "${CI-false}" = "true" ]; then
	pr_number=$(curl -X 'GET' \
		"$GITHUB_API_URL/repos/$GITHUB_REPOSITORY/pulls?state=open&sort=recentupdate" \
		-H 'accept: application/json' |
		jq --arg head_ref "$GITHUB_REF_NAME" '.[] | select(.head.ref == $head_ref) | .number')

	if [ -z "$pr_number" ]; then
		echo "No PR created for this commit"
		exit 0
	fi

	echo "Retrieved index: $pr_number" >&2
	echo "Expected PR URL: $GITHUB_SERVER_URL/$GITHUB_REPOSITORY/pulls/$pr_number" >&2

	echo 'Generating comment body' >&2
	comment=$(markdown)

	echo 'Posting comment:' >&2
	echo "$comment" >&2

	echo 'Request data:' >&2
	data=$(echo '{}' | jq --arg comment "$comment" '.body=$comment')
	echo "$data" >&2
	curl -o - -X 'POST' \
		"$GITHUB_API_URL/repos/$GITHUB_REPOSITORY/issues/$pr_number/comments" \
		-H 'accept: application/json' \
		-H "Authorization: token $GITHUB_TOKEN" \
		-H 'Content-Type: application/json' \
		-d "$data"
else
	markdown
fi

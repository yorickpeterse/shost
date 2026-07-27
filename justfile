# Update the changelog
changelog version:
    clogs "{{ version }}"

# Create and push the release commit
commit version:
    git add .
    git commit -m "Release v{{ version }}"
    git push origin "$(git rev-parse --abbrev-ref HEAD)"

# Create the release tag
tag version:
    git tag -a -m "Release v{{ version }}" "v{{ version }}"
    git push origin "v{{ version }}"

# Update the version in the source
update-version version:
    sed -E -i -e "s/^let VERSION = '([^']+)'$/let VERSION = '{{ version }}'/" src/shost.inko

# Publish a new release
release version: (update-version version) (changelog version) (commit version) (tag version)

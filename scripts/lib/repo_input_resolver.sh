#!/usr/bin/env bash

sanitize_slug() {
  local value="${1:-}"
  local slug

  slug="$(printf '%s' "$value" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9._-' '-')"
  slug="${slug#-}"
  slug="${slug%-}"

  if [[ -z "$slug" ]]; then
    slug="repo-$(date +%Y%m%d%H%M%S)"
  fi

  printf '%s\n' "$slug"
}

is_doi_input() {
  local input="${1:-}"
  local lowered

  lowered="$(printf '%s' "$input" | tr '[:upper:]' '[:lower:]')"

  if [[ "$lowered" =~ ^doi:10\.[0-9]{4,9}/[^[:space:]]+$ ]]; then
    return 0
  fi

  if [[ "$lowered" =~ ^https?://doi\.org/10\.[0-9]{4,9}/[^[:space:]]+$ ]]; then
    return 0
  fi

  if [[ "$lowered" =~ ^10\.[0-9]{4,9}/[^[:space:]]+$ ]]; then
    return 0
  fi

  return 1
}

is_remote_repo_input() {
  local input="${1:-}"
  local lowered

  lowered="$(printf '%s' "$input" | tr '[:upper:]' '[:lower:]')"
  if [[ "$lowered" =~ ^https?://doi\.org/ ]]; then
    return 1
  fi

  if [[ "$input" =~ ^(git@|ssh://) ]]; then
    return 0
  fi

  if [[ "$input" =~ ^git:// ]]; then
    return 0
  fi

  if [[ "$input" =~ ^https?:// ]]; then
    return 0
  fi

  return 1
}

repo_slug_from_input() {
  local input="${1:-}"
  local slug=""

  if [[ "$input" =~ ^git@[^:]+:(.+)$ ]]; then
    slug="${BASH_REMATCH[1]}"
    slug="${slug##*/}"
  else
    local stripped="$input"
    stripped="${stripped%%\?*}"
    stripped="${stripped%%#*}"
    stripped="${stripped%/}"
    slug="${stripped##*/}"
  fi

  slug="${slug%.git}"
  sanitize_slug "$slug"
}

# Sets these globals:
# - REPO_INPUT_ORIGINAL
# - REPO_INPUT_KIND (local|repo_url|doi|unsupported)
# - REPO_INPUT_RESOLVED
# - REPO_INPUT_CLONED ("1" or "0")
# - REPO_INPUT_DEFAULT_METADATA_PATH
# - REPO_INPUT_HINT
resolve_repo_input() {
  local repo_root="${1:?repo root required}"
  local repo_input="${2:?repo input required}"

  REPO_INPUT_ORIGINAL="$repo_input"
  REPO_INPUT_KIND="unsupported"
  REPO_INPUT_RESOLVED=""
  REPO_INPUT_CLONED="0"
  REPO_INPUT_DEFAULT_METADATA_PATH=""
  REPO_INPUT_HINT=""

  if [[ -d "$repo_input" ]]; then
    REPO_INPUT_KIND="local"
    REPO_INPUT_RESOLVED="$(cd "$repo_input" && pwd)"
    REPO_INPUT_DEFAULT_METADATA_PATH="${REPO_INPUT_RESOLVED}/hssi_metadata.md"
    return 0
  fi

  if is_remote_repo_input "$repo_input"; then
    if ! command -v git >/dev/null 2>&1; then
      echo "Error: git is required to clone repository URLs into repos/." >&2
      return 2
    fi

    local repos_dir="${repo_root}/repos"
    local slug
    local target_dir

    mkdir -p "$repos_dir"
    slug="$(repo_slug_from_input "$repo_input")"
    target_dir="${repos_dir}/${slug}"

    if [[ -d "${target_dir}/.git" ]]; then
      echo "Refreshing existing clone in ${target_dir}" >&2
      if ! git -C "$target_dir" pull --ff-only; then
        echo "Warning: failed to refresh clone at ${target_dir}; using existing checkout." >&2
      fi
    elif [[ -e "$target_dir" ]]; then
      echo "Error: target clone directory exists and is not a git repo: ${target_dir}" >&2
      return 2
    else
      echo "Cloning repository URL into ${target_dir}" >&2
      if ! git clone "$repo_input" "$target_dir"; then
        echo "Error: failed to clone repository URL: ${repo_input}" >&2
        echo "Hint: this pipeline treats URL-like inputs as repository candidates and attempts git clone." >&2
        echo "Hint: verify the URL points to a clonable git repository, or provide a local path/DOI." >&2
        return 2
      fi
    fi

    REPO_INPUT_KIND="repo_url"
    REPO_INPUT_RESOLVED="$target_dir"
    REPO_INPUT_CLONED="1"
    REPO_INPUT_DEFAULT_METADATA_PATH="${target_dir}/hssi_metadata.md"
    return 0
  fi

  if is_doi_input "$repo_input"; then
    REPO_INPUT_KIND="doi"
    REPO_INPUT_RESOLVED="$repo_input"
    REPO_INPUT_DEFAULT_METADATA_PATH=""
    return 0
  fi

  if [[ -e "$repo_input" && ! -d "$repo_input" ]]; then
    REPO_INPUT_HINT="Input path exists but is not a directory: ${repo_input}"
  elif [[ "$repo_input" == *"/"* || "$repo_input" == "." || "$repo_input" == ".." || "$repo_input" == "~"* ]]; then
    REPO_INPUT_HINT="Local repository path not found: ${repo_input}"
  elif [[ "$repo_input" =~ ^[A-Za-z][A-Za-z0-9+.-]*:// ]]; then
    REPO_INPUT_HINT="Input URL is not supported for repository staging: ${repo_input}. Provide a clonable git URL, local path, or DOI."
  else
    REPO_INPUT_HINT="Input must be a local repo path, clonable repository URL, or DOI: ${repo_input}"
  fi

  echo "Error: ${REPO_INPUT_HINT}" >&2
  return 2
}

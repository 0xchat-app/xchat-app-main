#!/usr/bin/env bash
# =============================================================================
# ox_pub_get.sh
# Utility script to checkout specific branches for the 0xChat Lite repo and its
# sub-projects, then run `flutter pub get` for each package.
#
# Supported repositories & default branches:
#   1. Main project           → main  (flag: -m <branch>)
#   2. 0xchat-core            → upgrade/isar4 (fixed)
#   3. nostr-dart             → main  (flag: -n <branch>)
#   4. nostr-mls-package      → main  (flag: -l <branch>)
# =============================================================================

set -euo pipefail

main_path="$(pwd)"
core_path="${main_path}/packages/0xchat-core"
nostr_dart_path="${main_path}/packages/nostr-dart"
nostr_mls_path="${main_path}/packages/nostr-mls-package"

# Default branches
main_branch="main"
core_branch="upgrade/isar4"       # Fixed
nostr_branch="main"
mls_branch="main"

usage() {
  cat <<EOF
Usage: ./ox_pub_get.sh [options]
Options:
  -m <branch>   Branch name for main project          (default: main)
  -n <branch>   Branch name for packages/nostr-dart   (default: main)
  -l <branch>   Branch name for packages/nostr-mls-package (default: main)
  -h            Show this help message
EOF
  exit 1
}

# ------------------------- Parse CLI arguments ------------------------------
while getopts ':m:n:l:h' opt; do
  case "$opt" in
    m) main_branch="$OPTARG" ;;
    n) nostr_branch="$OPTARG" ;;
    l) mls_branch="$OPTARG" ;;
    h) usage ;;
    :) echo "Option -$OPTARG requires an argument."; exit 1 ;;
    \?) echo "Invalid option: -$OPTARG"; usage ;;
  esac
done

# ------------------------- Helper functions ---------------------------------
checkout_branch() {
  local dir=$1
  local branch=$2
  echo "\n--- Checkout $(basename "$dir") => $branch ---"
  if [[ ! -d "$dir/.git" ]]; then
    echo "Directory $dir is not a git repo, skipping."
    return
  fi
  git -C "$dir" fetch --all --tags
  git -C "$dir" checkout "$branch"
  git -C "$dir" pull --ff-only || true
}

run_pub_get() {
  local dir=$1
  echo "Running flutter pub get in $dir"
  (cd "$dir" && flutter pub get)
}

# ------------------------- Checkout branches --------------------------------
checkout_branch "$main_path" "$main_branch"
checkout_branch "$core_path" "$core_branch"
checkout_branch "$nostr_dart_path" "$nostr_branch"
checkout_branch "$nostr_mls_path" "$mls_branch"

# ------------------------- Run flutter pub get ------------------------------
run_pub_get "$main_path"
run_pub_get "$core_path"
run_pub_get "$nostr_dart_path"
run_pub_get "$nostr_mls_path"

echo "\n✔ All done."
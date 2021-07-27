#!/usr/bin/env bash
# ^^^^^^^^^^^^^^^^^ this is the most platform-agnostic way to guarantee this script runs with Bash
# 2021-07-08 WATERMARK, DO NOT REMOVE - This script was generated from the Kurtosis Bash script template

set -euo pipefail   # Bash "strict mode"
script_dirpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root_dirpath="$(dirname "${script_dirpath}")"


# ==================================================================================================
#                                             Constants
# ==================================================================================================
# A sed regex that will be used to determine if the user-supplied image name matches the regex
ALLOWED_IMAGE_NAME_CHARS='a-z0-9._/-'

KURTOSIS_LAMBDA_FOLDER="kurtosis-lambda"


# =============================================================================
#                             Pre-Arg Parsing
# =============================================================================
show_help_and_exit() {
  echo ""
  echo "Usage: $(basename "${0}") kurtosis_lambda_image_name"
  echo ""
  # NOTE: We *could* extract the arg names to variables since they're repeated, but then we wouldn't be able to visually align the indentation here
  echo "  kurtosis_lambda_image_name  Every Kurtosis Lambda runs inside a Docker image, so building your Kurtosis Lambda means producing a Docker image containing"
  echo "                              your Kurtosis Lambda code. This is the name of the Docker image that building your Kurtosis Lambda repo will produce."
  echo "                              This image should not exist yet, as building the Kurtosis Lambda will create it. "
  echo "                              The image name must match the regex [${ALLOWED_IMAGE_NAME_CHARS}]+ (e.g. 'my-kurtosis-lambda-image')."
  echo ""
  exit 1 # Exit with an error so CI fails if this was accidentally called
}

# =============================================================================
#                           Arg Parsing & Validation
# =============================================================================
lambda_image="${1:-}"

if [ -z "${lambda_image}" ]; then
  echo "Error: Kurtosis Lambda image cannot be empty" >&2
  show_help_and_exit
fi
sanitized_image="$(echo "${lambda_image}" | sed "s|[^${ALLOWED_IMAGE_NAME_CHARS}]||g")"
if [ "${sanitized_image}" != "${lambda_image}" ]; then
  echo "Error: Kurtosis Lambda image name '${lambda_image}' doesn't match regex [${ALLOWED_IMAGE_NAME_CHARS}]+" >&2
  show_help_and_exit
fi

# =============================================================================
#                                 Main Code
# =============================================================================
# Build Dockerfile
# Captures the first of tag > branch > commit
git_ref="$(cd "${root_dirpath}" && git describe --tags --exact-match 2>/dev/null || git symbolic-ref -q --short HEAD || git rev-parse --short HEAD)"
if [ "${git_ref}" == "" ]; then
  echo "Error: Could not determine a Git ref to use for the Docker tag; is the repo a Git directory?" >&2
  exit 1
fi


if ! [ -f "${root_dirpath}"/.dockerignore ]; then
  echo "Error: No .dockerignore file found in root of repo '${root_dirpath}'; this is required so Docker caching is enabled and your Kurtosis Lambda builds remain quick" >&2
  exit 1
fi

dockerfile_filepath="${root_dirpath}/${KURTOSIS_LAMBDA_FOLDER}/Dockerfile"
echo "Building Kurtosis Lambda into a Docker image named '${lambda_image}'..."
# The BUILD_TIMESTAMP variable is provided because Docker sometimes caches steps it shouldn't and we need a constantly-changing ARG so that we can intentionally bust the cache
# See: https://stackoverflow.com/questions/31782220/how-can-i-prevent-a-dockerfile-instruction-from-being-cached
if ! docker build --build-arg BUILD_TIMESTAMP="$(date +"%FT%H:%M:%S")" -t "${lambda_image}" -f "${dockerfile_filepath}" "${root_dirpath}"; then
  echo "Error: Docker build of the Kurtosis Lambda failed" >&2
  exit 1
fi
echo "Successfully built Docker image '${lambda_image}' containing the Kurtosis Lambda"
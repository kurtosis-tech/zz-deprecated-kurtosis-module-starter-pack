#!/usr/bin/env bash
# ^^^^^^^^^^^^^^^^^ this is the most platform-agnostic way to guarantee this script runs with Bash
# 2021-07-08 WATERMARK, DO NOT REMOVE - This script was generated from the Kurtosis Bash script template

set -euo pipefail   # Bash "strict mode"
script_dirpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root_dirpath="$(dirname "${script_dirpath}")"


# ==================================================================================================
#                                             Constants
# ==================================================================================================
KURTOSIS_DOCKERHUB_ORG="kurtosistech"
IMAGE_NAME="kurtosis-lambda-starter-pack"
KURTOSIS_LAMBDA_FOLDER="kurtosis-lambda"


# =============================================================================
#                           Arg Parsing & Validation
# =============================================================================
lambda_image="${1:-}"

# Sets a default value that will be used for Kurtosis in local development and integration tests
if [ "${lambda_image}" == "" ]; then
  lambda_image="${KURTOSIS_DOCKERHUB_ORG}/${IMAGE_NAME}"
fi

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
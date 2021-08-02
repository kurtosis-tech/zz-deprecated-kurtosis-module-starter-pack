#!/usr/bin/env bash
# ^^^^^^^^^^^^^^^^^ this is the most platform-agnostic way to guarantee this script runs with Bash
# 2021-07-08 WATERMARK, DO NOT REMOVE - This script was generated from the Kurtosis Bash script template

set -euo pipefail # Bash "strict mode"
script_dirpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root_dirpath="$(dirname "${script_dirpath}")"

# ==================================================================================================
#                                             Constants
# ==================================================================================================
IMAGE_NAME="kurtosistech/kurtosis-lambda-starter-pack"
KURTOSIS_LAMBDA_FOLDER="kurtosis-lambda"

# =============================================================================
#                                 Main Code
# =============================================================================
# Checks if dockerignore file is in the root path
if ! [ -f "${root_dirpath}"/.dockerignore ]; then
  echo "Error: No .dockerignore file found in root of repo '${root_dirpath}'; this is required so Docker caching is enabled and your Kurtosis Lambda builds remain quick" >&2
  exit 1
fi

# Builds Dockerfile
dockerfile_filepath="${root_dirpath}/${KURTOSIS_LAMBDA_FOLDER}/Dockerfile"
echo "Building Kurtosis Lambda into a Docker image named '${IMAGE_NAME}'..."
# The BUILD_TIMESTAMP variable is provided because Docker sometimes caches steps it shouldn't and we need a constantly-changing ARG so that we can intentionally bust the cache
# See: https://stackoverflow.com/questions/31782220/how-can-i-prevent-a-dockerfile-instruction-from-being-cached
if ! docker build --build-arg BUILD_TIMESTAMP="$(date +"%FT%H:%M:%S")" -t "${IMAGE_NAME}" -f "${dockerfile_filepath}" "${root_dirpath}"; then
  echo "Error: Docker build of the Kurtosis Lambda failed" >&2
  exit 1
fi
echo "Successfully built Docker image '${IMAGE_NAME}' containing the Kurtosis Lambda"

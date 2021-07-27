#!/usr/bin/env bash
# ^^^^^^^^^^^^^^^^^ this is the most platform-agnostic way to guarantee this script runs with Bash
# 2021-07-08 WATERMARK, DO NOT REMOVE - This script was generated from the Kurtosis Bash script template

set -euo pipefail # Bash "strict mode"
script_dirpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root_dirpath="$(dirname "${script_dirpath}")"

# ==================================================================================================
#                                             Constants
# ==================================================================================================
# A sed regex that will be used to determine if the user-supplied image name matches the regex
ALLOWED_IMAGE_NAME_CHARS='a-z0-9._/-'

SUPPORTED_LANGS_FILENAME="supported-languages.txt"

# Build script
BUILD_FILENAME="build.sh"

# Script for prepping a new Kurtosis Lambda repo
PREP_NEW_REPO_FILENAME="prep-new-repo.sh"

# Output repo constants
OUTPUT_README_FILENAME="README.md"
KURTOSIS_LAMBDA_FOLDER="kurtosis-lambda"

SCRIPTS_DIRNAME="scripts"

# =============================================================================
#                             Pre-Arg Parsing
# =============================================================================
supported_langs_filepath="${repo_root_dirpath}/${SUPPORTED_LANGS_FILENAME}"
if ! [ -f "${supported_langs_filepath}" ]; then
  echo "Error: Couldn't find supported languages file '${supported_langs_filepath}'; this is a bug in this script" >&2
  exit 1
fi

# Validate that the supported langs correspond to directories
while read supported_lang; do
  supported_lang_dirpath="${repo_root_dirpath}/${supported_lang}"
  if ! [ -d "${supported_lang_dirpath}" ]; then
    echo "Error: Supported languages file lists language '${supported_lang}', but no lang directory '${supported_lang_dirpath}' found corresponding to it; this is a bug in the supported languages file" >&2
    exit 1
  fi
  supported_lang_bootstrap_dirpath="${script_dirpath}/${supported_lang}"
  if ! [ -d "${supported_lang_bootstrap_dirpath}" ]; then
    echo "Error: Supported languages file lists language '${supported_lang}', but no lang bootstrap directory '${supported_lang_bootstrap_dirpath}' found corresponding to it; this is a bug in the supported languages file" >&2
    exit 1
  fi
done <"${supported_langs_filepath}"

show_help_and_exit() {
  echo ""
  echo "Usage: $(basename "${0}") lang new_repo_dirpath kurtosis_lambda_image_name"
  echo ""
  # NOTE: We *could* extract the arg names to variables since they're repeated, but then we wouldn't be able to visually align the indentation here
  echo "  lang                        Language that you want to write your Kurtosis Lambda in (choices: $(paste -sd '|' "${supported_langs_filepath}"))."
  echo "  new_repo_dirpath            Your new Kurtosis Lambda will be a repo of its own that you'll commit to your version control. This path is  where the bootstrap script"
  echo "                              will create the directory to contain the new Kurtosis Lambda's repo, and you should put it wherever you keep your code repos (e.g. "
  echo "                              /path/to/your/code/repos/my-new-kurtosis-lambda). This path shouldn't exist yet, as the bootstrap will fill it."
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
lang="${1:-}"
output_dirpath="${2:-}"
lambda_image="${3:-}"

if [ -z "${lang}" ]; then
  echo "Error: Lang cannot be empty" >&2
  show_help_and_exit
fi
if ! grep -q "^${lang}$" "${supported_langs_filepath}"; then
  echo "Error: Unrecognized lang '${lang}'" >&2
  show_help_and_exit
fi
if [ -z "${output_dirpath}" ]; then
  echo "Error: Output dirpath must not be empty" >&2
  show_help_and_exit
fi
if [ -d "${output_dirpath}" ] && [ "$(ls -A "${output_dirpath}")" ]; then
  echo "Error: Output directory '${output_dirpath}' exists, but is not empty"
  show_help_and_exit
fi
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
# Use language-specific prep script to populate contents of output directory
if ! mkdir -p "${output_dirpath}"; then
  echo "Error: Could not create output directory '${output_dirpath}'" >&2
  exit 1
fi
lang_dirpath="${repo_root_dirpath}/${lang}"
lang_bootstrap_dirpath="${script_dirpath}/${lang}"
prep_new_repo_script_filepath="${lang_bootstrap_dirpath}/${PREP_NEW_REPO_FILENAME}"
if ! bash "${prep_new_repo_script_filepath}" "${lang_dirpath}" "${output_dirpath}" "${lambda_image}"; then
  echo "Error: Failed to prep new repo using script '${prep_new_repo_script_filepath}'" >&2
  exit 1
fi

# README file
output_readme_filepath="${output_dirpath}/${OUTPUT_README_FILENAME}"
cat <<EOF >"${output_readme_filepath}"
My Kurtosis Lambda
=====================
Welcome to your new Kurtosis Lambda! You can use Example Kurtosis Lambda implementation as a pattern to create your own Kurtosis Lambda.

1. Customize your own Kurtosis Lambda by editing the generated files inside the `/path/to/your/code/repos/kurtosis-lambda/impl` folder
  1. Follow the bootstrap instructions

EOF
if [ "${?}" -ne 0 ]; then
  echo "Error: Could not write README file to '${output_readme_filepath}'" >&2
  exit 1
fi

#Initialize the new repo as a Git directory, because running the Kurtosis Lambda depends on it
if ! command -v git &> /dev/null; then
    echo "Error: Git is required to create a new Kurtosis Lambda repo, but it is not installed" >&2
    exit 1
fi
if ! cd "${output_dirpath}"; then
    echo "Error: Could not cd to new Kurtosis Lambda repo '${output_dirpath}', which is necessary for initializing it as a Git repo" >&2
    exit 1
fi
if ! git init; then
    echo "Error: Could not initialize the new repo as a Git repository" >&2
    exit 1
fi
if ! git add .; then
    echo "Error: Could not stage files in new repo for committing" >&2
    exit 1
fi
if ! git commit -m "Initial commit" > /dev/null; then
    echo "Error: Could not create initial commit in new repo" >&2
    exit 1
fi

#Runs build script
scripts_dirpath="${output_dirpath}/${SCRIPTS_DIRNAME}"
bash "${scripts_dirpath}/${BUILD_FILENAME}"

echo "Bootstrap successful!"
echo "For next steps, follow the instructions in the README at /path/to/new/README"

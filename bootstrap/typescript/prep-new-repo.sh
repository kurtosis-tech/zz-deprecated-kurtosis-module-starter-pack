#!/usr/bin/env bash
# 2021-07-08 WATERMARK, DO NOT REMOVE - This script was generated from the Kurtosis Bash script template

set -euo pipefail   # Bash "strict mode"
script_dirpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"



# ==================================================================================================
#                                             Constants
# ==================================================================================================
LAMBDA_IMPL_DIRNAME="kurtosis-lambda"
SCRIPTS_DIRNAME="scripts"

# ==================================================================================================
#                                       Arg Parsing & Validation
# ==================================================================================================
show_helptext_and_exit() {
    echo "Usage: $(basename "${0}") input_dirpath output_dirpath"
    echo ""
    echo "  input_dirpath   The source directory to copy files from"
    echo "  output_dirpath  A nonexistent or empty directory to create the bootstrap output in"
    echo ""
    exit 1  # Exit with an error so that if this is accidentally called by CI, the script will fail
}

input_dirpath="${1:-}"
output_dirpath="${2:-}"

if [ -z "${input_dirpath}" ]; then
    echo "Error: No input dirpath provided" >&2
    show_helptext_and_exit
fi
if ! [ -d "${input_dirpath}" ]; then
    echo "Error: Input dirpath '${some_filepath_arg}' isn't a valid directory" >&2
    show_helptext_and_exit
fi
if [ -z "${output_dirpath}" ]; then
    echo "Error: Output dirpath is empty" >&2
    show_helptext_and_exit
fi



# ==================================================================================================
#                                             Main Logic
# ==================================================================================================
cp "${input_dirpath}/package.json" "${output_dirpath}/"
cp "${input_dirpath}/tsconfig.json" "${output_dirpath}/"
cp "${input_dirpath}/yarn.lock" "${output_dirpath}/"
cp -r "${input_dirpath}/${LAMBDA_IMPL_DIRNAME}" "${output_dirpath}/"
cp -r "${input_dirpath}/${SCRIPTS_DIRNAME}" "${output_dirpath}/"

set -euo pipefail
script_dirpath="$(cd "$(dirname "${0}")" && pwd)"
root_dirpath="$(dirname "${script_dirpath}")"

# ==========================================================================================
#                                         Constants
# ==========================================================================================
BOOTSTRAP_SCRIPTS_DIRNAME="bootstrap"
BOOTSTRAP_SCRIPT_FILENAME="bootstrap.sh"
SUPPORTED_LANGS_FILENAME="supported-languages.txt"
SCRIPTS_DIRNAME_INSIDE_KURTOSIS_LAMBDA="scripts"
BUILD_SCRIPT_FILENAME="build.sh"

GIT_USER_EMAIL_PROPERTY="user.email"
GIT_USER_NAME_PROPERTY="user.name"

MISSING_BOOTSTRAP_FLAGS_KEY="MISSING"

# Bootstrapping normally requires input from STDIN, but we can set
#  certain variables so this isn't required for CI
# NOTE: This won't handle flag values that contain spaces, though it can handle multiple flags separated by a space
declare -A CUSTOM_LANG_BOOTSTRAP_FLAGS 
CUSTOM_LANG_BOOTSTRAP_FLAGS[golang]="GO_NEW_MODULE_NAME=github.com/test/test-module"
CUSTOM_LANG_BOOTSTRAP_FLAGS[typescript]=""  # No extra Typescript bootstrapping flags needed



# ==========================================================================================
#                                        Arg-parsing
# ==========================================================================================
docker_username="${1:-}"
docker_password_DO_NOT_LOG="${2:-}" # WARNING: DO NOT EVER LOG THIS!!

# ==========================================================================================
#                                        Arg validation
# ==========================================================================================
if [ -z "${docker_username}" ]; then
    echo "Error: Docker username cannot be empty" >&2
    exit 1
fi
if [ -z "${docker_password_DO_NOT_LOG}" ]; then
    echo "Error: Docker password cannot be empty" >&2
    exit 1
fi


# ==========================================================================================
#                                           Main code
# ==========================================================================================
# Docker is restricting anonymous image pulls, so we log in before we do any pulling
if ! docker login -u "${docker_username}" -p "${docker_password_DO_NOT_LOG}"; then
    echo "Error: Logging in to Docker failed" >&2
    exit 1
fi

# Git needs to be initialized, since the bootstrap will create a new Git repo and commit to it
if ! { git config --list | grep "${GIT_USER_EMAIL_PROPERTY}"; } || ! { git config --list | grep "${GIT_USER_NAME_PROPERTY}"; }; then
    if ! git config --global "${GIT_USER_EMAIL_PROPERTY}" "bootstrap-tester@.com"; then
        echo "Error: An error occurred configuring the Git user email property '${GIT_USER_EMAIL_PROPERTY}'" >&2
        exit 1
    fi
    if ! git config --global "${GIT_USER_NAME_PROPERTY}" "Bootstrap Tester"; then
        echo "Error: An error occurred configuring the Git user name property '${GIT_USER_NAME_PROPERTY}'" >&2
        exit 1
    fi
fi

bootstrap_script_filepath="${root_dirpath}/${BOOTSTRAP_SCRIPTS_DIRNAME}/${BOOTSTRAP_SCRIPT_FILENAME}"
echo "Bootstrapping and running new Kurtosis Lambda for all languages..."
for lang in $(cat "${root_dirpath}/${SUPPORTED_LANGS_FILENAME}"); do
    echo "Bootstrapping and running ${lang} Kurtosis Lambda..."
    output_dirpath="$(mktemp -d)"
    kurtosis_lambda_image="bootstrap-kurtosis-lambda-${lang}-image"
    lang_specific_vars_to_set="${CUSTOM_LANG_BOOTSTRAP_FLAGS[${lang}]:-"${MISSING_BOOTSTRAP_FLAGS_KEY}"}"
    if [ "${lang_specific_vars_to_set}" == "${MISSING_BOOTSTRAP_FLAGS_KEY}" ]; then
        echo "Error: No custom bootstrap flas were defined for ${lang}; this bootstrap validation script needs to be updated with them" >&2
        exit 1
    fi
    command="${lang_specific_vars_to_set} ${bootstrap_script_filepath} ${lang} ${output_dirpath} ${kurtosis_lambda_image}"
    if ! eval "${command}"; then
        echo "Error: Bootstrapping ${lang} Kurtosis Lambda failed" >&2
        exit 1
    fi

    build_filepath="${output_dirpath}/${SCRIPTS_DIRNAME_INSIDE_KURTOSIS_LAMBDA}/${BUILD_SCRIPT_FILENAME}"
    if ! "${build_filepath}"; then
        echo "Error: The build of the bootstrapped ${lang} Kurtosis Lambda failed" >&2
        exit 1
    fi
    echo "Successfully bootstrapped and built new ${lang} Kurtosis Lambda"
done
echo "Successfully bootstrapped and ran new Kurtosis Lambdas for all languages!"

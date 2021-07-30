set -euo pipefail
script_dirpath="$(cd "$(dirname "${0}")" && pwd)"
root_dirpath="$(dirname "${script_dirpath}")"

# ==========================================================================================
#                                         Constants
# ==========================================================================================
KURTOSIS_DOCKERHUB_ORG="kurtosistech"
LANG_SCRIPTS_DIRNAME="scripts"
BUILD_FILENAME="build"

# ==========================================================================================
#                                        Arg-parsing
# ==========================================================================================
docker_username="${1:-}"
docker_password_DO_NOT_LOG="${2:-}" # WARNING: DO NOT EVER LOG THIS!!
circleci_git_tag="${3:-}"   # This should be mutually exclusive with the CircleCI Git branch

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
if [ -z "${circleci_git_tag}" ]; then
    echo "Error: CircleCI Git tag cannot be empty" >&2
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

echo "Pushing example Kurtosis Lambda Docker images to Dockerhub..."
supported_langs_filepath="${root_dirpath}/supported-languages.txt"
for lang in $(cat "${supported_langs_filepath}"); do
    echo "Building ${lang} Docker image..."
    buildscript_filepath="${root_dirpath}/${lang}/${LANG_SCRIPTS_DIRNAME}/${BUILD_FILENAME}"
    if ! bash "${buildscript_filepath}" build; then
        echo "Error: Building example ${lang} image failed" >&2
        exit 1
    fi
    echo "Successfully built ${lang} Docker image"

    image_name="${KURTOSIS_DOCKERHUB_ORG}/kurtosis-${lang}-example:${circleci_git_tag}"

    echo "Pushing ${image_name} to Dockerhub..."
    if ! docker push ${image_name}; then
        echo "Error: Could not push Docker image '${image_name}' to Dockerhub" >&2
        exit 1
    fi
    echo "Successfully pushed ${image_name} to Dockerhub"
done
echo "Successfully pushed Kurtosis Lambda Docker image to Dockerhub"

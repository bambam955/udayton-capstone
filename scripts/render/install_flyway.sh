#!/usr/bin/env bash
set -euo pipefail

# Pin Flyway so Render deploys stay deterministic even if Redgate publishes a
# newer CLI between beta and prod rollouts.
flyway_version="${FLYWAY_VERSION:-12.4.0}"
tools_dir="${PWD}/.render-tools"
install_dir="${tools_dir}/flyway-${flyway_version}"
archive_path="${tools_dir}/flyway-commandline-${flyway_version}-linux-x64.tar.gz"
download_url="https://download.red-gate.com/maven/release/com/redgate/flyway/flyway-commandline/${flyway_version}/flyway-commandline-${flyway_version}-linux-x64.tar.gz"

if [ -x "${install_dir}/flyway" ]; then
    echo "Flyway ${flyway_version} already installed at ${install_dir}"
    exit 0
fi

mkdir -p "${tools_dir}"

echo "Downloading Flyway ${flyway_version}..."
curl --fail --location --silent --show-error "${download_url}" --output "${archive_path}"

echo "Extracting Flyway ${flyway_version}..."
tar -xzf "${archive_path}" -C "${tools_dir}"
rm -f "${archive_path}"

echo "Flyway installed at ${install_dir}"

#!/bin/bash
# This script is meant to be run as the Startup Script of each Compute Instance while it's booting. The script uses the
# run-consul and run-vault scripts to configure and start both Vault and Consul in client mode. This script assumes it's
# running in a Compute Instance based on a Google Image built from the Packer template in
# examples/vault-consul-image/vault-consul.json.
ls

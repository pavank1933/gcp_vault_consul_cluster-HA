#!/bin/bash
# This script is meant to be run as the Startup Script of each Compute Instance while it's booting. The script uses the
# run-consul and run-vault scripts to configure and start both Vault and Consul in client mode. This script assumes it's
# running in a Compute Instance based on a Google Image built from the Packer template in
# examples/vault-consul-image/vault-consul.json.

set -e

# Send the log output from this script to startup-script.log, syslog, and the console
# Inspired by https://alestic.com/2010/12/ec2-user-data-output/
exec > >(tee /var/log/startup-script.log|logger -t startup-script -s 2>/dev/console) 2>&1

# The Packer template puts the TLS certs in these file paths
readonly VAULT_TLS_CERT_FILE="/opt/vault/tls/vault.crt.pem"
readonly VAULT_TLS_KEY_FILE="/opt/vault/tls/vault.key.pem"

# Note that any variables below with <dollar-sign><curly-brace><var-name><curly-brace> are expected to be interpolated by Terraform.


cp -rpf /opt/consul/bin/run-consul /opt/consul/bin/run-consul-orig
sed -i 's/get_instance_zone/get_instance_region/g' /opt/consul/bin/run-consul
sed -i 's/instance_zone/instance_region/g' /opt/consul/bin/run-consul
sed '/zone"/s/$/ | awk -F'\''-'\'' '\''{ print $1"-"$2 }'\''/' /opt/consul/bin/run-consul > /opt/consul/bin/replace_out
#sed '/zone\"/s/$/ | awk -F'\\''-'\\'' '\\''{ print $1\"-\"$2 }'\\''/' /opt/consul/bin/run-consul > /opt/consul/bin/replace_out
rm -rf /opt/consul/bin/run-consul
mv /opt/consul/bin/replace_out /opt/consul/bin/run-consul
chmod a+x /opt/consul/bin/run-consul


/opt/consul/bin/run-consul --client --cluster-tag-name "${consul_cluster_tag_name}"
/opt/vault/bin/run-vault --gcs-bucket ${vault_cluster_tag_name} --tls-cert-file "$VAULT_TLS_CERT_FILE" --tls-key-file "$VAULT_TLS_KEY_FILE"

# pingfederate-terraform-export

The scripts in this repository are meant as a helper to extract configuration from a running PingFederate instance, populate a Terraform HCL file with the appropriate `import {}` blocks, which in turn can generate full Terraform HCL.

More information about the Terraform `import {}` block and it's use when generating HCL can be found on [Terraform's Configuration Language Documentation](https://developer.hashicorp.com/terraform/language/import).

## Requirements

* The script is a shell script.  A bash (or equivalent) shell terminal must be used.
* `jq` must be installed.
* `curl` must be installed.
* The script supports Basic auth to the APIs.  If using your own PingFederate instance, ensure Basic auth is enabled.

## QuickStart

The following instructions are a quickstart for using the tool.

First, clone the repo and set our current directory:
```shell
git clone https://github.com/patrickcping/pingfederate-terraform-export.git
cd pingfederate-terraform-export
PF_TF_EXPORT=`pwd`
```

For testing, run the docker container locally.

**Before running a docker image locally, ensure all the pre-reqs are met by following the [Getting Started pre-reqs](https://devops.pingidentity.com/get-started/prereqs/) at [devops.pingidentity.com](https://devops.pingidentity.com/)
```shell
docker run --name pingfederate_terraform_provider_container \
		-d -p 9031:9031 \
		-d -p 9999:9999 \
		--env-file "${HOME}/.pingidentity/config" \
		-e SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git \
		-e SERVER_PROFILE_BRANCH=2312 \
		-e SERVER_PROFILE_PATH=baseline/pingfederate \
		pingidentity/pingfederate:12.0.0-latest
```

Tail the logs to ensure the server has started:
```shell
docker logs -f pingfederate_terraform_provider_container
```

Initialise Terraform:
```shell
cd $PF_TF_EXPORT/terraform
terraform init
```

Optional: Prepare the script for use with a different PingFederate.
* Open the file `$PF_TF_EXPORT/scripts/generate_import_blocks.sh`
* In the `Configuration` block, modify:
  * The `API_BASE_URL` parameter for your own PingFederate instance (e.g. `https://localhost:9999/pf-admin-api/v1`)
  * The `API_USERNAME` parameter for connecting to the PingFederate API using basic auth
  * The `API_PASSWORD` parameter for connecting to the PingFederate API using basic auth
* Save the file.

Run the script to pull configuration as `import {}` blocks:
```shell
cd $PF_TF_EXPORT/scripts
./generate_import_blocks.sh
```

Use Terraform to generate HCL from the `import {}` blocks:
```shell
cd $PF_TF_EXPORT/terraform
terraform plan -generate-config-out=generated.tf
```

Errors will be observed, but the HCL will have been generated in the `generated.tf` file.

**Manual work is required to clean and re-format the HCL as needed.**

## Cleanup

Stop the Docker container:
```shell
docker stop pingfederate_terraform_provider_container
```

Remove the Docker container:

```shell
docker container rm pingfederate_terraform_provider_container
```

## Limitations

The script is provided as a guide only.  Resources that can be extracted are found in the `scripts/ProviderMappings.json` file and this file can be extended as needed.  The list of resources that can be exported as `import {}` blocks are:

* `pingfederate_authentication_policy_contract` - [Terraform Registry Doc Link](https://registry.terraform.io/providers/pingidentity/pingfederate/latest/docs/resources/authentication_policy_contract)
* `pingfederate_idp_adapter` - [Terraform Registry Doc Link](https://registry.terraform.io/providers/pingidentity/pingfederate/latest/docs/resources/pingfederate_idp_adapter)
* `pingfederate_idp_sp_connection` - [Terraform Registry Doc Link](https://registry.terraform.io/providers/pingidentity/pingfederate/latest/docs/resources/pingfederate_idp_sp_connection)
* `pingfederate_password_credential_validator` - [Terraform Registry Doc Link](https://registry.terraform.io/providers/pingidentity/pingfederate/latest/docs/resources/pingfederate_password_credential_validator)

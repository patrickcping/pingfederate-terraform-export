#!/bin/bash

################################################
# Configuration

# Admin API endpoint connection details
API_BASE_URL="https://localhost:9999/pf-admin-api/v1"
API_USERNAME="administrator"
API_PASSWORD="2FederateM0re"

# End of configuration
################################################

BULK_EXPORT_API_URL="$API_BASE_URL/bulk/export?includeExternalResources=false"

# Check if jq is installed
if command -v jq &> /dev/null; then
    echo "jq is installed."
else
    echo "jq is not installed. Please install jq."
fi

# Check if curl is installed
if command -v curl &> /dev/null; then
    echo "curl is installed."
else
    echo "curl is not installed. Please install curl."
fi

# File path to the template
TEMPLATE_FILE="../templates/result_template.txt"

#set -x

# Make API request and store response in a variable
api_response=$(curl -u ${API_USERNAME}:${API_PASSWORD} -X 'GET' -k \
  ${BULK_EXPORT_API_URL} \
  -H 'accept: application/json' \
  -H 'X-XSRF-Header: PingFederate')

# Check if the API request was successful
if [ $? -ne 0 ]; then
    echo "Error making API request"
    exit 1
fi

if [[ $(echo $api_response | jq -r '.metadata.pfVersion') =~ ^12\.[0-9]{1}\.[0-9]{1}\.[0-9]{1}$ ]]; then
    echo "API request successful"
else
    echo "Error making API request - error response: $(echo $api_response | jq -r '.message')"
    exit 1
fi

RESULT=""

echo "" > ../terraform/import.tf

# Use jq to parse the JSON response and loop through the array
jq -c '.[]' "./ProviderMappings.json" | while read -r mapping; do

    jqExpression=$(echo $mapping | jq -r '.jqExpression')
    resourceType=$(echo $mapping | jq -r '.providerResource')
    resourceTypeDescription=$(echo $mapping | jq -r '.providerResourceDescription')

    configItems=$(echo $api_response | jq -r "$jqExpression")
    configItemsArray=$(echo $configItems | jq -c '.[]')


    IFS=$'\n'
    for item in $configItemsArray; do

        rawid=$(echo $item | jq -r '.id')
        formattedid=$(echo $rawid | tr -c '[:alnum:]' '_' | tr '[:upper:]' '[:lower:]')
        name=$(echo $item | jq -r '.name')

        echo Generating import for $resourceType.$formattedid \(ID: $rawid / Name: $name\)

        sed "s/{RESOURCE_NAME}/$resourceType/g; s/{RESOURCE_DESCRIPTION}/$resourceTypeDescription/g; s/{API_NAME}/$name/g; s/{API_RAWID}/$rawid/g; s/{API_RESOURCE_FORMATTED_ID}/$formattedid/g" "$TEMPLATE_FILE" >> ../terraform/import.tf

    done
done

echo "Done"

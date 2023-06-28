#!/bin/sh
# Variables
url="https://api.linode.com/v4"
node_path="linode/instances"
fw_path="networking/firewalls/$fw_id/devices"

# Get node ID
get_node_id() {
  local counter=0
  
 while [[ -z "$node_id" && $counter -lt 100 ]]; do
  
  counter=$((counter+1))
node_id=$(curl -H "Authorization: Bearer $LINODE_CLI_TOKEN" "$url/$node_path" -H 'X-Filter: { "label": "'"$LINODE_ID"'" }' | awk -F'[:,]' '/"id"/{print $3}')
node_id="${node_id#"${node_id%%[![:space:]]**}"}"
sleep 1
done
if [[ -z "$node_id" ]]; then
echo "Failed to retrieve valid node ID."
exit 1
else
fw_data="{ \"type\": \"linode\", \"id\": "$node_id" }"
fi

}

# Post firewall data
post_fw_data() {
response=$(curl -H "Content-Type: application/json" -H "Authorization: Bearer $LINODE_CLI_TOKEN" -X POST -d "$fw_data" "$url/$fw_path")
  echo "Posted firewall data: $fw_data"
 echo $response
}


# Main script
existing_nodes=""

get_node_id

while true; do
 existing_nodes=$(curl -s -H "Authorization: Bearer $LINODE_CLI_TOKEN" "$url/$fw_path" | jq -r '.data[].entity.id | tonumber')
 echo $existing_nodes
 echo $url/$fw_path
 if echo "$existing_nodes" | grep -q "$node_id"; then
 echo "node exists"
 sleep $interval
 exit
 else
 echo "node does not exist"
 post_fw_data
 sleep $interval 
fi
  
  # Wait for changes to propagate
  sleep 10
  
  existing_nodes=$(curl -s -H "Authorization: Bearer $LINODE_CLI_TOKEN" "$url/$fw_path" | jq -r '.data[].entity.id | tonumber')
  if echo "$existing_nodes" | grep -q "$node_id"; then
  echo "node exists"
  sleep $interval
 exit 
 
  fi
done


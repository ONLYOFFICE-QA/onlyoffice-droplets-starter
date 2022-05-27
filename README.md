# onlyoffice-droplets-starter

## Key generation

1. Add the [ssh key](https://cloud.digitalocean.com/account/security) to your DO account

2. You'll need to generate an access token in DigitalOcean's control panel

   [Account api token](https://cloud.digitalocean.com/settings/applications)

3. After add digitalocean API token in file

    ```bash
      ~/.do/access_token
    ```

## Configuration

It is necessary to fill in the values of variables in the file

  ```bash
    ./lib/data/static_data.rb
  ```

* PROJECT_NAME: [Optional] - __If you want to add a droplet to the selected project__
* LOADER_PATTERN: [Required] - __Name pattern on your droplets__
* DROPLET_REGION: [Required] - __default: 'nyc3'__
* DROPLET_IMAGE: [Required] - __default: 'docker-20-04'__
* DROPLET_SIZE: [Required] - __default: 's-1vcpu-1gb'__
* SSH_KEY_ID: [Required] - __*Find this value after the Api request__

### SSH_KEY_ID

To set the SSH_KEY_ID, you need to send a __GET__ request.

Api documentation [List All SSH Keys](https://docs.digitalocean.com/reference/api/api-reference/#operation/list_all_keys)

Or you can use the script for a quick search

  ```bash
    #!/bin/bash

    DIGITALOCEAN_TOKEN=$(cat ~/.do/access_token)

    # install jq util
    sudo apt update && sudo apt install jq

    curl -X GET \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
      "https://api.digitalocean.com/v2/account/keys" \
      | jq
  ```

In the output of the script copy the id value
for your ssh and set the value in the file:

  ```bash
    ~/.do/ssh_key_id
  ```

### Finally for configuration add the document server version to the bash script

  ```bash
    ./lib/bash_script/script.sh
  ```

### Set project dependencies

  ```bash
    bundle install
  ```

## Usage

All rake commands

  ```bash
    rake -T
  ```

### Command for start droplets

  ```bash
    rake create_droplets[container_count]
  ```

Where the [container_count] should contain the number [integer] of droplets to open.

### Command for start convert_service_testing

  ```bash
    rake launch[7.0.0.0]
  ```

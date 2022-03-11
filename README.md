# onlyoffice-droplets-starter

## Key generation

### The first step is to add the ssh key to your DO account
    
[Digital ocean account security](https://cloud.digitalocean.com/account/security)

>You find a guide on the website DO

### Second step you'll need to generate an access token in DigitalOcean's control panel

[Account api token](https://cloud.digitalocean.com/settings/applications)

### After add digitalocean API token in file:

```bash
.do/access_token
```

## Configuration

It is necessary to fill in the values of variables in the file

```bash
./lib/data/static_data.rb
```

* PROJECT_NAME: [Optional] __If you want to add a droplet to the selected project__
* LOADER_PATTERN: [Required] __Name pattern on your droplets__
* DROPLET_REGION: [Required]
* DROPLET_IMAGE: [Required]
* DROPLET_SIZE: [Required]
* SSH_KEY_ID: [Required] __*Find this value after the Api request__

### SSH_KEY_ID

To set the SSH_KEY_ID, you need to send a GET request.

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

### Finally for configuration add the document server version to the bash script:

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

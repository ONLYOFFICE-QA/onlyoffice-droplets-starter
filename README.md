# onlyoffice-droplets-starter

## Installation

Execute in project directory 

```bash
bundle install
```

You'll need to generate an access token in DigitalOcean's control panel at https://cloud.digitalocean.com/settings/applications

After add digitalocean API token in file:

```bash
.do/access_token
```

It is necessary to fill in the values of variables in the file

```bash
./lib/data/static_data.rb
```

* PROJECT_NAME: __If you have project add droplet__
* LOADER_PATTERN: __Name pattern on your droplets__
* DROPLET_REGION:
* DROPLET_IMAGE:
* DROPLET_SIZE:
* SSH_KEY_ID: __Find this value after the Api request__

Finally add the documentserver version to the script:

```bash
./lib/bash_script/script.sh
```

## Usage

You need use RAKE command:

```bash
rake create_droplets[container_count]
```

Where the first parameter should contain the number of containers to open.
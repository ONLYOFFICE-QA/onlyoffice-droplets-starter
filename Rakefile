# frozen_string_literal: true

require_relative 'lib/management'

def init_api
  @init_api ||= OnlyofficeDigitaloceanWrapper::DigitalOceanWrapper.new
end

desc 'Create containers'
task :create_droplets, :container_count do |_t, args|
  RakeHelper.init_api = init_api
  args.with_defaults(container_count: 1)
  container_count = args[:container_count].to_i

  container_count.times do |_|
    droplet_name = RakeHelper.next_loader_name
    RakeHelper.create_droplet(droplet_name)
    RakeHelper.include_in_the_project(droplet_name)
    ip = @init_api.get_droplet_ip_by_name(droplet_name)
    `cat ./lib/bash_scripts/script.sh | ssh -o StrictHostKeyChecking=no root@#{ip} /bin/bash`
    puts('Run one container')
    sleep(5) # Timeout between commands to not be banned by ssh
  end
end

desc 'Start convert_service_testing'
task :start_cst do |_t|
  RakeHelper.init_api = init_api
  droplet_name = 'convert-service-testing'
  RakeHelper.create_droplet(droplet_name)
  RakeHelper.include_in_the_project(droplet_name)
  ip = @init_api.get_droplet_ip_by_name(droplet_name)

  `echo "mkdir /root/.palladium
        mkdir /root/.s3
        put #{StaticData::PALLADIUM_TOKEN_PATH} /root/.palladium/token
        put #{StaticData::PRIVATE_KEY_PATH} /root/.s3/private_key
        put #{StaticData::KEY_PATH} /root/.s3/key
   bye" | sftp -o StrictHostKeyChecking=no root@#{ip}`

  `cat ./lib/bash_scripts/script-convert.sh | ssh -o StrictHostKeyChecking=no root@#{ip} /bin/bash`

  puts('Run project convert_service_testing')
end

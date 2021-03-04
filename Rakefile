# frozen_string_literal: true

require_relative 'management'

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
    `cat ./script.sh | ssh -o StrictHostKeyChecking=no root@#{ip} /bin/bash`
    puts('Run one container')
    sleep(5) # Timeout between commands to not be banned by ssh
  end
end

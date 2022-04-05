# frozen_string_literal: true

require_relative 'lib/management'

desc 'Create containers'
task :create_droplets, :container_count do |_t, args|
  args.with_defaults(container_count: 1)
  container_count = args[:container_count].to_i

  container_count.times do |_|
    droplet_name = digital_ocean_helper.next_loader_name
    digital_ocean_helper.create_droplet(droplet_name)
    digital_ocean_helper.include_in_the_project(droplet_name)
    ip = digital_ocean_helper.do_api.get_droplet_ip_by_name(droplet_name)
    `cat ./lib/bash_scripts/script.sh | ssh -o StrictHostKeyChecking=no root@#{ip} /bin/bash`
    puts('Run one container')
    sleep(5) # Timeout between commands to not be banned by ssh
  end
end

desc 'Docserver version entry format "7.0.0.0"'
task :convert_run, :docserver_version do |_t, args|
  docserver_version = args[:docserver_version].to_s

  StaticData::SPEC_FILES.each do |spec|
    droplet_name = digital_ocean_helper.next_loader_name
    digital_ocean_helper.create_droplet(droplet_name)
    digital_ocean_helper.include_in_the_project(droplet_name)

    # debug
    # droplet_name = 'droplets-starter-0'
    # docserver_version = '7.1.0.91'
    # spec = 'check_open_docx_by_screen_spec.rb'

    host = digital_ocean_helper.do_api.get_droplet_ip_by_name(droplet_name)
    OnlyofficeDigitaloceanWrapper::SshChecker.new(host).wait_until_ssh_up
    RemoteAccess.new(host, docserver_version, spec).configuration_project
    sleep 5 # Timeout between commands to not be banned by ssh
  end
end

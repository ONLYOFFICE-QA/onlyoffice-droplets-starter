# frozen_string_literal: true

require_relative 'lib/management'

desc 'Create containers'
task :create_droplets, :container_count do |_t, args|
  args.with_defaults(container_count: 1)
  container_count = args[:container_count].to_i

  container_count.times do |num|
    droplet_name = digital_ocean_helper.next_loader_name
    digital_ocean_helper.create_droplet(droplet_name)
    digital_ocean_helper.include_in_the_project(droplet_name)
    ip = digital_ocean_helper.do_api.get_droplet_ip_by_name(droplet_name)
    OnlyofficeDigitaloceanWrapper::SshChecker.new(ip).wait_until_ssh_up(timeout: 120)
    RemoteConfiguration.new(host: ip).run_script_on_server('ds_run.sh')
    puts("Run container #{num}")
    sleep(5) # Timeout between commands to not be banned by ssh
  end
end

desc 'Docserver version entry format "7.0.0.0"'
task :launch, :version do |_t, args|
  StaticData::SPEC_FILES_LIST['conversion_by_format'] do |spec|
    droplet_name = digital_ocean_helper.next_loader_name
    digital_ocean_helper.create_droplet(droplet_name)
    digital_ocean_helper.include_in_the_project(droplet_name)
    ip = digital_ocean_helper.do_api.get_droplet_ip_by_name(droplet_name)
    OnlyofficeDigitaloceanWrapper::SshChecker.new(ip).wait_until_ssh_up
    RemoteConfiguration.new(host: ip,
                            version: args[:version].to_s,
                            spec:).build_convert_service_testing
    sleep 5 # Timeout between commands to not be banned by ssh
  end
end

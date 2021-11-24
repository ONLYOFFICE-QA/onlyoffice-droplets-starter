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

desc 'Convert service testing run in parallel container'
task :run do
  StaticData::SPEC_FILES.each do |spec|
    droplet_name = digital_ocean_helper.next_loader_name
    digital_ocean_helper.create_droplet(droplet_name)
    digital_ocean_helper.include_in_the_project(droplet_name)

    # droplet_name = 'convert-service-0'
    host = digital_ocean_helper.do_api.get_droplet_ip_by_name(droplet_name)

    ssh_checker(host).wait_until_ssh_up
    remote_control_helper.initialize_keys(host, StaticData::DEFAULT_USER)

    remote_control_helper.run_bash_script(host, StaticData::DEFAULT_USER,
                                          File.read('lib/bash_scripts/add_swap.sh'))

    docserver_version = 'onlyoffice/4testing-documentserver-de:7.0.0.49'

    ssh(host, StaticData::DEFAULT_USER) do |ssh|
      response = ssh.exec! 'git clone https://github.com/ONLYOFFICE-QA/convert-service-testing.git'
      logger.info response.rstrip

      sed_script = "s,onlyoffice/4testing-documentserver-ie:latest,#{docserver_version},g"
      response = ssh.exec! "sed -i #{sed_script} convert-service-testing/docker-compose.yml; echo 'done'"
      logger.info "Sed docserver version is #{response.rstrip}"

      response = ssh.exec! "convert-service-testing/docker-compose up #{spec}"
      logger.info "Sed docserver version is #{response.rstrip}"
    end

    sleep(5)
  end
end

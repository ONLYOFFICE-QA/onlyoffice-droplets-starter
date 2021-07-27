# frozen_string_literal: true

# Class represent rake helper methods
class DigitalOceanHelper
  class << self
    attr_accessor :init_api

    private

    def logger
      @logger ||= Logger.new($stdout)
    end

    def project_by_name(project_name)
      @init_api.retry_exception do
        projects = @init_api.client.projects.all
        projects.find { |x| x.name == project_name }
      end
    end

    def get_project_id_by_name(project_name)
      project = project_by_name(project_name)
      if project.nil?
        logger.info("get_project_id_by_name(#{project_name}): not found any projects")
        nil
      else
        logger.info("get_project_id_by_name(#{project_name}): #{project.id}")
        project.id
      end
    end

    # @return [Array<String>] names of currently run loaders
    def loaders_names
      loaders = []
      all_droplets = @init_api.client.droplets.all
      all_droplets.each do |droplet|
        loaders << droplet.name if droplet.name.start_with?(StaticData::DROPLET_NAME_PATTERN)
      end
      loaders
    end

    public

    # @return [String] next name of loader
    def next_loader_name
      loaders = loaders_names
      return "#{StaticData::DROPLET_NAME_PATTERN}-0" if loaders.empty?

      loaders_digits = loaders.map { |x| x[/\d+/].to_i }
      "#{StaticData::DROPLET_NAME_PATTERN}-#{loaders_digits.max + 1}"
    end

    def create_droplet(loader_name)
      droplet = DropletKit::Droplet.new(name: loader_name,
                                        region: StaticData::DROPLET_REGION,
                                        image: StaticData::DROPLET_IMAGE,
                                        size: StaticData::DROPLET_SIZE,
                                        ssh_keys: [StaticData.get_ssh_key_id])
      @init_api.client.droplets.create(droplet)
      @init_api.wait_until_droplet_have_status(loader_name)
    end

    def include_in_the_project(droplet_name)
      droplet_id = @init_api.get_droplet_id_by_name(droplet_name)
      project_id = get_project_id_by_name(StaticData.get_project_name)
      @init_api.client.projects.assign_resources(["do:droplet:#{droplet_id}"], id: project_id)
      logger.info("Droplet #{droplet_name} added by project #{StaticData.get_project_name}")
    end
  end
end

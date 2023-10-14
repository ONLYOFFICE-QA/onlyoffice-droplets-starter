# frozen_string_literal: true

require_relative '../management'

# Class represent rake helper methods
class DigitalOceanHelper
  attr_reader :do_api

  def initialize(api = OnlyofficeDigitaloceanWrapper::DigitalOceanWrapper.new)
    @do_api = api
  end

  private

  # @return [Array<String>] names of currently run loaders
  def loaders_names
    loaders = []
    all_droplets = @do_api.client.droplets.all
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

  # @param [Object] loader_name
  # @return [Symbol, nil]
  def create_droplet(loader_name)
    droplet = DropletKit::Droplet.new(name: loader_name,
                                      region: StaticData::DROPLET_REGION,
                                      image: StaticData::DROPLET_IMAGE,
                                      size: StaticData::DROPLET_SIZE,
                                      ssh_keys: [StaticData.ssh_key_id])
    @do_api.client.droplets.create(droplet)
  end

  # @param [Object] droplet_name
  # @return [TrueClass]
  def include_in_the_project(droplet_name)
    droplet_id = @do_api.get_droplet_id_by_name(droplet_name)
    project_id = @do_api.get_project_id_by_name(StaticData.project_name)
    @do_api.client.projects.assign_resources(["do:droplet:#{droplet_id}"], id: project_id)
    logger.info("Droplet #{droplet_name} added by project #{StaticData.project_name}")
  end
end

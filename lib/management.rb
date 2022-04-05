# frozen_string_literal: true

require 'bundler/setup'
require 'onlyoffice_digitalocean_wrapper'
require 'droplet_kit'
require_relative 'data/static_data'
require_relative 'helpers/digital_ocean_helper'
require_relative 'helpers/remote_access'

def digital_ocean_helper
  @digital_ocean_helper ||= DigitalOceanHelper.new
end

def logger
  @logger = Logger.new($stdout)
end

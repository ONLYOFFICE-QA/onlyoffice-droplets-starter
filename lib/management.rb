# frozen_string_literal: true

require 'bundler/setup'
require 'onlyoffice_digitalocean_wrapper'
require 'droplet_kit'
require 'net/ssh'
require 'net/sftp'
require 'stringio'
require 'logger'
require_relative 'data/static_data'
require_relative 'helpers/ssh_client'
require_relative 'helpers/sftp_client'
require_relative 'helpers/file_manager'
require_relative 'helpers/digital_ocean_helper'
require_relative 'helpers/remote_configuration'

def digital_ocean_helper
  @digital_ocean_helper ||= DigitalOceanHelper.new
end

# @return [Logger] Object for interaction with a simple logger
def logger
  @logger = Logger.new($stdout)
end

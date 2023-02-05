# frozen_string_literal: true

require 'bundler/setup'
require 'onlyoffice_digitalocean_wrapper'
require 'droplet_kit'
require 'net/sftp'
require 'net/ssh'
require 'stringio'
require 'logger'
require 'tmpdir'
require_relative 'data/static_data'
require_relative 'ssh/ssh_wrapper'
require_relative 'ssh/sftp_client'
require_relative 'helpers/file_manager'
require_relative 'helpers/digital_ocean_helper'
require_relative 'helpers/remote_configuration'

# @return [DigitalOceanHelper] Returns DigitalOceanHelper instance if DigitalOcean doesn't exist
def digital_ocean_helper
  @digital_ocean_helper ||= DigitalOceanHelper.new
end

# @return [Logger] Returns Logger instance if Logger doesn't exist
def logger
  @logger ||= Logger.new($stdout)
end

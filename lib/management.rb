# frozen_string_literal: true

require 'bundler/setup'
require 'onlyoffice_digitalocean_wrapper'
require 'droplet_kit'
require_relative 'data/static_data'
require_relative 'helpers/digital_ocean_helper'
require_relative 'helpers/remote_control_helper'

def digital_ocean_helper
  @digital_ocean_helper ||= DigitalOceanHelper.new
end

def ssh_checker(ip)
  @ssh_checker ||= OnlyofficeDigitaloceanWrapper::SshChecker.new(ip)
end

def remote_control_helper
  @remote_control_helper ||= RemoteControlHelper.new
end

def logger
  @logger = Logger.new($stdout)
end

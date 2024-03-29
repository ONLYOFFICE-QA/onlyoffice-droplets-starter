# frozen_string_literal: true

require 'json'

# class with some constants and static data
class StaticData
  PROJECT_DIR = Dir.pwd.freeze
  BASH_SCRIPTS = "#{PROJECT_DIR}/lib/bash_scripts".freeze
  PROJECT_NAME = ''
  DROPLET_NAME_PATTERN = 'droplets-starter'
  DROPLET_REGION = 'nyc3'
  DROPLET_IMAGE = 'docker-20-04'
  DROPLET_SIZE = 's-1vcpu-1gb'
  SSH_KEY_ID = ''

  DEFAULT_USER = 'root'

  PATH_ARRAY = [
    { dir: '.s3', file: 'key' },
    { dir: '.s3', file: 'private_key' },
    { dir: '.palladium', file: 'token' },
    { dir: '.documentserver', file: 'documentserver_jwt' }
  ].freeze

  SPEC_FILES_LIST = JSON.load_file("#{Dir.pwd}/lib/assets/spec_list.json")

  DOCKERFILE = "/#{StaticData::DEFAULT_USER}/convert-service-testing/Dockerfile".freeze
  ENV = "/#{StaticData::DEFAULT_USER}/convert-service-testing/.env".freeze
  SWAP = './lib/bash_scripts/swap.sh'

  GIT_CLONE_PROJECT = 'git clone https://github.com/ONLYOFFICE-QA/convert-service-testing.git; echo "project is cloned"'

  # @return [String] project name in DigitalOcean
  def self.project_name
    return ENV.fetch('PROJECT_NAME', nil) if ENV['PROJECT_NAME']

    File.read("#{Dir.home}/.do/project_name").rstrip
  end

  # @return [String] SSH key id
  def self.ssh_key_id
    return ENV.fetch('SSH_KEY_ID', nil) if ENV['SSH_KEY_ID']

    File.read("#{Dir.home}/.do/ssh_key_id").rstrip
  end

  # @return [String] Palladium token
  def self.palladium_token
    return ENV.fetch('PALLADIUM_TOKEN', nil) if ENV['PALLADIUM_TOKEN']

    File.read("#{Dir.home}/.palladium/token").rstrip
  end

  # @return [String] Documentserver jwt
  def self.jwt_key
    File.read("#{Dir.home}/.documentserver/documentserver_jwt").rstrip
  end

  # @return [String] S3 private key
  def self.s3_private_key
    File.read("#{Dir.home}/.s3/private_key").rstrip
  end

  # @return [String] S3 public key
  def self.s3_public_key
    File.read("#{Dir.home}/.s3/key").rstrip
  end
end

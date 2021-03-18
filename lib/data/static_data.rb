# frozen_string_literal: true

# class with some constants and static data
class StaticData
  PROJECT_NAME = ''
  DROPLET_NAME_PATTERN = 'droplets-starter'
  DROPLET_REGION = 'nyc3'
  DROPLET_IMAGE = 'docker-20-04'
  DROPLET_SIZE = 's-1vcpu-1gb'
  SSH_KEY_ID = ''

  def self.get_project_name
      return ENV['PROJECT_NAME'] if ENV['PROJECT_NAME']

      File.read("#{Dir.home}/.do/project_name").delete("\n")
  end

  def self.get_ssh_key_id
      return ENV['SSH_KEY_ID'] if ENV['SSH_KEY_ID']

      File.read("#{Dir.home}/.do/ssh_key_id").delete("\n")
  end
end

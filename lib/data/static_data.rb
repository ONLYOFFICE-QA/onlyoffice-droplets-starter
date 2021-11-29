# frozen_string_literal: true

# class with some constants and static data
class StaticData
  PROJECT_NAME = ''
  DROPLET_NAME_PATTERN = 'droplets-starter'
  DROPLET_REGION = 'nyc3'
  DROPLET_IMAGE = 'docker-20-04'
  DROPLET_SIZE = 's-1vcpu-1gb'
  SSH_KEY_ID = ''

  DEFAULT_USER = 'root'

PATHS_LIST = [
        {dir: '.palladium',      file: 'token'},
        {dir: '.s3',             file: 'private_key'},
        {dir: '.s3',             file: 'key'},
        {dir: '.documentserver', file: 'documentserver_jwt'}
        ].freeze

  SPEC_FILES = %w[check_open_docx_by_screen_spec.rb
                  check_open_epub_by_screen_spec.rb
                  check_open_fb2_by_screen_spec.rb
                  check_open_odp_by_screen_spec.rb
                  check_open_odt_by_screen_spec.rb
                  check_open_pptx_by_screen_spec.rb
                  check_open_xlsx_by_screen_spec.rb
                  check_open_ods_by_screen_spec.rb
                  check_open_html_by_screen_spec.rb].freeze

  def self.get_project_name
      return ENV['PROJECT_NAME'] if ENV['PROJECT_NAME']

      File.read("#{Dir.home}/.do/project_name").rstrip
  end

  def self.get_ssh_key_id
      return ENV['SSH_KEY_ID'] if ENV['SSH_KEY_ID']

      File.read("#{Dir.home}/.do/ssh_key_id").rstrip
  end

  def self.get_palladium_token
    return ENV['PALLADIUM_TOKEN'] if ENV['PALLADIUM_TOKEN']

    File.read("#{ENV['HOME']}/.palladium/token").rstrip
  end

  def self.get_jwt_key
    File.read("#{ENV['HOME']}/.documentserver/documentserver_jwt").rstrip
  end

  def self.s3_private_key
    File.read("#{ENV['HOME']}/.s3/private_key").rstrip
  end

  def self.s3_public_key
    File.read("#{ENV['HOME']}/.s3/key").rstrip
  end
end

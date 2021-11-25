# frozen_string_literal: true '

require 'net/sftp'
require 'logger'

def logger
  @logger = Logger.new($stdout)
end

def sftp(host, user, &block)
  @sftp = Net::SFTP.start(host, user, &block)
end

def ssh(host, user, &block)
  @ssh ||= Net::SSH.start(host, user, &block)
end

# Describer
class RemoteControlHelper

  private

  # @param [Object] sftp_object
  # @param [Object] path
  # @param [Object] file_name
  # @return [TrueClass, FalseClass]
  def remote_file_exist?(sftp_object, path, file_name)
    @file_list.clear if nil?
    @file_list = []
    sftp_object.dir.foreach(path) do |entry|
      @file_list << entry.name
    end
    @file_list.include?(file_name)
  end

  # @param [Object] session
  # @param [String] line_number
  # @param [Object] desired
  # @param [Object] replaceable
  # @param [Object] file
  # @return [TrueClass]
  def sed(session, line_number = '', desired, replaceable, file)
    sed_script = "#{line_number}s,#{desired},#{replaceable},"
    response = session.exec! "sed -i #{sed_script} #{file}; echo done"
    logger.info "Sed #{file} is #{response.rstrip}"
  end

  public

  # @param [Object] host
  # @param [Object] docserver_version
  # @return [Array, Net::SSH::Authentication]
  def configuration_project(host, docserver_version)
    ssh(host, StaticData::DEFAULT_USER) do |ssh|
      response = ssh.exec! 'git clone https://github.com/ONLYOFFICE-QA/convert-service-testing.git'
      logger.info response.rstrip

      sed(ssh,'4', "\\\"\\\"", "\\\"#{StaticData.s3_public_key}\\\"",
          'convert-service-testing/Dockerfile')
      sed(ssh,'5', "\\\"\\\"", "\\\"#{StaticData.s3_private_key}\\\"",
          'convert-service-testing/Dockerfile')
      sed(ssh,'6', "\\\"\\\"", "\\\"#{StaticData.get_palladium_token}\\\"",
          'convert-service-testing/Dockerfile')
      sed(ssh,'7', "\\\"\\\"", "\\\"#{StaticData.get_jwt_key}\\\"",
          'convert-service-testing/Dockerfile')

      sed(ssh, '','onlyoffice/4testing-documentserver-ie:latest',
          "#{docserver_version}", 'convert-service-testing/docker-compose.yml')
    end
  end

  # @param [Object] host
  # @param [Object] user
  # @return [Net::SFTP::Session, nil]
  def initialize_keys(host, user)
    sftp(host, user) do |sftp|
      StaticData::PATHS_LIST.map do |path|
        sftp.mkdir! "/#{user}/#{path[:dir]}" unless remote_file_exist?(sftp, "/#{user}", path[:dir])
        unless remote_file_exist?(sftp, "/#{user}/#{path[:dir]}", path[:file])
          sftp.upload!("#{Dir.home}/#{path[:dir]}/#{path[:file]}",
                       "/#{user}/#{path[:dir]}/#{path[:file]}")
        end
        logger.info "#{path[:dir]}/#{path[:file]} is written"
      end
    end
  end

  # @param [Object] host
  # @param [Object] user
  # @param [Object] script
  # @return [Array, Net::SSH::Authentication]
  def run_bash_script(host, user, script)
    ssh(host, user) do |ssh|
      request = execute_in_shell!(ssh, script)
      logger.info "Script installed? #{request}"
    end
  end

  # @param [Object] session
  # @param [Object] commands
  # @param [String] shell
  # @return [Object]
  def execute_in_shell!(session, commands, shell = 'bash')
    channel = session.open_channel do |ch|
      ch.exec("#{shell} -l") do |ch2, success|
        # Set the terminal type
        ch2.send_data 'export TERM=vt100n'
        # Output each command as if they were entered on the command line
        [commands].flatten.each do |command|
          ch2.send_data "#{command}n"
        end
        # Remember to exit or we'll hang!
        ch2.send_data 'exitn'
        @request_execute_in_shell = success
        # Configure to listen to ch2 data so you can grab stdout
      end
    end
    channel.wait
    @request_execute_in_shell
  end
end

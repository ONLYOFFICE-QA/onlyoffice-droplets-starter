# frozen_string_literal: true

require 'net/ssh'
require 'net/sftp'
require 'stringio'
require 'logger'
require_relative 'ssh_client'
require_relative 'file_manager'

# @return [Logger]
def logger
  @logger = Logger.new($stdout)
end

# Describer
class RemoteAccess
  attr_reader :docserver_version, :spec, :host

  # @param [Object] host
  # @param [Object] docserver_version
  # @param [Object] spec_name
  #
  # @return [Object]
  def initialize(host, docserver_version, spec_name)
    @host = host
    @docserver_version = docserver_version
    @spec_name = spec_name
  end

  private

  # @param [Object] session
  # @param [Object] script
  # @param [String] shell
  #
  # @return [Object]
  def execute_in_shell!(session, script, shell = 'bash')
    channel = session.open_channel do |ch|
      ch.exec("#{shell} -l") do |ch2, success|
        raise 'could not execute command' unless success

        # Set the terminal type
        ch2.send_data 'export TERM=vt100n'
        # Output each command as if they were entered on the command line
        [script].flatten.each do |command|
          ch2.send_data "#{command}n"
        end
        # Remember to exit or we'll hang!
        ch2.send_data 'exitn'
        # Configure to listen to ch2 data so you can grab stdout
      end
    end
    channel.wait
  end

  # @param [Object] session
  # @param [Object] path
  #
  # @return [String]
  def download!(session, path)
    io = StringIO.new
    session.sftp.connect do |sftp|
      sftp.download!(path, io)
    rescue Net::SFTP::Operations::StatusException => e
      logger.error e.message
    ensure
      if io.string.empty?
        logger.error 'Response data empty'
        sftp.close
      end
    end
    io.string
  end

  # @param [Object] session
  # @param [Object] file_path
  # @param [Object] data
  #
  # @return [Object]
  def upload!(session, file_path, data)
    session.sftp.connect do |sftp|
      io = StringIO.new(data.to_s)
      begin
        sftp.upload!(io, file_path)
      rescue Net::SFTP::Operations::StatusException => e
        logger.error e.message
      end
    end
  end


  # @param [Object] session
  # @param [Object] path_to_script
  # 
  # @return [TrueClass]
  def run_bash_script(session, path_to_script)
    request = execute_in_shell!(session, File.read(path_to_script.to_s))
    if request
      logger.info 'Script installed'
    else
      logger.error 'Script is not installed'
    end
    request
  end

  public

  # @return [Array, Net::SSH::Authentication]
  def configuration_project
    SshClient.new.connect(host, StaticData::DEFAULT_USER, ssh_options = {}) do |session|

      run_bash_script(session, 'lib/bash_scripts/add_swap.sh')

      output = session.exec! StaticData::GIT_CLONE_PROJECT
      logger.info output.rstrip

      dockerfile = download!(session, StaticData::DOCKERFILE)
      upload!(session, StaticData::DOCKERFILE,
              FileManager.overwrite(dockerfile, /""/, StaticData::PATHS_LIST))

      env = download!(session, StaticData::ENV)
      upload!(session, StaticData::ENV,
              env = FileManager.overwrite(env, /latest/, @docserver_version))
      upload!(session, StaticData::ENV,
              FileManager.overwrite(env,  /''/, @spec_name))

      output = session.exec! 'cd convert-service-testing/; docker-compose up -d'
      logger.info output.rstrip
    end
  end
end

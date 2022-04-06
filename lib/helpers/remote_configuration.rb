# frozen_string_literal: true

require 'net/ssh'
require 'net/sftp'
require 'stringio'
require 'logger'
require_relative 'ssh_client'
require_relative 'sftp_client'
require_relative 'file_manager'

# @return [Logger]
def logger
  @logger = Logger.new($stdout)
end

# Describer
class RemoteConfiguration
  attr_reader :docserver_version, :spec, :host

  # @param [Object] host
  # @param [Object] docserver_version
  # @param [Object] spec_name
  # @return [Object]
  def initialize(host, docserver_version, spec_name)
    @host = host
    @docserver_version = docserver_version
    @spec_name = spec_name
  end

  # @return [Array, Net::SSH::Authentication]
  def convert_service_testing
    SshClient.new.connect(host, StaticData::DEFAULT_USER, {}) do |session|
      SshClient.run(session, StaticData::SWAP)
      logger.info session.exec! StaticData::GIT_CLONE_PROJECT
      dockerfile = SftpClient.download!(session, StaticData::DOCKERFILE)
      SftpClient.upload!(session,
                         StaticData::DOCKERFILE,
                         FileManager.overwrite(dockerfile, /""/, StaticData::PATHS_LIST))
      env = SftpClient.download!(session, StaticData::ENV)
      SftpClient.upload!(session,
                         StaticData::ENV,
                         env = FileManager.overwrite(env, /latest/, @docserver_version))
      SftpClient.upload!(session,
                         StaticData::ENV,
                         FileManager.overwrite(env, /''/, @spec_name))
      logger.info session.exec! 'cd convert-service-testing/; docker-compose up -d'
    end
  end
end

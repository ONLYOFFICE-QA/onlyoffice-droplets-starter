# frozen_string_literal: true

require_relative '../management'

# class to manage remote configuration
class RemoteConfiguration
  attr_reader :version, :spec, :host, :user

  # @param [Object] args Hash of arguments
  # @return [Object] Returns a new instance of RemoteConfiguration
  def initialize(args)
    @host = args[:host]
    @user = args[:user] || StaticData::DEFAULT_USER
    @version = args[:version]
    @spec_name = args[:spec]
  end

  # @param [Proc] block Code with instructions for net-ssh gem
  def ssh(&block)
    @ssh ||= SshWrapper.new(host, user, {}, &block)
  end

  # @return [Object] Returns a new instance of FileManager if doesn't exist
  def f_manager
    @f_manager ||= FileManager.new
  end

  # @param [Net::SSH::Connection::Channel] channel Receives a current ssh connection
  def overwrite_configs(channel)
    dockerfile = ssh.download!(channel, StaticData::DOCKERFILE)
    ssh.upload!(channel,
                StaticData::DOCKERFILE,
                f_manager.overwrite(dockerfile, /""/, StaticData::PATHS_LIST))

    env = ssh.download!(channel, StaticData::ENV)
    ssh.upload!(channel,
                StaticData::ENV,
                env = f_manager.overwrite(env, /latest/, @version))
    ssh.upload!(channel,
                StaticData::ENV,
                f_manager.overwrite(env, /''/, @spec_name))
  end

  # Configuration, build and run convert service project
  def build_convert_service_testing
    ssh do |channel|
      ssh.exec_in_shell!(channel, File.read(StaticData::SWAP))
      ssh.exec_with_logs!(channel, StaticData::GIT_CLONE_PROJECT)
      overwrite_configs(channel)
      ssh.exec_with_logs!(channel, 'cd convert-service-testing/; docker-compose up -d')
    end
  end
end

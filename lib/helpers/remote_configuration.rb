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
  #
  def ssh(&block)
    @ssh ||= SshWrapper.new(host, user, {}, &block)
  end

  # @return [Object] Returns a new instance of FileManager if doesn't exist
  #
  def f_manager
    @f_manager ||= FileManager.new
  end

  # @param [Net::SSH::Connection::Session] session SSH session
  #
  def overwrite_configs(session)
    dockerfile = ssh.download!(session, StaticData::DOCKERFILE)
    ssh.upload!(session,
                StaticData::DOCKERFILE,
                f_manager.writes_tokens_by_path_array(dockerfile, /""/, StaticData::PATHS_LIST))

    env = ssh.download!(session, StaticData::ENV)
    ssh.upload!(session,
                StaticData::ENV,
                env = f_manager.overwrite(env, /latest/, f_manager.wrap_in_double_quotes(@version)))
    ssh.upload!(session,
                StaticData::ENV,
                f_manager.overwrite(env, /''/, f_manager.wrap_in_double_quotes(@spec_name)))
  end

  # Configuration, build and run convert service project
  #
  def build_convert_service_testing
    ssh do |channel|
      ssh.exec_in_shell!(channel, File.read(StaticData::SWAP))
      ssh.exec_with_logs!(channel, StaticData::GIT_CLONE_PROJECT)
      overwrite_configs(channel)
      ssh.exec_with_logs!(channel, 'cd convert-service-testing/; docker-compose up -d')
    end
  end
end

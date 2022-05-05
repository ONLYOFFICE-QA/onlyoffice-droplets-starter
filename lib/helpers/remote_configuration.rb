# frozen_string_literal: true

require_relative '../management'

# Describer
class RemoteConfiguration
  attr_reader :version, :spec, :host, :user

  def initialize(args)
    @host = args[:host]
    @user = args[:user] || StaticData::DEFAULT_USER
    @version = args[:version]
    @spec_name = args[:spec]
  end

  def ssh(&block)
    @ssh ||= SshWrapper.new(host, user, {}, &block)
  end

  def f_manager
    @f_manager ||= FileManager.new
  end

  # @param [Object] channel
  # @return [Object]
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

  # @return [SshWrapper]
  def build_convert_service_testing
    ssh do |channel|
      ssh.exec_in_shell!(channel, File.read(StaticData::SWAP))
      ssh.exec_with_logs!(channel, StaticData::GIT_CLONE_PROJECT)
      overwrite_configs(channel)
      ssh.exec_with_logs!(channel, 'cd convert-service-testing/; docker-compose up -d')
    end
  end
end

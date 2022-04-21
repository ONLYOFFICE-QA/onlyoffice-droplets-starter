# frozen_string_literal: true

require_relative '../management'

# Describer
class RemoteConfiguration
  attr_reader :version, :spec, :host

  def initialize(args)
    @host = args[:host]
    @version = args[:version]
    @spec_name = args[:spec]
  end

  def ssh(&block)
    @ssh ||= SshWrapper.new(host, StaticData::DEFAULT_USER, {}, &block)
  end

  def f_manager
    @f_manager ||= FileManager.new
  end

  def build_convert_service_testing
    ssh do |channel|
      ssh.exec_in_shell!(channel, File.read(StaticData::SWAP))
      channel.exec!(StaticData::GIT_CLONE_PROJECT)
      overwrite_configs(channel)
      channel.exec!('cd convert-service-testing/; docker-compose up -d') do |_ch, stream, data|
        $stdout << data if stream == :stdout
      end
    end
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
end

# frozen_string_literal: true

require_relative '../management'

# Describer
class RemoteConfiguration
  attr_reader :version, :spec, :host
  def initialize(args)
    @host       = args[:host]
    @version    = args[:version]
    @spec_name  = args[:spec]
  end

  def ssh(&block)
    @ssh ||= SshWrapper.new(host, StaticData::DEFAULT_USER, {}, &block)
  end

  def f_manager
    @f_manager ||= FileManager.new
  end

  def build_convert_service_testing
    ssh do |ch|
      ssh.execute_in_shell!(ch, File.read(StaticData::SWAP))
      ch.exec!(StaticData::GIT_CLONE_PROJECT)

      dockerfile = ssh.download!(ch, StaticData::DOCKERFILE)
      ssh.upload!(ch,
                  StaticData::DOCKERFILE,
                  f_manager.overwrite(dockerfile, /""/, StaticData::PATHS_LIST))

      env = ssh.download!(ch, StaticData::ENV)
      ssh.upload!(ch,
                  StaticData::ENV,
                  env = f_manager.overwrite(env, /latest/, @version))
      ssh.upload!(ch,
                  StaticData::ENV,
                  f_manager.overwrite(env, /''/, @spec_name))

      ch.exec!('cd convert-service-testing/; docker-compose up -d') do |ch2, stream, data|
        $stdout << data if stream == :stdout
      end
    end
  end
end

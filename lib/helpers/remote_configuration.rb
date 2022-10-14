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
    @spec = args[:spec]
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

  # Method for overwriting configurations
  # to start convert_service_testing project
  #
  def overwrite_configs
    ssh.sftp_get(StaticData::DOCKERFILE,
                 "#{StaticData::TMP}/Dockerfile",
                 StaticData::DEFAULT_USER,
                 host)
    file = File.read("#{StaticData::TMP}/Dockerfile")
    file = f_manager.writes_tokens_by_path_array(file, /""/, StaticData::PATH_ARRAY)
    File.write("#{StaticData::TMP}/Dockerfile", file)
    ssh.sftp_put("#{StaticData::TMP}/Dockerfile",
                 StaticData::DOCKERFILE,
                 StaticData::DEFAULT_USER,
                 host)
    ssh.sftp_get(StaticData::ENV, "#{StaticData::TMP}/.env", StaticData::DEFAULT_USER, host)
    file = File.read("#{Dir.pwd}/tmp/.env")
    file = f_manager.overwrite(file, /latest/, f_manager.wrap_in_double_quotes(@version))
    file = f_manager.overwrite(file, /''/, f_manager.wrap_in_double_quotes(@spec))
    File.write("#{StaticData::TMP}/.env", file)
    ssh.sftp_put("#{StaticData::TMP}/.env", StaticData::ENV, StaticData::DEFAULT_USER, host)
    FileUtils.rm %w[Dockerfile .env]
  end

  # Configuration, build and run convert service project
  #
  def build_convert_service_testing
    ssh do |channel|
      ssh.exec_in_shell!(channel, File.read(StaticData::SWAP))
      ssh.exec_with_logs!(channel, StaticData::GIT_CLONE_PROJECT)
      overwrite_configs
      ssh.exec_with_logs!(channel, 'cd convert-service-testing/; docker-compose up -d')
    end
  end
end

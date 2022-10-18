# frozen_string_literal: true

require_relative '../management'

# class to manage remote configuration
class RemoteConfiguration
  attr_reader :version, :spec, :host, :user

  # @param [Object] args Hash of arguments
  # @return [Object] Returns a new instance of RemoteConfiguration
  #
  def initialize(args)
    @host = args[:host]
    @user = args[:user] || StaticData::DEFAULT_USER
    @version = args[:version]
    @spec = args[:spec]
  end

  # @param [Proc] block Code with instructions for net-ssh gem
  # @return [SshWrapper]
  #
  def ssh(&block)
    @ssh ||= SshWrapper.new(host, user, {}, &block)
  end

  # @return [Object] Returns a new instance of FileManager if doesn't exist
  #
  def f_manager
    @f_manager ||= FileManager.new
  end

  # @param [Object] tmpdir
  # @return [Integer]
  #
  def overwrite_dockerfile(tmpdir)
    file = File.read("#{tmpdir}/Dockerfile")
    file = f_manager.writes_tokens_by_path_array(file, /""/, StaticData::PATH_ARRAY)
    File.write("#{tmpdir}/Dockerfile", file)
  end

  # @param [Object] tmpdir
  # @return [Integer]
  #
  def overwrite_dot_env(tmpdir)
    file = File.read("#{tmpdir}/.env")
    file = f_manager.overwrite(file, /latest/, f_manager.wrap_in_double_quotes(@version))
    file = f_manager.overwrite(file, /''/, f_manager.wrap_in_double_quotes(@spec))
    File.write("#{tmpdir}/.env", file)
  end

  # Method for overwriting configurations
  # to start convert_service_testing project
  #
  # @return [TrueClass, FalseClass]
  #
  def overwrite_configs
    Dir.mktmpdir do |tmpdir|
      ssh.sftp_get(StaticData::DOCKERFILE, "#{tmpdir}/Dockerfile", StaticData::DEFAULT_USER, host)
      overwrite_dockerfile(tmpdir)
      ssh.sftp_put("#{tmpdir}/Dockerfile", StaticData::DOCKERFILE, StaticData::DEFAULT_USER, host)

      ssh.sftp_get(StaticData::ENV, "#{tmpdir}/.env", StaticData::DEFAULT_USER, host)
      overwrite_dot_env(tmpdir)
      ssh.sftp_put("#{tmpdir}/.env", StaticData::ENV, StaticData::DEFAULT_USER, host)
    end
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

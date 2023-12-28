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
  # @return [SshWrapper]
  def ssh(&)
    @ssh ||= SshWrapper.new(host, user, {}, &)
  end

  # @param [Proc] block Code with instructions for net-sftp gem
  # @return [SFTPClient]
  def sftp(&)
    @sftp ||= SFTPClient.new(host, user, {}, &)
  end

  # @return [Object] Returns a new instance of FileManager if doesn't exist
  def f_manager
    @f_manager ||= FileManager.new
  end

  # @param [String] file_path
  # @return [Integer]
  def overwrite_dockerfile(file_path)
    file = File.read(file_path)
    file = f_manager.writes_tokens_by_path_array(file, /""/, StaticData::PATH_ARRAY)
    File.write(file_path, file)
  end

  # @param [String] file_path
  # @return [Integer]
  def overwrite_dot_env(file_path)
    file = File.read(file_path)
    file = f_manager.overwrite(file, /latest/, f_manager.wrap_in_double_quotes(@version))
    file = f_manager.overwrite(file, /''/, f_manager.wrap_in_double_quotes(@spec))
    File.write(file_path, file)
  end

  # Method for overwriting configurations
  # to start convert_service_testing project
  def overwrite_configs
    Dir.mktmpdir do |tmpdir|
      sftp do |channel|
        sftp.download_file(channel, StaticData::DOCKERFILE.to_s, "#{tmpdir}/Dockerfile")
        overwrite_dockerfile("#{tmpdir}/Dockerfile")
        sftp.upload_file(channel, "#{tmpdir}/Dockerfile", StaticData::DOCKERFILE.to_s)
        sftp.download_file(channel, StaticData::ENV.to_s, "#{tmpdir}/.env")
        overwrite_dot_env("#{tmpdir}/.env")
        sftp.upload_file(channel, "#{tmpdir}/.env", StaticData::ENV.to_s)
      end
    end
  end

  # Running the specified service on the server
  # @param [String] service_name Service name for run
  def run_service_on_server(service_name)
    logger.info("Run service: #{service_name}")
    ssh do |channel|
      ssh.exec_with_logs!(channel, 'systemctl daemon-reload')
      ssh.exec_with_logs!(channel, "systemctl enable #{service_name}")
      ssh.exec_with_logs!(channel, "systemctl start #{service_name}")
    end
  end

  # Running a script on the server to configure the server
  # @param [String] script  Script name from the folder ./lib/bash_scripts/
  # @param [String] service Service name for run script
  def run_script_on_server(script, service = 'myscript.service')
    logger.info("Copying script: #{script}")
    sftp do |channel|
      sftp.upload_file(channel, "#{StaticData::BASH_SCRIPTS}/#{script}", '/root/script.sh')
      sftp.upload_file(channel, "#{StaticData::BASH_SCRIPTS}/#{service}", "/lib/systemd/system/#{service}")
    end
    run_service_on_server(service)
  end

  # Configuration, build and run convert service project
  def build_convert_service_testing
    ssh do |channel|
      ssh.exec_in_shell!(channel, File.read(StaticData::SWAP))
      ssh.exec_with_logs!(channel, StaticData::GIT_CLONE_PROJECT)
      overwrite_configs
      ssh.exec_with_logs!(channel, 'cd convert-service-testing/; docker-compose up -d')
    end
  end
end

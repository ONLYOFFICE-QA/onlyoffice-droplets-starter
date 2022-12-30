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
  def ssh(&block)
    @ssh ||= SshWrapper.new(host, user, {}, &block)
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
      ssh.sftp_command(StaticData::DEFAULT_USER, host,
                       %(echo "get #{StaticData::DOCKERFILE} #{tmpdir}/Dockerfile"))
      overwrite_dockerfile("#{tmpdir}/Dockerfile")
      ssh.sftp_command(StaticData::DEFAULT_USER, host,
                       %(echo "put #{tmpdir}/Dockerfile #{StaticData::DOCKERFILE}"))

      ssh.sftp_command(StaticData::DEFAULT_USER, host,
                       %(echo "get #{StaticData::ENV} #{tmpdir}/.env"))
      overwrite_dot_env("#{tmpdir}/.env")
      ssh.sftp_command(StaticData::DEFAULT_USER, host,
                       %(echo "put #{tmpdir}/.env #{StaticData::ENV}"))
    end
  end

  # Running a script on the server to configure the server
  # param [String] ip - the server address to configure
  # param [String] script - Script name from the folder ./lib/bash_scripts/
  def self.configure_server(ip, script)
    status = false
    timeout = 0
    until status
      status = system("scp -o StrictHostKeyChecking=no ./lib/bash_scripts/#{script} root@#{ip}:/root/#{script}")
      sleep(5)
      timeout += 1
      return p 'Failed to connect to the server' if timeout == 20
    end
    system("ssh root@#{ip} chmod +x /root/#{script}")
    system("ssh root@#{ip} /root/#{script} > /dev/null 2>&1 &")
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

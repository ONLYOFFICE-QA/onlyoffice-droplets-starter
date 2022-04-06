# frozen_string_literal: true

# Describe
class SftpClient
  class << self
    # @param [Object] session
    # @param [Object] path
    # @return [String]
    def download!(session, path)
      io = StringIO.new
      session.sftp.connect do |sftp|
        sftp.download!(path, io)
      rescue Net::SFTP::Operations::StatusException => e
        logger.error e.message
      ensure
        if io.string.empty?
          logger.error 'Response data empty'
          sftp.close
        end
      end
      io.string
    end

    # @param [Object] session
    # @param [Object] file_path
    # @param [Object] data
    # @return [Object]
    def upload!(session, file_path, data)
      session.sftp.connect do |sftp|
        io = StringIO.new(data.to_s)
        begin
          sftp.upload!(io, file_path)
        rescue Net::SFTP::Operations::StatusException => e
          logger.error e.message
        end
      end
    end
  end
end

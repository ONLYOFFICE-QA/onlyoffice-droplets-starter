# frozen_string_literal: true

require_relative '../management'

# Describe
class FileManager
  # @param [Object] data
  # @param [Object] pattern
  # @param [Object] changes
  # @return [Object]
  def overwrite(data, pattern, changes)
    case changes
    when String
      data = data.sub(pattern, "\"#{changes}\"")
      logger.info("overwriting #{pattern} with #{changes}")
    when Array
      if data.scan(pattern).length == changes.length
        changes.each do |path|
          data = data.sub(pattern, "\"#{File.read("#{ENV.fetch('HOME', nil)}/#{path[:dir]}/#{path[:file]}").rstrip}\"")
          logger.info("#{path[:file]} is written")
        end
      end
    else
      raise 'changes data type is not supported by the method'
    end
    data
  end
end

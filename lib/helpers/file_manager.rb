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
      logger.info 'is overwritten by the pattern'
    when Array
      if data.scan(pattern).length == changes.length
        changes.each do |path|
          data = data.sub(pattern, "\"#{File.read("#{ENV.fetch('HOME', nil)}/#{path[:dir]}/#{path[:file]}").rstrip}\"")
          Logger.new(@stdout).info "#{path[:file]} is written"
        end
      end
    else
      logger.error 'Overwrite error'
    end
    data
  end
end

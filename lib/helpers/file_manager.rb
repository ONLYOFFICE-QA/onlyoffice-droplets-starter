# frozen_string_literal: true

require 'logger'

# Describe
class FileManager

  # @param [Object] data
  # @param [Object] pattern
  # @param [Object] changes
  #
  # @return [Object]
  def self.overwrite(data, pattern, changes)
    case changes
    when String
      data = data.sub(pattern, "\"#{changes}\"")
      Logger.new(@stdout).info 'is overwritten by the pattern'
    when Array
      if data.scan(pattern).length == changes.length
        changes.each do |path|
          data = data.sub(pattern, "\"#{File.read("#{ENV['HOME']}/#{path[:dir]}/#{path[:file]}").rstrip}\"")
          Logger.new(@stdout).info "#{path[:file]} is written"
        end
      end
    else
      Logger.new(@stdout).error 'Overwrite error'
    end
    data
  end
end

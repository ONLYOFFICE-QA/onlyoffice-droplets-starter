# frozen_string_literal: true

require_relative '../spec_helper'

f_manager = FileManager.new

arr_path = [{ dir: 'lib/assets', file: 'test_file' }]

describe FileManager do
  it 'should be able to overwrite String' do
    expect(f_manager.overwrite('pattern', /pattern/, 'test')).to eq('test')
  end

  it 'should be able wrap in double quotes' do
    expect(f_manager.wrap_in_double_quotes('test')).to eq(%Q{"test"})
  end

  it 'should be able to overwrite Array' do
    expect(f_manager.writes_tokens_by_path_array('""',
                                                 /""/,
                                                 Dir.pwd,
                                                 arr_path)).to eq(%Q{"test"})
  end
end

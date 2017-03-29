require 'spec_helper'
describe 'nhproduction' do
  context 'with default values for all parameters' do
    it { should contain_class('nhproduction') }
  end
end

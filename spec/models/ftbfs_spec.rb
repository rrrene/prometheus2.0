require 'spec_helper'

describe Ftbfs do
  it { should belong_to :branch }
  it { should validate_presence_of :branch }

  it { should validate_presence_of :name }
  it { should validate_presence_of :version }
  it { should validate_presence_of :release }
  it { should validate_presence_of :weeks }
  it { should validate_presence_of :arch }
end

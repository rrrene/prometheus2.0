require 'spec_helper'

describe ApplicationHelper do
  it "should return '/en' for url '/' and lang 'en'" do
    current_page('/', 'en').should == '/en'
  end

  it "should change '/en/project' to '/ru/project'" do
    current_page('/en/project', 'ru').should == '/ru/project'
  end
end
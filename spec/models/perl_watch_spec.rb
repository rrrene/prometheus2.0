require 'spec_helper'

describe PerlWatch do
  it { should validate_presence_of :name }

  it "should import data from CPAN" do
    page = `cat spec/data/02packages.details.txt`
    FakeWeb.register_uri(:get,
                         "http://www.cpan.org/modules/02packages.details.txt",
                         :response => page)
    expect{PerlWatch.import_data("http://www.cpan.org/modules/02packages.details.txt")}.to \
    change{PerlWatch.count}.from(0).to(1)
    PerlWatch.count.should == 1
    perlwatch = PerlWatch.first
    perlwatch.name.should == 'AnyEvent::ZeroMQ'
    perlwatch.version.should == '0.01'
    perlwatch.path.should == 'J/JR/JROCKWAY/AnyEvent-ZeroMQ-0.01.tar.gz'
  end
end
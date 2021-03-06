require 'spec_helper'

describe Srpm do
  describe 'Associations' do
    it { should belong_to :branch }
    it { should belong_to :group }
    it { should have_many :packages }
    it { should have_many :changelogs }
    it { should have_many :repocops }
    it { should have_one :specfile }
    it { should have_one :repocop_patch }
    it { should have_many :patches }
    it { should have_many :sources }
  end

  # pending "test :dependent => :destroy for :packages, :changelogs, :acls"
  # pending "test :foreign_key => 'srcname', :primary_key => 'name' for :repocops"

  describe 'Validation' do
    it { should validate_presence_of :branch }
    it { should validate_presence_of :group }
    it { should validate_presence_of :groupname }
    it { should validate_presence_of :md5 }
  end

  it { should have_db_index :branch_id }
  it { should have_db_index :group_id }
  it { should have_db_index :name }

  it 'should return Srpm.name on .to_param' do
    Srpm.new(name: 'openbox').to_param.should eq('openbox')
  end

  it 'should import srpm file' do
    branch = FactoryGirl.create(:branch)
    file = 'openbox-3.4.11.1-alt1.1.1.src.rpm'
    md5 = "f87ff0eaa4e16b202539738483cd54d1  /Sisyphus/files/SRPMS/#{file}"
    maintainer = Maintainer.create!(login: 'icesik', email: 'icesik@altlinux.org', name: 'Igor Zubkov')

    Srpm.should_receive(:`).with("/usr/bin/md5sum #{ file }").and_return(md5)
    Srpm.should_receive(:`).with("export LANG=C && rpm -qp --queryformat='%{NAME}' #{ file }").and_return('openbox')
    Srpm.should_receive(:`).with("export LANG=C && rpm -qp --queryformat='%{VERSION}' #{ file }").and_return('3.4.11.1')
    Srpm.should_receive(:`).with("export LANG=C && rpm -qp --queryformat='%{RELEASE}' #{ file }").and_return('alt1.1.1')
    Srpm.should_receive(:`).with("export LANG=C && rpm -qp --queryformat='%{EPOCH}' #{ file }").and_return('(none)')
    Srpm.should_receive(:`).with("export LANG=C && rpm -qp --queryformat='%{SUMMARY}' #{ file }").and_return('short description')
    Srpm.should_receive(:`).with("export LANG=C && rpm -qp --queryformat='%{GROUP}' #{ file }").and_return('Graphical desktop/Other')

    Srpm.should_receive(:`).with("export LANG=C && rpm -qp --queryformat='%{PACKAGER}' #{ file }").and_return('Igor Zubkov <icesik@altlinux.org>')

    Maintainer.should_receive(:import).with('Igor Zubkov <icesik@altlinux.org>')

    MaintainerTeam.should_not_receive(:import).with('Igor Zubkov <icesik@altlinux.org>')

    Srpm.should_receive(:`).with("export LANG=C && rpm -qp --queryformat='%{LICENSE}' #{ file }").and_return('GPLv2+')
    Srpm.should_receive(:`).with("export LANG=C && rpm -qp --queryformat='%{URL}' #{ file }").and_return('http://openbox.org/')
    Srpm.should_receive(:`).with("export LANG=C && rpm -qp --queryformat='%{DESCRIPTION}' #{ file }").and_return('long description')
    Srpm.should_receive(:`).with("export LANG=C && rpm -qp --queryformat='%{VENDOR}' #{ file }").and_return('ALT Linux Team')
    Srpm.should_receive(:`).with("export LANG=C && rpm -qp --queryformat='%{DISTRIBUTION}' #{ file }").and_return('ALT Linux')
    Srpm.should_receive(:`).with("export LANG=C && rpm -qp --queryformat='%{BUILDTIME}' #{ file }").and_return('1315301838')
    Srpm.should_receive(:`).with("export LANG=C && rpm -qp --queryformat='%{CHANGELOGTIME}' #{ file }").and_return('1312545600')
    Srpm.should_receive(:`).with("export LANG=C && rpm -qp --queryformat='%{CHANGELOGNAME}' #{ file }").and_return('Igor Zubkov <icesik@altlinux.org> 3.4.11.1-alt1.1.1')
    Srpm.should_receive(:`).with("export LANG=C && rpm -qp --queryformat='%{CHANGELOGTEXT}' #{ file }").and_return('- 3.4.11.1')

    File.should_receive(:size).with(file).and_return(831_617)

    Specfile.should_receive(:import).and_return(true)
    Changelog.should_receive(:import).and_return(true)
    Patch.should_receive(:import).and_return(true)
    Source.should_receive(:import).and_return(true)

    expect {
      Srpm.import(branch, file)
    }.to change { Srpm.count }.from(0).to(1)

    srpm = Srpm.first
    srpm.name.should eq('openbox')
    srpm.version.should eq('3.4.11.1')
    srpm.release.should eq('alt1.1.1')
    srpm.epoch.should be_nil
    srpm.summary.should eq('short description')
    srpm.group.full_name.should eq('Graphical desktop/Other')
    srpm.groupname.should eq('Graphical desktop/Other')
    srpm.license.should eq('GPLv2+')
    srpm.url.should eq('http://openbox.org/')
    srpm.description.should eq('long description')
    srpm.vendor.should eq('ALT Linux Team')
    srpm.distribution.should eq('ALT Linux')
    # FIXME:
    # srpm.buildtime.should eq(Time.at(1_315_301_838))
    # srpm.changelogtime.should eq(Time.at(1_312_545_600))
    srpm.changelogname.should eq('Igor Zubkov <icesik@altlinux.org> 3.4.11.1-alt1.1.1')
    srpm.changelogtext.should eq('- 3.4.11.1')
    srpm.filename.should eq('openbox-3.4.11.1-alt1.1.1.src.rpm')

    $redis.get("#{ branch.name }:#{ srpm.filename }").should eq('1')
  end

  it 'should import all srpms from path' do
    branch = FactoryGirl.create(:branch)
    path = '/ALT/Sisyphus/files/SRPMS/*.src.rpm'
    $redis.get("#{ branch.name }:glibc-2.11.3-alt6.src.rpm").should be_nil
    Dir.should_receive(:glob).with(path).and_return(['glibc-2.11.3-alt6.src.rpm'])
    File.should_receive(:exist?).with('glibc-2.11.3-alt6.src.rpm').and_return(true)
    RPM.should_receive(:check_md5).and_return(true)
    Srpm.should_receive(:import).and_return(true)

    Srpm.import_all(branch, path)
  end

  it 'should remove old srpms from database' do
    branch = FactoryGirl.create(:branch)
    group = FactoryGirl.create(:group, branch_id: branch.id)
    srpm1 = FactoryGirl.create(:srpm, branch_id: branch.id, group_id: group.id)
    $redis.set("#{ branch.name }:#{ srpm1.filename }", 1)
    srpm2 = FactoryGirl.create(:srpm, name: 'blackbox', filename: 'blackbox-1.0-alt1.src.rpm', branch_id: branch.id, group_id: group.id)
    $redis.set("#{ branch.name }:#{ srpm2.filename }", 1)
    $redis.sadd("#{ branch.name }:#{ srpm2.name }:acls", "icesik")
    $redis.set("#{ branch.name }:#{ srpm2.name }:leader", "icesik")

    path = '/ALT/Sisyphus/files/SRPMS/'

    File.should_receive(:exists?).with("#{ path }openbox-3.4.11.1-alt1.1.1.src.rpm").and_return(true)
    File.should_receive(:exists?).with("#{ path }blackbox-1.0-alt1.src.rpm").and_return(false)

    expect {
      Srpm.remove_old(branch, path)
    }.to change { Srpm.count }.from(2).to(1)

    $redis.get("#{ branch.name }:openbox-3.4.11.1-alt1.1.1.src.rpm").should eq('1')
    $redis.get("#{ branch.name }:blackbox-1.0-alt1.src.rpm").should be_nil
    $redis.get("#{ branch.name }:#{ srpm2.name }:acls").should be_nil
    $redis.get("#{ branch.name }:#{ srpm2.name }:leader").should be_nil

    # TODO: add checks for sub packages, set-get-delete
  end

  it 'should increment branch.counter on srpm.save' do
    branch = FactoryGirl.create(:branch)
    group = FactoryGirl.create(:group, branch_id: branch.id)
    FactoryGirl.create(:srpm, branch_id: branch.id, group_id: group.id)
    branch.counter.value.should eq(1)
  end

  it 'should decrement branch.counter on srpm.destroy' do
    branch = FactoryGirl.create(:branch)
    group = FactoryGirl.create(:group, branch_id: branch.id)
    srpm = FactoryGirl.create(:srpm, branch_id: branch.id, group_id: group.id)
    srpm.destroy
    branch.counter.value.should eq(0)
  end
end

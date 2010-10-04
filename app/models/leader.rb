class Leader < ActiveRecord::Base
  #validates_presence_of :package, :login
  belongs_to :branch
  belongs_to :maintainer
  belongs_to :srpm

  def self.import_leaders(vendor, branch, url)
    br = Branch.first :conditions => { :name => branch, :vendor => vendor }
    if br.leaders.count(:all) == 0
      ActiveRecord::Base.transaction do
        file = open(URI.escape(url)).read
        file.each_line do |line|
          package = line.split[0]
          srpm = Srpm.first :conditions => { :name => package, :branch_id => br.id }
          login = line.split[1]
          login = 'php-coder' if login == 'php_coder'
          login = 'p_solntsev' if login == 'psolntsev'
          login = '@vim-plugins' if login == '@vim_plugins'
          maintainer = Maintainer.first :conditions => { :login => login }
          if maintainer.nil?
            puts "BAD login: " + login
          elsif srpm.nil?
            puts "BAD package: " + package
          else
            Leader.create :srpm_id => srpm.id, :branch_id => br.id, :maintainer_id => maintainer.id
          end
        end      
      end
    else
      puts Time.now.to_s + ": leaders already imported"
    end
  end

#  def self.update_leaders(vendor, branch, url)
#    ActiveRecord::Base.transaction do
#      ActiveRecord::Base.connection.execute("DELETE FROM leaders WHERE branch = '" + branch + "' AND vendor = '" + vendor + "'")
#
#      file = open(URI.escape(url)).read
#
#      file.each_line do |line|
#        package = line.split[0]
#        login = line.split[1]
#        Leader.create :package => package, :login => login, :branch => branch, :vendor => vendor
#      end
#    end
#  end
end
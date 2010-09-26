namespace :sisyphus do
desc "Import all ACL for packages from Sisyphus to database"
task :acls => :environment do
  require 'open-uri'
  puts Time.now.to_s + ": import all acls for packages from Sisyphus to database"
  Acl.update_acls 'ALT Linux', 'Sisyphus', 'http://git.altlinux.org/acl/list.packages.sisyphus'
  puts Time.now.to_s + ": end"
end

desc "Import RPM groups for Sisyphus to database"
task :groups => :environment do
  require 'open-uri'
  puts Time.now.to_s + ": import RPM groups for Sisyphus to database"
  Group.update_from_gitalt 'ALT Linux', 'Sisyphus'
  puts Time.now.to_s + ": end"
end

desc "Import *.src.rpm from Sisyphus to database"
task :srpms => :environment do
  require 'rpm'
  require 'open-uri'
  puts Time.now.to_s + ": import *.src.rpm from Sisyphus to database"
  Srpm.import_srpms 'ALT Linux', 'Sisyphus'
  puts Time.now.to_s + ": end"
  puts Time.now.to_s + ': update repocop cache'
  Repocop.update_repocop_cache  
  puts Time.now.to_s + ': end'
end

desc "Import *.i586.rpm from Sisyphus to database"
task :i586 => :environment do
  require 'rpm'
  puts Time.now.to_s + ": import *.i586.rpm from Sisyphus to database"
  Package.import_packages_i586 'ALT Linux', 'Sisyphus'
  puts Time.now.to_s + ": end"
end

desc "Import *.noarch.rpm from Sisyphus to database"
task :noarch => :environment do
  require 'rpm'
  puts Time.now.to_s + ": import *.noarch.rpm from Sisyphus to database"
  Package.import_packages_noarch 'ALT Linux', 'Sisyphus'
  puts Time.now.to_s + ": end"
end

desc "Import *.x86_64.rpm from Sisyphus to database"
task :x86_64 => :environment do
  require 'rpm'
  puts Time.now.to_s + ": import *.x86_64.rpm from Sisyphus to database"
  Package.import_packages_x86_64 'ALT Linux', 'Sisyphus'
  puts Time.now.to_s + ": end"
end

desc "Import all leaders for packages from Sisyphus to database"
task :leaders => :environment do
  require 'open-uri'
  puts Time.now.to_s + ": import all leaders for packages from Sisyphus to database"
  Leader.update_from_gitalt 'ALT Linux', 'Sisyphus'
  puts Time.now.to_s + ": end"
end

desc "Import packagers list from src.rpm from Sisyphus to database"
task :packagers => :environment do
  require 'rpm'
  puts Time.now.to_s + ": import packagers list from *.src.rpm's"
  Packager.update_packager_list 'ALT Linux', 'Sisyphus'
  puts Time.now.to_s + ": end"
end

desc "Import all teams from Sisyphus to database"
task :teams => :environment do
  require 'open-uri'
  puts Time.now.to_s + ": import all teams from Sisyphus to database"
  Team.update_from_gitalt 'ALT Linux', 'Sisyphus'
  puts Time.now.to_s + ": end"
end

end

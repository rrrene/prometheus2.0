namespace :sisyphus do
  desc 'Update Sisyphus stuff'
  task :update => :environment do
    require 'open-uri'
    puts "#{Time.now.to_s}: Update Sisyphus stuff"
    if $redis.get('__SYNC__')
      exist = begin
                Process::kill(0, $redis.get('__SYNC__').to_i)
                true
              rescue
                false
              end
      if exist
        puts "#{Time.now.to_s}: update is locked by another cron script"
        Process.exit!(true)
      else
        puts "#{Time.now.to_s}: dead lock found and deleted"
        $redis.del('__SYNC__')
      end
    end
    $redis.set('__SYNC__', Process.pid)
    puts "#{Time.now.to_s}: update *.src.rpm from Sisyphus to database"
    branch = Branch.where(name: 'Sisyphus', vendor: 'ALT Linux').first
    ThinkingSphinx::Deltas.suspend! if ENV['PROMETHEUS2_BOOTSTRAP'] == 'yes'
    Srpm.import_all(branch, '/ALT/Sisyphus/files/SRPMS/*.src.rpm')
    Srpm.remove_old(branch, '/ALT/Sisyphus/files/SRPMS/')
    puts "#{Time.now.to_s}: end"
    puts "#{Time.now.to_s}: update *.i586.rpm/*.noarch.rpm/*.x86_64.rpm from Sisyphus to database"
    pathes = ['/ALT/Sisyphus/files/i586/RPMS/*.i586.rpm',
              '/ALT/Sisyphus/files/noarch/RPMS/*.noarch.rpm',
              '/ALT/Sisyphus/files/x86_64/RPMS/*.x86_64.rpm']
    Package.import_all(branch, pathes)
    ThinkingSphinx::Deltas.resume! if ENV['PROMETHEUS2_BOOTSTRAP'] == 'yes'
    puts "#{Time.now.to_s}: end"
#    # TODO: review and cleanup this code
#    puts "#{Time.now.to_s}: expire cache"
#    ['en', 'ru', 'uk', 'br'].each do |locale|
#      ActionController::Base.new.expire_fragment("#{locale}_top15_#{branch.name}")
#      ActionController::Base.new.expire_fragment("#{locale}_srpms_#{branch.name}_")
#      pages_counter = (branch.srpms.where("srpms.created_at > '2010-11-09 09:00:00'").count / 50) + 1
#      for page in 1..pages_counter do
#        ActionController::Base.new.expire_fragment("#{locale}_srpms_#{branch.name}_#{page}")
#      end
#    end
#    puts "#{Time.now.to_s}: end"
    puts "#{Time.now.to_s}: update acls in redis cache"
    Acl.update_redis_cache('ALT Linux', 'Sisyphus', 'http://git.altlinux.org/acl/list.packages.sisyphus')
    puts "#{Time.now.to_s}: end"
    puts "#{Time.now.to_s}: update leaders in redis cache"
    Leader.update_redis_cache('ALT Linux', 'Sisyphus', 'http://git.altlinux.org/acl/list.packages.sisyphus')
    puts "#{Time.now.to_s}: end"
    puts "#{Time.now.to_s}: update time"
    $redis.set("#{branch.name}:updated_at", Time.now.to_s)
    puts "#{Time.now.to_s}: end"
    $redis.del('__SYNC__')
  end

  # desc 'Import all leaders for packages from Sisyphus to database'
  # task :leaders => :environment do
  #   require 'open-uri'
  #   puts "#{Time.now.to_s}: import all leaders for packages from Sisyphus to database"
  #   Leader.import_leaders('ALT Linux', 'Sisyphus', 'http://git.altlinux.org/acl/list.packages.sisyphus')
  #   puts "#{Time.now.to_s}: end"
  # end
  # 
  # desc 'Import all teams from Sisyphus to database'
  # task :teams => :environment do
  #   require 'open-uri'
  #   puts "#{Time.now.to_s}: import all teams from Sisyphus to database"
  #   Team.import_teams('ALT Linux', 'Sisyphus', 'http://git.altlinux.org/acl/list.groups.sisyphus')
  #   puts "#{Time.now.to_s}: end"
  # end
end

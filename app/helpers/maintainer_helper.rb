module MaintainerHelper
  def fix_maintainer_email(email)
    email.gsub!(' at altlinux.ru', '@altlinux.org')
    email.gsub!(' at altlinux.org', '@altlinux.org')
    email.gsub!(' at altlinux.net', '@altlinux.org')
    email.gsub!(' at altlinux.com', '@altlinux.org')
    email.gsub!(' at altlinux dot org', '@altlinux.org')
    email.gsub!(' at altlinux dot ru', '@altlinux.org')
    email.gsub!(' at altlinux dot net', '@altlinux.org')
    email.gsub!(' at altlinux dot com', '@altlinux.org')
    email.gsub!('@altlinux.ru', '@altlinux.org')
    email.gsub!('@altlinux.net', '@altlinux.org')
    email.gsub!('@altlinux.com', '@altlinux.org')
    email.gsub!(' at packages.altlinux.org', '@packages.altlinux.org')
    email.gsub!(' at packages.altlinux.ru', '@packages.altlinux.org')
    email.gsub!(' at packages.altlinux.net', '@packages.altlinux.org')
    email.gsub!(' at packages.altlinux.com', '@packages.altlinux.org')
    email.gsub!('@packages.altlinux.ru', '@packages.altlinux.org')
    email.gsub!('@packages.altlinux.net', '@packages.altlinux.org')
    email.gsub!('@packages.altlinux.com', '@packages.altlinux.org')
    email
  end
end

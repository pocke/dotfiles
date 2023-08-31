is_arch = File.exist?('/etc/arch-release')
is_mac = `uname`.strip == 'Darwin'

if is_arch
  remote_file '/etc/systemd/system/ruby-trunk-build.service' do
    user 'root'
    owner 'root'
    group 'root'
  end

  remote_file '/etc/systemd/system/ruby-trunk-build.timer' do
    user 'root'
    owner 'root'
    group 'root'
  end
end

directory '/opt/ruby-trunk-build' do
  user 'root'
end

remote_file '/opt/ruby-trunk-build/ruby-trunk-build.sh' do
  user 'root'
  owner 'root'
  group 'root' if is_arch
  mode '755'
end

if is_mac
  remote_file '/Library/LaunchDaemons/launched.ruby-trunk-build.plist' do
    user 'root'
  end

  execute 'load plist' do
    user 'root'
    command 'launchctl unload /Library/LaunchDaemons/launched.ruby-trunk-build.plist; launchctl load /Library/LaunchDaemons/launched.ruby-trunk-build.plist'
  end
end

if is_arch
  execute 'reload daemon' do
    command "systemctl daemon-reload"
    user 'root'
  end

  service 'ruby-trunk-build.timer' do
    user 'root'
    action :enable
  end

  service 'ruby-trunk-build.timer' do
    user 'root'
    action :start
  end
end

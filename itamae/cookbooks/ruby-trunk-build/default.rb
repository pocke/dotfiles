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

directory '/opt/ruby-trunk-build' do
  user 'root'
end

remote_file '/opt/ruby-trunk-build/ruby-trunk-build.sh' do
  user 'root'
  owner 'root'
  group 'root'
  mode '755'
end

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

# Download packages daily

remote_file '/etc/systemd/system/pacman-syuw.service' do
  user 'root'
  owner 'root'
  group 'root'
end

remote_file '/etc/systemd/system/pacman-syuw.timer' do
  user 'root'
  owner 'root'
  group 'root'
end

execute 'reload daemon' do
  command "systemctl daemon-reload"
  user 'root'
end

service 'pacman-syuw.timer' do
  user 'root'
  action :enable
end

service 'pacman-syuw.timer' do
  user 'root'
  action :start
end

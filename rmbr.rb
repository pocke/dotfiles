active_br = `git ls-remote`.chomp.split("\n").select{|x|x[%r!refs/heads!]}.map{|x|x[%r!refs/heads/(.+)$!, 1]}

local_br  = `git branch`.chomp.split("\n").map{|x|x[/^(\s|\*)+(.+)$/, 2]}
remote_br = `git branch -r`.chomp.split("\n").reject{|x|x.include?('origin/HEAD')}.map{|x|x[/^\s+origin\/(.+)$/, 1]}


exec = -> (cmd) {
  puts "> #{cmd}"
  system(cmd)
}

(local_br - active_br).each do |br|
  exec.("git branch -d #{br}")
end


(remote_br - active_br).each do |br|
  exec.("git branch -d -r origin/#{br}")
end
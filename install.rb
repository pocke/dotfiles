require 'fileutils'

def exec(cmd)
  puts "> #{cmd}"
  fail(cmd) unless system(cmd)
end

unless File.exist?(File.expand_path("~/.gitconfig"))
  exec(<<-EOS
cat <<EOF > ~/.gitconfig
[include]
  path = dotfiles/.gitconfig
[core]
  excludesfile = #{File.expand_path("~/dotfiles/.gitignore_global")}
EOF
       EOS
  )
end

unless File.exist?(File.expand_path("~/.zshrc"))
  exec('echo "source dotfiles/.zshrc" >> ~/.zshrc')
end

unless Dir.exist?(File.expand_path('~/.vim/bundle/neobundle.vim'))
  exec('git clone https://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim')
end

unless Dir.exist?(File.expand_path('~/.zsh/zsh-syntax-highlighting'))
  exec('git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting')
end

exec('gem install bundler')
exec('go get github.com/motemen/ghq github.com/jteeuwen/go-bindata/... github.com/pocke/www github.com/golang/lint/golint github.com/peco/peco/...  github.com/pocke/www github.com/pocke/zettai github.com/alecthomas/gometalinter')

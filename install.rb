require 'fileutils'

def exec(cmd)
  puts "> #{cmd}"
  fail(cmd) unless system(cmd)
end

FileUtils.mkdir_p(File.expand_path('~/.bundle'))
FileUtils.mkdir_p(File.expand_path('~/.vim/bundle'))
FileUtils.mkdir_p(File.expand_path('~/.config/awesome/'))
FileUtils.mkdir_p(File.expand_path('~/.config/fontconfig/'))
FileUtils.mkdir_p(File.expand_path('~/.config/peco/'))


%w[
  .gemrc .rspec .tigrc .vimperatorrc .xinitrc .yaourtrc
  .tmux.conf .vimrc .Xmodmap .ctags .gvimrc .pryrc 
  .config/awesome/rc.lua .config/fontconfig/fonts.conf .config/peco/config.json
  .bundle/config
  .vim/after
  .vim/colors
].each do |file|
  unless File.exists?(File.expand_path("~/#{file}"))
    exec("ln -s ~/dotfiles/#{file} ~/#{file}")
  end
end

is_arch = File.exists?('/etc/pacman.conf')
exec('sudo pacman -S words nodejs go') if is_arch

unless File.exists?(File.expand_path("~/.gitconfig"))
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

unless File.exists?(File.expand_path("~/.zshrc"))
  exec('echo "source dotfiles/.zshrc" >> .zshrc')
end

unless Dir.exist?(File.expand_path('~/.vim/bundle/neobundle.vim'))
  exec('git clone https://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim')
end

exec('vim +NeoBunldeInstall +q')
exec('sudo npm install -g jshint bower chai jsonlint mocha mocha-phantomjs nib sinon stylus typescript typescript-tools yuidocjs')
exec('gem install refe2 rcodetools fastri bundler pry')
exec('bitclust setup --versions=2.2.0')
exec('go get github.com/motemen/ghq github.com/sona-tar/ghs github.com/motemen/github-list-starred github.com/jteeuwen/go-bindata github.com/nsf/gocode code.google.com/p/rog-go/exp/cmd/godef code.google.com/p/go.tools/cmd/goimports github.com/golang/lint/golint github.com/peco/peco')

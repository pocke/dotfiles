include_recipe '../cookbooks/ruby-trunk-build'
include_recipe '../cookbooks/pacman-syuw'

directory File.expand_path('~/.bundle')
directory File.expand_path('~/.vim/bundle')
directory File.expand_path('~/.zsh')
directory File.expand_path('~/.config/')
directory File.expand_path('~/.config/awesome/')
directory File.expand_path('~/.config/fontconfig/')
directory File.expand_path('~/.config/sakura/')
directory File.expand_path('~/.config/peco/')

if File.exist?('/etc/arch-release')
  %w[
    curl
    docker
    docker-compose
    go
    gvim
    maim
    nodejs
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    npm
    openssh
    peek
    python
    ragel
    ristretto
    ruby
    slop
    tig
    tmux
    unzip
    wget
    words
    xorg-xev
    xorg-xmodmap
    xorg-xprop
    xorg-xrandr
    xorg-xset
    xsel
    yarn
    zip
    zsh
  ].each do |pack|
    package pack do
      user 'root'
    end
  end
end

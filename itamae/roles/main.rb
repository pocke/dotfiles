include_recipe '../cookbooks/ruby-trunk-build'
include_recipe '../cookbooks/pacman-syuw'

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

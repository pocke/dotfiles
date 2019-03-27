DOTFILES_PRIVATE_PATH = File.expand_path("~/ghq/github.com/pocke/dotfiles-private")

git DOTFILES_PRIVATE_PATH do
  repository 'git@github.com:pocke/dotfiles-private.git'
end

link File.expand_path("~/.config/ptmux") do
  to File.join(DOTFILES_PRIVATE_PATH, '.config/ptmux')
end

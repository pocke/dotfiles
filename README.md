Install
========

(for arch linux)

```sh
$ cd ~
$ git clone https://github.com/pocke/dotfiles
$ for f in .gemrc .rspec .tigrc .vimperatorrc .vimshrc .xinitrc .yaourtrc .tmux.conf .vimrc .xbindkeysrc .Xmodmap ; do ; ln -s dotfiles/$f; done
$ for f in dotfiles/vim/* ; do ; ln -s dotfiles/vim/$f .vim/$f; done
$ echo 'source dotfiles/.zshrc' >> .zshrc
$ cat <<EOF > .gitconfig
[user]
  name = pocke
  email = p.ck.t22@gmail.com
[include]
  path = dotfiles/.gitconfig
[core]
  excludesfile = /home/pocke/dotfiles/.gitignore_global
EOF
```

vim
-----------

Build vim with if_lua, if_ruby and if_python.

```sh
$ cd ~
$ mkdir -p .vim/bundle/
$ git clone https://github.com/Shougo/neobundle.vim.git .vim/bundle/neobundle.vim
$ sudo pacman -S words nodejs
$ gem install refe2
$ bitclust setup --versions=2.1.0
$ vim +NeoBundleInstall
```




TODO
==========


Vim
-----------

- GVim対応
- Lazy時のComplete
- ruby_hl_lvarがめっちゃ重いので、なんとかする


Other
-------------


# Windows (WSL2) setup

Windows 側でも dotfiles の設定を使うための仕組み。リポジトリは WSL 側に clone した
1 本だけを持ち、Windows 側の `%USERPROFILE%` 配下にはそのファイルへの symlink を張る。
こうすると WSL 側で `git pull` するだけで Windows 側にも反映される。

## 前提

- `\\wsl.localhost\` 形式のパスを使うため Windows 10 21H2 / Windows 11 以降。
- symlink 作成には Windows の開発者モード有効化、または管理者権限が必要。
  設定 → プライバシーとセキュリティ → 開発者向け → 開発者モード を ON にしておくと
  管理者権限なしで実行できる。

## 使い方

PowerShell から一度だけ実行する。実行ポリシーに引っかかる場合は `-ExecutionPolicy
Bypass` を付ける。

```powershell
powershell -ExecutionPolicy Bypass -File \\wsl.localhost\Ubuntu\home\pocke\dotfiles\windows\setup.ps1
```

distro 名や Linux 側ユーザー名が違う場合は引数で渡す。

```powershell
powershell -ExecutionPolicy Bypass -File \\wsl.localhost\Ubuntu\home\pocke\dotfiles\windows\setup.ps1 -Distro Ubuntu -LinuxUser pocke
```

以降は WSL 側で `git pull` するだけ。symlink は実体ファイルを指しているので、
内容が更新されれば Windows 側でもそのまま反映される。

`%USERPROFILE%` 配下に同名の実ファイルが既にある場合は、上書きせず警告してスキップ
する。共有したいときは手動で退避してから再実行する。

## Git の設定

`.gitconfig` は symlink せず、Linux 側 (`~/.gitconfig`) と同じく include 方式で共有する。
`%USERPROFILE%\.gitconfig` (実ファイル) に以下を追記する。include した共有設定には
`pager` (Linux 専用パス) や `editor` が含まれるので、これら OS 固有のキーと
`excludesfile`・credential helper はこのファイル側で上書き・設定する。パスは
バックスラッシュのエスケープを避けるため `/` で書く。

```ini
[include]
    path = //wsl.localhost/Ubuntu/home/pocke/dotfiles/.gitconfig
[core]
    excludesfile = //wsl.localhost/Ubuntu/home/pocke/dotfiles/.gitignore_global
    pager =
    editor = <Windows で使うエディタ>
```

## 注意

- symlink のリンク先や上記の include パスは `\\wsl.localhost\...` の UNC パスなので、
  参照には WSL が起動している必要がある。アプリから開く際に WSL は自動起動する。
- 対象は Windows ネイティブアプリが読む設定のみ（`setup.ps1` の `$links` 参照）。
  `.zshrc` などの Linux 専用設定は含めていない。

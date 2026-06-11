#Requires -Version 5.1

param(
    [string]$Distro = 'Ubuntu',
    [string]$LinuxUser = 'pocke'
)

$ErrorActionPreference = 'Stop'

$repo = "\\wsl.localhost\$Distro\home\$LinuxUser\dotfiles"

if (-not (Test-Path $repo)) {
    throw "Repository not found at $repo. Start the WSL distro '$Distro' first, or pass -Distro/-LinuxUser."
}

# Configs read by Windows-native apps. Linux-only entries (.zshrc, .tmux.conf, ...) are
# intentionally omitted. .gitconfig is shared via include, not a symlink; see README.md.
$links = @(
    '.wezterm.lua',
    '.vimrc',
    '.gvimrc',
    '.ideavimrc',
    '.ctags',
    '.vim/after',
    '.vim/colors',
    '.vim/spell',
    '.claude/CLAUDE.md',
    '.claude/skills'
)

foreach ($rel in $links) {
    $sub = $rel -replace '/', '\'
    $target = Join-Path $repo $sub
    $link = Join-Path $env:USERPROFILE $sub

    if (-not (Test-Path $target)) {
        Write-Warning "Skip $rel : target $target not found"
        continue
    }

    $parent = Split-Path $link -Parent
    if (-not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    if (Test-Path $link) {
        $item = Get-Item $link -Force
        if ($item.LinkType -eq 'SymbolicLink') {
            $item.Delete()
        } else {
            Write-Warning "Skip $link : already exists and is not a symlink"
            continue
        }
    }

    New-Item -ItemType SymbolicLink -Path $link -Target $target | Out-Null
    Write-Host "Linked $link -> $target"
}

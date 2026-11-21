# dotfiles

macOS（Apple Silicon）向けの個人用設定ファイル。zsh / tmux / Vim / Git の設定と、Homebrew と mise で入れるツールの一覧を管理する。

## ファイル構成

| ファイル | 内容 | リンク先 |
|---|---|---|
| `.zshrc` | zsh の設定（zplug、プロンプト、fzf のキーバインド、mise / zoxide の有効化） | `~/.zshrc` |
| `.tmux.conf` | tmux の設定（tpm、セッションの自動復元、fzf 連携） | `~/.tmux.conf` |
| `.vimrc` / `dpp.ts` / `tomls/` | Vim の設定。プラグイン管理は dpp.vim（denops 経由で deno が必要） | `~/.vimrc` |
| `.gitconfig` / `.gitconfig.dotfiles` | Git の設定。dotfiles リポジトリでだけ個人用の名前とアドレスを使う | `~/.gitconfig` |
| `.Brewfile` | Homebrew で入れるパッケージの一覧 | `~/.Brewfile` |
| `mise/config.toml` | mise のグローバル設定（言語ランタイムと CLI のデフォルトバージョン） | `~/.config/mise/config.toml` |
| `.latexmkrc` | latexmk の設定 | `~/.latexmkrc` |
| `dotfileslink.sh` | 上の表のシンボリックリンクをまとめて張る | |
| `init_vim.sh` | dpp.vim と denops.vim の本体を `~/.cache/dpp` に clone する | |
| `tmux-new-session-fzf.sh` | tmux の `prefix + N` で使う、zoxide の履歴からディレクトリを選んで window / pane を開くスクリプト | |
| `update_vim_plugin_versions.sh` | `tomls/` の Vim プラグインのリビジョンを、安全性チェック付きで更新する | |
| `update_zplug_versions.sh` | `.zshrc` の zplug プラグインのタグを更新する | |
| `plantuml` | PlantUML で PNG を作って開くラッパー | |

`setup.sh`、`git.sh`、`zsh.sh`、`install.sh` は古いセットアップ用スクリプト。neobundle や apt 前提の処理が残っていて、そのままでは動かない部分があるので、新しい環境では下の手順を使う。

## 新しい Mac のセットアップ

```sh
# 1. Homebrew を入れる（https://brew.sh）
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"

# 2. dotfiles を clone してリンクを張る
git clone git@github.com:shivashin/dotfiles.git ~/dotfiles
~/dotfiles/dotfileslink.sh

# 3. Homebrew のパッケージを入れる
brew bundle --global

# 4. mise でランタイムと CLI を入れる
mise trust ~/dotfiles/mise/config.toml
mise install

# 5. zsh / tmux / Vim のプラグインマネージャを入れる
git clone https://github.com/zplug/zplug ~/.zplug
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
~/dotfiles/init_vim.sh
```

その後の手順:

- zsh を起動すると、zplug が足りないプラグインを入れるか聞いてくるので `y` を押す。
- tmux を起動して `prefix + I`（大文字の I）を押し、tpm のプラグインを入れる。
- Vim を起動すると dpp の状態ファイルが作られる。プラグインは `:call dpp#async_ext_action('installer', 'install')` で入れる。

## パッケージ管理の方針

ツールごとに「プロジェクトによってバージョンが変わるか」で、Homebrew と mise のどちらで管理するかを決める。

| 管理するもの | ツール | 例 |
|---|---|---|
| プロジェクトごとにバージョンを固定したい言語ランタイムと CLI | mise | ruby, node, python, terraform, protoc, buf |
| Python 製の CLI で、グローバルに 1 つあればよいもの | mise（`pipx:` 指定） | onelogin-aws-cli, cfn-lint |
| OS 寄りの CLI、ライブラリ、DB、GUI アプリ | Homebrew | jq, ripgrep, fzf, tmux, gh, mysql, redis, iTerm2 |

- rbenv、asdf、tfenv、nodenv、pyenv などの言語ごとのバージョン管理ツールは使わない。mise が `.ruby-version`、`.node-version`、`.python-version`、`.terraform-version`、`.tool-versions` を読む。
- Homebrew の Python に `pip install` しない。Python のバージョンを上げたり消したりしたときに CLI が壊れる。グローバルに使う CLI は `mise use -g pipx:<パッケージ名>` で入れる。
- deno（denops 用）、go、yarn は、プロジェクトによってバージョンが変わらないので Homebrew で入れている。

### Homebrew

```sh
brew install <名前>                  # 入れたら .Brewfile に追記する（下の dump でもよい）
brew bundle dump --global --force --no-vscode --no-go --no-cargo --no-uv --no-npm --no-krew
                                     # 今入っているものから .Brewfile を作り直す
brew bundle cleanup --global         # .Brewfile にないものを表示する（--force で削除）
```

### mise

普段は特別なコマンドは不要。`.zshrc` の `mise activate` が、プロンプトを表示するたびにカレントディレクトリの設定を読んで PATH を切り替える。`terraform plan` なども、対象のディレクトリに `cd` してから普通に実行する。

| やりたいこと | コマンド |
|---|---|
| 今のディレクトリで使われるバージョンを見る | `mise current` / `mise ls --current` |
| プロジェクトで指定されたバージョンを入れる | `mise install` |
| プロジェクトのバージョンを固定する | `mise use terraform@1.15.8`（`mise.toml` に書かれる） |
| コミットせずに自分だけ固定する | `mise use --env local terraform@1.15.8`（`mise.local.toml` に書かれる） |
| グローバルのデフォルトを変える | `mise use -g node@26`（`mise/config.toml` が更新される） |
| 一度だけ別のバージョンで実行する | `mise exec node@20 -- node -v` |
| 設定の範囲内で新しいバージョンがあるか見る | `mise outdated` |
| 範囲を超えた新しいバージョンも見る | `mise outdated --bump` |

バージョンを上げるときの注意:

- `mise upgrade` は、新しいバージョンを入れると同時に古いバージョンを削除する。古いバージョンをプロジェクトが使っていることがあるので、`mise install <ツール>@<バージョン>` で新しいものを追加し、古いものは `mise uninstall` で個別に消す方が安全。
- `mise prune` は、mise が一度読んだことのある設定ファイルしか考慮しない。まだ入ったことのないプロジェクトが使うバージョンも削除候補に出るので、`--dry-run` で確認してから使う。
- `pipx:cfn-lint = "latest"` は自動では上がらない。ときどき `mise upgrade pipx:cfn-lint` を実行する。
- 初めて入るプロジェクトに `mise.toml` があると、`mise trust` を求められる。中身を確認してから実行する。
- cron や `bash -c` で起動するスクリプトなど、`.zshrc` を読まない環境では mise のツールが見えない。`mise exec -- <コマンド>` で実行するか、`~/.local/share/mise/shims` を PATH に入れる。

## Git

- 名前とアドレスは、普段は会社用（`.gitconfig` の `[user]`）を使う。
- `~/dotfiles` の中でだけ、`includeIf "gitdir:~/dotfiles/"` で `.gitconfig.dotfiles` の個人用の名前とアドレスに切り替わる。
- 確認は `git config user.email`。

## キーバインド

### zsh

| キー | 動作 |
|---|---|
| `Ctrl-r` | fzf でコマンド履歴を検索する |
| `Ctrl-q` | fzf で最近移動したディレクトリを選んで `cd` する |

### tmux（prefix は `Ctrl-a`）

| キー | 動作 |
|---|---|
| `prefix + \|` / `prefix + -` | pane を縦 / 横に分割する |
| `prefix + h/j/k/l` | pane を移動する |
| `prefix + H/J/K/L` | pane の大きさを変える |
| `prefix + Ctrl-h` / `Ctrl-l` | 前 / 次の window に移る |
| `prefix + N` | zoxide の履歴からディレクトリを選び、`Enter` で新しい window、`Ctrl-h/j/k/l` でその方向に pane を開く |
| `prefix + Space` | fzf で pane を選んで移動する |
| `prefix + r` | `.tmux.conf` を読み直す |

tmux のセッションは、tmux-resurrect と tmux-continuum で自動的に保存・復元される。

## プラグインの更新

```sh
~/dotfiles/update_zplug_versions.sh           # リリースから 30 日以上たったタグだけを対象にする
~/dotfiles/update_zplug_versions.sh 14        # 14 日以上に変える
~/dotfiles/update_vim_plugin_versions.sh      # 全プラグインを確認し、更新ごとに確認を求める
~/dotfiles/update_vim_plugin_versions.sh -d 14 Shougo/ddc.vim
```

どちらも、公開から一定の日数がたったリビジョンだけを対象にする。Vim 側は、差分に `curl` や `eval` などの怪しいパターンがないかも確認する。

## 既知の注意点

- Rancher Desktop は、`.zshrc` の `MANAGED BY RANCHER DESKTOP` ブロックを書き換えることがある。`$HOME/.rd/bin` が `/Users/<ユーザー名>/.rd/bin` に戻っていたら、コミット前に直す。
- onelogin-aws-cli 0.1.19 は、新しい setuptools から消えた `pkg_resources` を使う。そのため `mise/config.toml` で `setuptools<81` を一緒に入れている。実行時に出る `pkg_resources is deprecated` の警告は無視してよい。
- Homebrew の `zplug` も `.Brewfile` に入っているが、`.zshrc` が読み込むのは `~/.zplug` に clone したもの。

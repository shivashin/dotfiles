# dotfiles

macOS（Apple Silicon）と Linux（apt / dnf）で使う個人用の設定ファイル。zsh / tmux / Vim / Git の設定と、Homebrew と mise で入れるツールの一覧を管理する。

## ファイル構成

| ファイル | 内容 | リンク先 |
|---|---|---|
| `.zshrc` | `zsh/*.zsh` をファイル名の順に読み込むだけのファイル | `~/.zshrc` |
| `zsh/` | zsh の設定を役割ごとに分けたもの（下の「zsh の設定」を参照） | |
| `sheldon/plugins.toml` | zsh のプラグイン（sheldon） | `~/.config/sheldon/plugins.toml` |
| `.tmux.conf` | tmux の設定（tpm、セッションの自動復元、fzf 連携） | `~/.tmux.conf` |
| `.vimrc` / `dpp.ts` / `tomls/` | Vim の設定。プラグイン管理は dpp.vim（denops 経由で deno が必要） | `~/.vimrc` |
| `.gitconfig` / `.gitconfig.dotfiles` | Git の設定。dotfiles リポジトリでだけ個人用の名前とアドレスを使う | `~/.gitconfig` |
| `.Brewfile` | Homebrew で入れるパッケージの一覧 | `~/.Brewfile` |
| `mise/config.toml` | mise のグローバル設定（言語ランタイムと CLI のデフォルトバージョン） | `~/.config/mise/config.toml` |
| `mise/linux.toml` | Linux でだけ mise で入れるツール（fzf, ripgrep, zoxide, uv, deno, gitleaks, sheldon） | `~/.config/mise/conf.d/linux.toml`（Linux のみ） |
| `.latexmkrc` | latexmk の設定 | `~/.latexmkrc` |
| `setup.sh` | セットアップ全体を行う。OS を判定して必要なものを入れる | |
| `dotfileslink.sh` | 上の表のシンボリックリンクをまとめて張る（`setup.sh` から呼ばれる）。リンク先に実体のファイルがあれば `<名前>.bak.<日時>` に退避してから張る | |
| `init_vim.sh` | dpp.vim と denops.vim の本体を `~/.cache/dpp` に clone する（`setup.sh` から呼ばれる） | |
| `tmux-new-session-fzf.sh` | tmux の `prefix + N` で使う、zoxide の履歴からディレクトリを選んで window / pane を開くスクリプト | |
| `update_vim_plugin_versions.sh` | `tomls/` の Vim プラグインのリビジョンを、安全性チェック付きで更新する | |
| `update_zsh_plugin_versions.sh` | `sheldon/plugins.toml` の zsh プラグインのタグを更新する | |
| `plantuml` | PlantUML で PNG を作って開くラッパー | |
| `.githooks/pre-commit` | コミットする変更に秘密情報がないかを gitleaks で調べる | `setup.sh` が `core.hooksPath` に設定する |

## セットアップ

```sh
git clone https://github.com/shivashin/dotfiles.git ~/dotfiles
~/dotfiles/setup.sh
```

`setup.sh` は OS を判定して、次の処理を行う。何度実行してもよく、すでに入っているものはスキップする。

| 手順 | macOS | Linux（apt / dnf） |
|---|---|---|
| パッケージ | Homebrew を入れ、`brew bundle --global --no-upgrade` で `.Brewfile` のものを入れる | apt / dnf で git, zsh, tmux, vim, tree などを入れる |
| シンボリックリンク | `dotfileslink.sh` | `dotfileslink.sh`（`mise/linux.toml` もリンクする） |
| mise | Homebrew で入る | 公式のインストーラ（`https://mise.run`）で `~/.local/bin` に入れる |
| ランタイムと CLI | `mise install` | `mise install`（fzf, ripgrep, zoxide, uv, deno も入る） |
| zsh のプラグイン | `sheldon lock` で取得する | `sheldon lock` で取得する |
| tpm / dpp.vim | clone する | clone する |
| Powerline フォント | 入れる | 入れない（手元のターミナル側で必要なもの） |

- dotfiles は `~/dotfiles` に clone する必要がある。ほかの場所だと `setup.sh` はエラーで止まる。
- Linux では、root 以外で実行すると sudo を使う。
- Amazon Linux 2023 は `curl-minimal` が入っていて、`curl` を入れると衝突するので、`curl` コマンドがあれば入れない。
- Ubuntu 24.04 と Amazon Linux 2023 では、CI で毎回動作を確認している（下の「CI」を参照）。

実行後の手順:

- ログインシェルを zsh に変える（`chsh -s "$(command -v zsh)"`）。`setup.sh` が必要なときに表示する。
- tmux を起動して `prefix + I`（大文字の I）を押し、tpm のプラグインを入れる。
- Vim を起動すると dpp の状態ファイルが作られる。プラグインは `:call dpp#async_ext_action('installer', 'install')` で入れる。

`.zshrc` と `.tmux.conf` は OS を判定して設定を切り替える。

- `.zshrc`: Homebrew、mysql のパス、`LESSOPEN` は macOS のときだけ設定する。`LANG` は `ja_JP.UTF-8` があればそれを、なければ `C.UTF-8` を使う。
- `.tmux.conf`: コピーモードでコピーした内容を、macOS では `pbcopy` に渡す。Linux では OSC 52（端末にクリップボードの操作を頼むエスケープシーケンス）で外側のターミナルに送るので、SSH 先の tmux でコピーしても手元の Mac のクリップボードに入る。iTerm2 では、設定の General > Selection にある「Applications in terminal may access clipboard」を有効にする。

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

## zsh の設定

`~/.zshrc` は `~/dotfiles/zsh/*.zsh` をファイル名の順に読み込む。設定を足すときは、役割に合うファイルに書く。

| ファイル | 内容 |
|---|---|
| `00-env.zsh` | 言語、OS ごとの設定（Homebrew など）、環境変数、mise の有効化 |
| `10-history.zsh` | 履歴 |
| `20-options.zsh` | ディレクトリ移動、グロブ、入出力、キーバインド（vi モード）などのオプション |
| `30-completion.zsh` | 補完の設定（`compinit` は sheldon で実行する） |
| `40-prompt.zsh` | プロンプト |
| `50-aliases.zsh` | alias と関数 |
| `60-plugins.zsh` | sheldon でプラグインを読み込む |
| `70-tools.zsh` | fzf のキーバインド、cdr、Rancher Desktop と npm の PATH、zoxide |

プラグインは `sheldon/plugins.toml` に書いた順に読み込む。

| プラグイン | 内容 |
|---|---|
| zsh-completions | zsh 標準にないコマンドの補完の定義を足す。このあとで `compinit` を実行する |
| fzf-tab | Tab 補完の候補を fzf で選ぶ。`compinit` のあと、zsh-autosuggestions より前に読み込む必要がある |
| anyframe | fzf などで履歴やディレクトリを選ぶための部品（今はキーに割り当てていない） |
| zsh-autosuggestions | 過去に打ったコマンドを、入力中に灰色の候補として出す。`→` で確定する |
| zsh-syntax-highlighting | 入力中のコマンドに色を付ける（存在するコマンドは緑、存在しないものは赤） |
| zsh-history-substring-search | 入力した文字を含む履歴をたどる。zsh-syntax-highlighting のあとに読み込む必要がある |

## Git

- 普段使う名前とアドレスは `~/.gitconfig.local` に書き、`.gitconfig` の `[include]` で読み込む。会社の情報を公開リポジトリに入れないため、このファイルは dotfiles に入れない。`setup.sh` は、このファイルがなければ作り方を表示する。
- `~/dotfiles` の中でだけ、`includeIf "gitdir:~/dotfiles/"` で `.gitconfig.dotfiles` の個人用の名前とアドレスに切り替わる。`~/.gitconfig.local` より後に読み込むので、こちらが優先される。
- 確認は `git config user.email`。

## キーバインド

### zsh

| キー | 動作 |
|---|---|
| `Ctrl-r` | fzf でコマンド履歴を検索する |
| `Ctrl-q` | fzf で最近移動したディレクトリを選んで `cd` する |
| `Tab` | 補完の候補を fzf で選ぶ（fzf-tab）。`<` / `>` で候補のグループを切り替える。`cd` ではディレクトリの中身をプレビューする |
| `↑` / `↓`（ノーマルモードでは `k` / `j`） | 入力した文字を含む履歴をたどる（zsh-history-substring-search） |

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
~/dotfiles/update_zsh_plugin_versions.sh      # リリースから 30 日以上たったタグだけを対象にする
~/dotfiles/update_zsh_plugin_versions.sh 14   # 14 日以上に変える
sheldon lock --update                         # 更新した plugins.toml のとおりにプラグインを取り直す
~/dotfiles/update_vim_plugin_versions.sh      # 全プラグインを確認し、更新ごとに確認を求める
~/dotfiles/update_vim_plugin_versions.sh -d 14 Shougo/ddc.vim
```

どちらも、公開から一定の日数がたったリビジョンだけを対象にする。Vim 側は、差分に `curl` や `eval` などの怪しいパターンがないかも確認する。

## CI

GitHub Actions（`.github/workflows/ci.yml`）で、PR と `master` への push のたびに次を確認する。

| ジョブ | 内容 |
|---|---|
| `lint` | Linux で shellcheck、`zsh -n .zshrc`、tmux による `.tmux.conf` の文法チェック |
| `lint-macos` | macOS で `bash -n`、`zsh -n .zshrc`、`.tmux.conf` の文法チェック。`.Brewfile` の tap / formula / cask が Homebrew でまだ配布されているかも調べる（インストールはしない） |
| `actions-lint` | actionlint で workflow の文法を、zizmor で workflow のセキュリティ（権限の与えすぎ、`${{ }}` の埋め込みによるコマンドの注入など）を調べる |
| `gitleaks` | 履歴全体に秘密情報（アクセスキー、トークン、秘密鍵など）がないかを調べる |
| `setup-linux` | Ubuntu 24.04 と Amazon Linux 2023 のコンテナで `setup.sh` を 2 回実行し、zsh と tmux がエラーなく起動すること、mise で入れたツールが使えることを確認する |

macOS では `setup.sh` を実行しない。`.Brewfile` の cask まで全部入れると時間がかかりすぎるため。

`setup-linux` は、手元でも Docker で同じように実行できる。

```sh
docker run --rm -v "$PWD":/src:ro ubuntu:24.04 bash /src/.github/scripts/test-setup-linux.sh
docker run --rm -v "$PWD":/src:ro amazonlinux:2023 bash /src/.github/scripts/test-setup-linux.sh
```

Rancher Desktop の VM からは macOS の `/tmp` が見えないので、マウントするディレクトリはホーム配下に置く。

workflow で使う action は commit SHA で固定している。Dependabot（`.github/dependabot.yml`）が毎週、新しいバージョンへ上げる PR を作る。公開から 7 日たっていないバージョンは対象にしない。

actionlint は GitHub Action として配布されていないので、Dependabot では上がらない。`ci.yml` の `ACTIONLINT_VERSION` と `ACTIONLINT_SHA256`（リリースの `actionlint_<version>_checksums.txt` にある `linux_amd64` の値）を手で更新する。

`.Brewfile` の確認は手元でも実行できる（`.github/scripts/check-brewfile.sh .Brewfile`）。非推奨（deprecated）の formula は警告だけで、無効（disabled）になったものや見つからないものがあると失敗する。

## 秘密情報のチェック

公開リポジトリなので、秘密情報は push する前に止める。

- `setup.sh` が `git config core.hooksPath .githooks` を設定し、コミットのたびに `.githooks/pre-commit` が gitleaks で、コミットする変更を調べる。見つかるとコミットが止まる。
- gitleaks の標準のルールに加えて、`~/.config/gitleaks/dotfiles-private.toml` があれば、そのルールでも調べる。会社名やアカウント ID のように、公開リポジトリに書きたくない文字列はこのファイルに書く。このファイルは dotfiles に入れない。
- 誤検出でコミットを止められたときは、内容を確認してから `git commit --no-verify` で通す。
- CI の `gitleaks` ジョブは標準のルールだけで調べる。手元のルールは CI では使えない。

手元のルールファイルの例:

```toml
[[rules]]
id = "company-identifier"
regex = '''(?i)(?:^|[^a-z])(会社名|プロジェクト名)(?:[^a-z]|$)'''

[[rules]]
id = "aws-account-id"
regex = '''\b[0-9]{12}\b'''
```

## 既知の注意点

- Rancher Desktop の PATH 管理は手動にしている（`rdctl set --application.path-management-strategy manual`）。`~/.rd/bin` は `.zshrc` で自分で PATH に入れている。自動（`rcfiles`）に戻すと、Rancher Desktop が `.zshrc` に管理ブロックを書き込み、`$HOME` を絶対パスに書き換えるので注意する。
- onelogin-aws-cli 0.1.19 は、新しい setuptools から消えた `pkg_resources` を使う。そのため `mise/config.toml` で `setuptools<81` を一緒に入れている。実行時に出る `pkg_resources is deprecated` の警告は無視してよい。

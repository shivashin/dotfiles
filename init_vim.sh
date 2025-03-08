mkdir -p ~/.cache/dpp/repos/github.com/
cd ~/.cache/dpp/repos/github.com/

directories=(
  "Shougo"
  "vim-denops"
)
for directory in "${directories[@]}" ; do
  mkdir -p ${directory}
done

cd ./Shougo
shougo_items=(
  "dpp.vim"
  "dpp-ext-installer"
  "dpp-protocol-git"
  "dpp-ext-lazy"
  "dpp-ext-toml"
)

for item in "${shougo_items[@]}" ; do
  if [ ! -d ${item} ]; then
    git clone https://github.com/Shougo/${item}
  fi
done

cd ../vim-denops
if [ ! -d denops.vim ]; then
  git clone https://github.com/vim-denops/denops.vim
fi

git clone https://github.com/llvm/llvm-project.git
git tag
git switch --detach #最新のバージョン
mkdir build && cd build
cmake ../llvm -dCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra"
sudo cmake --build . --target install # -jはOOMKillerに殺されない程度に
# cmake -Dcmake_install_prefix=/path/to/if/you/need -P cmake_install.cmake

# tree-sitter
curl -sLO https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-x64.gz
gunzip tree-sitter-linux-x64.gz
chmod +x tree-sitter-linux-x64
sudo mv tree-sitter-linux-x64 /usr/local/bin/tree-sitter

# efm-langserver
curl -sLO https://github.com/mattn/efm-langserver/releases/latest/download/efm-langserver_v0.0.56_linux_amd64.tar.gz
tar -xvf efm-langserver_v0.0.56_linux_amd64.tar.gz
mv efm-langserver_v0.0.56_linux_amd64/efm-langserver ~/.local/bin/

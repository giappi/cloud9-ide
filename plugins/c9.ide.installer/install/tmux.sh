
VERSION_LIBEVENT="2.1.8"
VERSION_LIBNCURSE="6.0"
VERSION_TMUX="1.9"
FILE_LIBEVENT_NAME="libevent-${VERSION_LIBEVENT}-stable"
FILE_LIBNCURSE_NAME="ncurses-${VERSION_LIBNCURSE}"
FILE_TMUX_NAME="tmux-${VERSION_TMUX}"
FILE_LIB_EXT="tar.gz"
FILE_LIBEVENT="${FILE_LIBEVENT_NAME}.${FILE_LIB_EXT}"
FILE_LIBNCURSE="${FILE_LIBNCURSE_NAME}.${FILE_LIB_EXT}"
FILE_TMUX="${FILE_TMUX_NAME}.${FILE_LIB_EXT}"

set -e

has() {
  type "$1" > /dev/null 2>&1
  return $?
}

if has "wget"; then
    DOWNLOAD="wget --no-check-certificate -nc"
elif has "curl"; then
    DOWNLOAD="curl -sSOL"
else
    echo "Error: you need curl or wget to proceed" >&2;
    exit 1
fi

C9_DIR="$HOME/.c10";

if [ -z "$1" ]; then
    echo "\\1 is empty.";
else
    C9_DIR="$1/.c10";
    echo "C9_DIR == '${C9_DIR}'";
fi;

mkdir -p "$C9_DIR"
cd "$C9_DIR"
PATH="$C9_DIR/node/bin/:$C9_DIR/node_modules/.bin:$PATH";

compile_tmux(){

  cd "$C9_DIR"
  echo "::Compiling libevent..."
  tar xzf "${FILE_LIBEVENT}";
  #rm "${FILE_LIBEVENT}";
  cd "${FILE_LIBEVENT_NAME}";
  echo "::Configuring Libevent"
  ./configure --disable-shared --prefix="$C9_DIR/local"
  echo "::Compiling Libevent"
  make
  echo "::Installing libevent"
  make install
 
  cd "$C9_DIR"
  echo ":: Compiling ncurses..."
  tar xzf "${FILE_LIBNCURSE}";
  #rm "${FILE_LIBNCURSE}";
  cd "${FILE_LIBNCURSE_NAME}";
  echo ":: Configuring Ncurses"
  CPPFLAGS=-P ./configure --prefix="$C9_DIR/local" --without-tests --without-cxx
  echo ":: Compiling Ncurses"
  make
  echo ":: Installing Ncurses"
  make install
 
  cd "$C9_DIR"
  echo ":: Compiling tmux..."
  tar xzf "${FILE_TMUX}";
  #rm "${FILE_TMUX_NAME}";
  cd "${FILE_TMUX_NAME}";
  echo ":: Configuring Tmux"
  ./configure CFLAGS="-I$C9_DIR/local/include -I$C9_DIR/local/include/ncurses" LDFLAGS="-static-libgcc -L$C9_DIR/local/lib" --prefix="$C9_DIR/local"
  echo ":: Compiling Tmux"
  make
  echo ":: Installing Tmux"
  make install
}

tmux_download()
{
  echo "Downloading tmux source code"
  echo "N.B: This will take a while. To speed this up install ${FILE_TMUX_NAME} manually on your machine and restart this process."
  
  echo "Downloading Libevent..."
  $DOWNLOAD "https://raw.githubusercontent.com/c9/install/master/packages/tmux/${FILE_LIBEVENT}"
  echo "Downloading Ncurses..."
  $DOWNLOAD "https://raw.githubusercontent.com/c9/install/master/packages/tmux/${FILE_LIBNCURSE}"
  echo "Downloading Tmux..."
  $DOWNLOAD "https://github.com/tmux/tmux/releases/download/${VERSION_TMUX}/${FILE_TMUX}"
}

check_tmux_version(){
  if [ ! -x $1 ]; then
    return 1
  fi
  tmux_version=$($1 -V | sed -e's/^[a-z0-9.-]* //g')
  if [ ! "$tmux_version" ]; then
    return 1
  fi

  if [ "$(node -e "console.log(1.7<=$tmux_version)")" == "true"  ]; then
    return 0
  else
    return 1
  fi
}

mkdir -p "$C9_DIR/bin"

if check_tmux_version $C9_DIR/bin/tmux; then
  echo 'Existing tmux version is up-to-date'

# If we can support tmux 1.9 or detect upgrades, the following would work:
elif has "tmux" && check_tmux_version `which tmux`; then
  echo 'A good version of tmux was found, creating a symlink'
  ln -sf $(which tmux) "$C9_DIR"/bin/tmux

# If tmux is not present or at the wrong version, we will install it
else
  if [ $os = "darwin" ]; then
    if ! has "brew"; then
      ruby -e "$($DOWNLOAD https://raw.githubusercontent.com/mxcl/homebrew/go/install)"
    fi
    brew install tmux > /dev/null ||
      (brew remove tmux &>/dev/null && brew install tmux >/dev/null)
    ln -sf $(which tmux) "$C9_DIR"/bin/tmux
  # Linux
  else
    if ! has "make"; then
      echo "Could not find make. Please install make and try again."
      exit 100;
    fi
  
    tmux_download  
    compile_tmux
    ln -sf "$C9_DIR"/local/bin/tmux "$C9_DIR"/bin/tmux
  fi
fi

if ! check_tmux_version "$C9_DIR"/bin/tmux; then
  echo "Installed tmux does not appear to work:"
  exit 100
fi

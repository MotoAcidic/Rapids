sudo git stash && sudo git pull && 
cd depends && 
sudo make HOST=x86_64-w64-mingw32 && cd .. && 
sudo ./autogen.sh && 
sudo CONFIG_SITE=$PWD/depends/x86_64-w64-mingw32/share/config.site ./configure --prefix=/ --disable-tests --disable-online-rust && 
sudo make
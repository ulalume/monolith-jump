### Modules
- [kikito/anim8](https://github.com/kikito/anim8)
- [vrld/HC](https://github.com/vrld/HC)
  https://hc.readthedocs.io/en/latest/
- [vrld/suit](https://github.com/vrld/SUIT)
  http://suit.readthedocs.org/en/latest/

```bash
set LUA_MODULE_PATH lua_modules/share/lua/5.1

# anim8
curl https://raw.githubusercontent.com/kikito/anim8/master/anim8.lua > "$LUA_MODULE_PATH/anim8.lua"

# HC
luarocks install hc --tree=lua_modules --lua-dir=/usr/local/opt/lua@5.1

# suit
set temp suit-0.1-1.rockspec
curl https://raw.githubusercontent.com/vrld/suit/master/suit-0.1-1.rockspec > $temp
luarocks install $temp --tree=lua_modules --lua-dir=/usr/local/opt/lua@5.1
rm $temp

```

### monolith libraries
```bash
# led matrix
luarocks install https://github.com/hnd2/MONOLITH/releases/download/v0.0.1/monolith-dev-1.rockspec --tree=lua_modules --lua-dir=/usr/local/opt/lua@5.1

# music
luarocks install https://github.com/ulalume/monolith-music/releases/download/v0.1/music-dev-1.rockspec --tree=lua_modules --lua-dir=/usr/local/opt/lua@5.1

# graphics
luarocks install https://github.com/ulalume/monolith-graphics/releases/download/v0.1/graphics-dev-1.rockspec --tree=lua_modules --lua-dir=/usr/local/opt/lua@5.1

# util
luarocks install https://github.com/ulalume/monolith-util/releases/download/v0.1/util-dev-1.rockspec --tree=lua_modules --lua-dir=/usr/local/opt/lua@5.1
```

### 3rd party
```bash
# json
luarocks install rxi-json-lua  --tree=lua_modules --lua-dir=/usr/local/opt/lua@5.1
```

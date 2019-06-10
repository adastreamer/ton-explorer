# SETUP

```
opm --cwd install bungle/lua-resty-template
opm --cwd install ledgetech/lua-resty-http
```

# RUN WEB

```
LUA_PATH=";;./?.lua;./resty_modules/lualib/?.lua" nginx -p `pwd`/ -c conf/nginx.conf
```

# SETUP DATABASE

```
CREATE DATABASE ton;
CREATE USER 'ton'@'localhost' IDENTIFIED BY 'ton';
GRANT ALL PRIVILEGES ON * . * TO 'ton'@'localhost';
```

# RUN SCRIPTS

```
LUA_PATH=";;./?.lua;./resty_modules/lualib/?.lua" resty ./scripts/parse.lua
```
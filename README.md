# SETUP

```
opm --cwd install bungle/lua-resty-template
opm --cwd install ledgetech/lua-resty-http
```

# RUN

```
LUA_PATH="./?.lua;./resty_modules/lualib/?.lua" nginx -p `pwd`/ -c conf/nginx.conf
```
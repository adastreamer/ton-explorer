local http 	= require "resty.http"
local mysql = require "resty.mysql"
local json	= require "utils.json"
local cjson = require "cjson"

local httpc = http.new()
local db 	= mysql:new()

local ok, err, errcode, sqlstate = db:connect({
   host = "127.0.0.1",
  port = 3306,
  database = "ton",
  user = "ton",
  password = "ton"})

local function init_db()
  local res, err, errcode, sqlstate = db:query("drop table ton.blocks;")
  if not res then
    print(ngx.ERR, "bad result #1: ", err, ": ", errcode, ": ", sqlstate, ".")
  end
  res, err, errcode, sqlstate = db:query("create table ton.blocks( at BIGINT, lt1 BIGINT, lt2 BIGINT, header VARCHAR(255) UNIQUE PRIMARY KEY, content TEXT(65535), INDEX (at, lt1, lt2, header) );")
  if not res then
    print(ngx.ERR, "bad result #2: ", err, ": ", errcode, ": ", sqlstate, ".")
  end
end

local function get_block(block_id)
  local res, err = httpc:request_uri("http://127.0.0.1:8000/getblock/" .. block_id, { method = "GET" })
  local data = res.body
  -- local data_value = string.match(data, 'amount:.var_uint%s*len:(%d+)%s*value:(%d+)..')
  local at, lt1, lt2 = string.match(data, "block header.+" .. block_id:gsub("%(", "%%%("):gsub("%)", "%%%)") .. " @ (%d+) lt (%d+) .. (%d+)")
  local res, err, errcode, sqlstate = db:query("insert into ton.blocks (at, lt1, lt2, header, content) values ('"..at.."','"..lt1.."','"..lt2.."','"..block_id.."','"..data.."');")
  local previous_block_id = string.match(data, "previous block #.+: (.+)\n")

  res, err, errcode, sqlstate = db:query("select count(*) as count from ton.blocks where (header=\""..previous_block_id.."\");")

  if (res[1].count == "0") then
    return get_block(previous_block_id)
  else
  	print("Block already exists, doing nothing")
  end
end

local function get_from_last()
  local res, err = httpc:request_uri("http://127.0.0.1:8000/last", { method = "GET" })
  local json_body = json.decode(res.body)
  local block_id = json_body.result
  get_block(block_id)
end

-- init_db()

while true do
  local status, result = pcall(get_from_last)
  print(result)
  os.execute("sleep 1")
end

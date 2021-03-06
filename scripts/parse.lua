local http 	= require "resty.http"
local mysql = require "resty.mysql"
local json	= require "utils.json"
local cjson = require "cjson"

local httpc = http.new()
local db 	= mysql:new()

local ok, err, errcode, sqlstate = db:connect({ host = "127.0.0.1", port = 3306, database = "ton", user = "ton", password = "ton"})

local function init_db()
  local res, err, errcode, sqlstate = db:query("drop table ton.blocks;")
  if not res then
    print(ngx.ERR, "bad result #1: ", err, ": ", errcode, ": ", sqlstate, ".")
  end
  res, err, errcode, sqlstate = db:query("create table ton.blocks( at BIGINT, lt1 BIGINT, lt2 BIGINT, header VARCHAR(255) UNIQUE PRIMARY KEY, content TEXT(65535), INDEX (at, lt1, lt2, header), FULLTEXT KEY ft_header (header), FULLTEXT KEY ft_content (content), FULLTEXT KEY ft_full (header, content) );")
  if not res then
    print(ngx.ERR, "bad result #2: ", err, ": ", errcode, ": ", sqlstate, ".")
  end
end

local function get_block(block_id)
  local http_res, http_err = httpc:request_uri("http://127.0.0.1:8000/getblock/" .. block_id, { method = "GET" })
  local json_body = json.decode(http_res.body)
  local result = json_body.result
  local data = result.block .. result.header .. result.vm
  local at, lt1, lt2 = string.match(data, "block header.+" .. block_id:gsub("%(", "%%%("):gsub("%)", "%%%)") .. " @ (%d+) lt (%d+) .. (%d+)")
  local res, err, errcode, sqlstate = db:query("insert into ton.blocks (at, lt1, lt2, header, content) values ('"..at.."','"..lt1.."','"..lt2.."','"..block_id.."','"..data.."');")
  if res then
    print("Parsed ", block_id)
  end

  local previous_block_id = string.match(result.header, "previous block #.+: (.+)\n")

  res, err, errcode, sqlstate = db:query("select count(*) as count from ton.blocks where (header=\""..previous_block_id.."\");")

  if (res[1].count == "0") then
    return get_block(previous_block_id)
  else
  	return
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
  os.execute("sleep 1")
end

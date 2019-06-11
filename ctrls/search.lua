require "ctrls._common"

local template	= require "resty.template"
local http 		= require "resty.http"
local mysql 	= require "resty.mysql"
local json		= require "utils.json"
local cjson		= require "cjson"

local httpc = http.new()
local db 	= mysql:new()

local ok, err, errcode, sqlstate = db:connect({ host = "127.0.0.1", port = 3306, database = "ton", user = "ton", password = "ton"})

-- GET TIME
res, err = httpc:request_uri("http://127.0.0.1:8000/time", { method = "GET" })
json_body = json.decode(res.body)

try {
  function()
    time = os.date('%Y-%m-%d %H:%M:%S', json_body.result)
  end,
catch {
  function(error)
    time = "ERROR GETTING TIME"
  end
} }
--

-- GET Q
ngx.req.read_body()
local args, err = ngx.req.get_uri_args()

local q = args["q"]
if not q then
  q = ""
end

local page = args["page"]
if page then
  page = tonumber(page)
else
  page = 0
end
local limit = 10
--

-- query = "select at, header, content from ton.blocks where content LIKE ('%"..q.."%') ORDER BY `at` DESC LIMIT "..limit.." OFFSET "..(page * limit)..";"
query = "select at, header, content from ton.blocks where MATCH(content) AGAINST ('"..q.."') LIMIT "..limit.." OFFSET "..(page * limit)..";"
res, err, errcode, sqlstate = db:query(query)

data = {
  time = time,
  q = q,
  page = page,
  res = res
}

template.render("search.html", data)

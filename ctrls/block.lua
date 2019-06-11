require "ctrls._common"

local template	= require "resty.template"
local http      = require "resty.http"
local json      = require "utils.json"

local httpc = http.new()

function try_redirect_to(block)
  if (block ~= nil) then
    ngx.redirect("/block/" .. block, 302)
    ngx.exit(0)
  end
end

-- GET block
ngx.req.read_body()
local args, err = ngx.req.get_post_args()

local block = args["block"]
try_redirect_to(block)

block = string.match(ngx.var.uri, '/.+/(.+)')
--

-- ngx.say(block)

-- GET TIME
local res, err = httpc:request_uri("http://127.0.0.1:8000/time", { method = "GET" })
local json_body = json.decode(res.body)

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

if not block then
  block = ""
end

local res, err

if block then
  res, err = httpc:request_uri("http://127.0.0.1:8000/getblock/" .. block, { method = "GET" })
end

local block_data

if res then
  block_data = res.body
end

data = {
  time = time,
  block = block,
  block_data = block_data
}

template.render("block.html", data)

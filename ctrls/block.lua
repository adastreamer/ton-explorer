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

local args, err = ngx.req.get_uri_args()
local q = args["q"]
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

local json_body
local block_data
local block_vm
local block_header

if res then
  json_body = json.decode(res.body).result
  block_data = json_body.block
  block_vm = json_body.vm
  block_header = json_body.header
end


data = {
  time = time,
  block = block,
  block_data = block_data,
  block_vm = block_vm,
  block_header = block_header,
  q = q
}

template.render("block.html", data)

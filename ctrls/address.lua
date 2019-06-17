require "ctrls._common"

local template	= require "resty.template"
local http      = require "resty.http"
local json      = require "utils.json"

local httpc = http.new()

function try_redirect_to(address)
  if (address ~= nil) then
    ngx.redirect("/address/" .. address, 302)
    ngx.exit(0)
  end
end

-- GET ADDRESS
ngx.req.read_body()
local args, err = ngx.req.get_post_args()

local address = args["address"]
try_redirect_to(address)

address = string.match(ngx.var.uri, '/.+/(.+)')
--

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

res, err = httpc:request_uri("http://127.0.0.1:8000/getaccount/" .. address, { method = "GET" })
local data = res.body
local json_body = json.decode(res.body)

try {
  function()
    data_len, data_value = string.match(data, 'amount:.var_uint%s*len:(%d+)%s*value:(%d+)..')
    balance = data_value / 1000000000
  end,
catch {
  function(error)
    data_value = "ERROR GETTING DATA, TON INTERNAL SERVER ERROR"
    balance = 0
  end
} }

data = {
  time = time,
  address = address,
  data = json_body.result,
  balance = balance
}

template.render("address.html", data)

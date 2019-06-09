require "ctrls._common"

local template	= require "resty.template"
local http 		= require "resty.http"
local json		= require "utils.json"

local httpc = http.new()

res, err = httpc:request_uri("http://127.0.0.1:8000/time", { method = "GET" })
json_body = json.decode(res.body)

try {
  function()
    data = { time = os.date('%Y-%m-%d %H:%M:%S', json_body.result) }
  end,
catch {
  function(error)
    data = { time = "ERROR GETTING TIME" }
  end
} }

template.render("index.html", data)

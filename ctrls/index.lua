require "ctrls._common"

local template	= require "resty.template"
local http 		= require "resty.http"

local httpc = http.new()

res, err = httpc:request_uri("http://127.0.0.1:8000/time", { method = "GET" })

try {
  function()
    data = { time = os.date('%Y-%m-%d %H:%M:%S', res.body) }
  end,
catch {
  function(error)
    data = { time = "ERROR GETTING TIME" }
  end
} }

template.render("index.html", data)

local template	= require "resty.template"
local http 		= require "resty.http_headers"
local http 		= require "resty.http"

data = {

}

template.render("views/index.html", { message = "Hello, World!" })
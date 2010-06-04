require 'rubygems'
require 'sinatra'
require 'base64'

get '/*' do
  from_host = request.env['HTTP_HOST']
  to_host = request.env['HTTP_HOST'] =~ /(.*?\.)coopsem.com/ ? $1 : ''
  to_host << "dealerignitionapp.com"
  
  response = "http#{request.secure? ? 's' : ''}://"
  response << to_host
  response << (request.env['PATH_INFO'].empty? ? '/' : request.env['PATH_INFO'])
  response << '?'
  response << request.env['QUERY_STRING'] + '&' unless request.env['QUERY_STRING'].empty?
  response << redirect_notice(from_host, to_host)
  redirect response, 301
end

def redirect_notice(from, to)
  message = <<-MSG
You accessed this site as <strong>#{from}</strong>. The address has been changed to <strong>#{to}</strong>.
Please update any bookmarks or shortcuts you may be using.
  MSG
  "message=" + Base64.encode64([:warning, message].to_yaml).gsub("\n", '')
end

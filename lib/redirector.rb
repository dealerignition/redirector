require 'rubygems'
require 'sinatra'
require 'yaml'
require 'cgi'

get '/*' do
  from_host = request.env['HTTP_HOST']
  to_host = new_host_name
  
  response = "http#{request.secure? ? 's' : ''}://"
  response << to_host
  response << (request.env['PATH_INFO'].empty? ? '/' : request.env['PATH_INFO'])
  response << '?'
  response << request.env['QUERY_STRING'] + '&' unless request.env['QUERY_STRING'].empty?
  response << redirect_notice(from_host, to_host)
  redirect response, 301
end

def new_host_name
  if !request.env['PATH_INFO'].empty? and
      (request.env['PATH_INFO'] =~ %r{/dealer/\d+/size/\d+.js} or
       request.env['PATH_INFO'] =~ %r{/a/\d+/\d+/\d+.js})
    'diadz.com'
  else
    to_host = request.env['HTTP_HOST'] =~ /(.*?\.)coopsem.com/ ? $1 : ''
    to_host << "dealerignitionapp.com"
  end
end

def redirect_notice(from, to)
  if to !~ /diadz.com/
    message = <<-MSG
You accessed this site as <strong>#{from}</strong>. The address has been changed to <strong>#{to}</strong>.
Please update any bookmarks or shortcuts you may be using.
    MSG
    "message=" + CGI.escape([:error, message].to_yaml)
  else
    ''
  end
end

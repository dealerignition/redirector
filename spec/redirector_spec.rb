require 'rubygems'
require 'sinatra'

set :environment, :test

require File.join(File.dirname(__FILE__), '..', 'lib', 'redirector')

require 'spec'
require 'rack/test'


describe 'The Redirector App' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end
  
  context "redirecting" do
    
    it "redirect permanantly" do
      get "/", nil, http_host
      last_response.status.should == 301
    end

    it 'should redirect the base domain' do
      get "/", nil, http_host
      redirect_url.should =~ %r{^http://dealerignitionapp.com}
    end

    it 'should maintain the secure status' do
      get "/", nil, http_host.merge(secure)
      redirect_url.should =~ %r{^https://dealerignitionapp.com}
    end

    it 'should preserve the subhost' do
      get "/", nil, http_host('blah.coopsem.com')
      redirect_url.should =~ %r{^http://blah.dealerignitionapp.com}
    end

    it 'should preserve even a silly subhost' do
      get "/", nil, http_host('www.blah.coopsem.com')
      redirect_url.should =~ %r{^http://www.blah.dealerignitionapp.com}
    end

    it 'should preserve the path' do
      get "/some/path", nil, http_host
      redirect_url.should =~ %r{^http://dealerignitionapp.com/some/path}
    end

    it 'should preserve the params' do
      get "/", { 'a' => 'b', 'c' => 'd'}, http_host
      redirect_url.should =~ %r{^http://dealerignitionapp.com/\?a=b&c=d}
    end

    context 'including a flash message' do
      it 'should include a message' do
        get "/", nil, http_host
        redirect_url.should be_end_with app.send(:redirect_notice, 'coopsem.com', 'dealerignitionapp.com')
      end

      it 'should give the proper message when a sub host is set' do
        get "/", nil, http_host('blah.coopsem.com')
        redirect_url.should be_end_with app.send(:redirect_notice, 'blah.coopsem.com', 'blah.dealerignitionapp.com')
      end
    end
  end
end

def http_host(host = 'coopsem.com')
  { 'HTTP_HOST' => host }
end

def secure
  { 'HTTP_X_FORWARDED_PROTO' => 'https'}
end

def redirect_url
  last_response['Location']
end

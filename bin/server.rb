require 'sinatra'

configure do
  set :my_content, File.read('bin/content.txt')
end

get '/some_path' do
  "#{settings.my_content}"
end
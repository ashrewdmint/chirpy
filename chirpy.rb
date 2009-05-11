# Chirpy - A simple Twitter client for Ruby
#   Github:  http://github.com/ashrewdmint/chirpy/
#   
# Copyright (C) 2009 Andrew Smith
#   Email:   andrew.caleb.smith@gmail.com
#   Twitter: ashrewdmint
#   
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#  
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#  
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Example
# ashrewdmint = Chirpy.new('ashrewdmint', 'redacted')
# timeline = ashrewdmint.friends_timeline
# if timeline.ok?
#   # Do something fun here!
# else
#   puts timeline.status[:error_message]
# ends

require 'rubygems'
require 'restclient'
require 'hpricot'

# From http://www.ruby-forum.com/topic/69428
class Hash
  def to_url_params
    elements = []
    keys.size.times do |i|
      elements << "#{keys[i]}=#{values[i]}"
    end
    elements.join('&')
  end

  def from_url_params(url_params)
    result = {}.with_indifferent_access
    url_params.split('&').each do |element|
      element = element.split('=')
      result[element[0]] = element[1]
    end
    result
  end
end

class Chirpy
  @@root    = 'twitter.com/'
  @username = nil
  @password = nil
  
  def initialize(username = nil, password  = nil)
    authenticate(username, password) if username and password
  end
  
  # Authentication
  
  def authenticate(username, password)
    @username = username
    @password = password
  end
  
  def auth_supplied?
    @username and @password
  end
  
  # Timeline methods

  def public_timeline
    get "statuses/public_timeline"
  end

  def friends_timeline(params = {})
    get "statuses/friends_timeline", :url_params => params
  end

  def user_timeline(user = nil, params = {})
    if user.is_a?(Hash)
        params = user.merge(params)
        user = nil
    end
    if user
      get "statuses/user_timeline/#{user}", :url_params => params
    else
      get "statuses/user_timeline", :url_params => params
    end
  end

  def mentions(params = {})
    get "statuses/mentions", :url_params => params
  end

  # Status methods

  def show_status(status_id)
    get "statuses/show/#{status_id}", params
  end

  def update_status(status)
    post "statuses/update", :post => {:status => status}
  end

  def destroy_status(status_id)
    delete "statuses/destroy/#{status_id}"
  end

  # User methods

  def show_user(user = nil, params = {})
    if user.is_a?(Hash)
        params = user.merge(params)
        user = nil
    end
    
    path = user ? "users/show/#{user}" : "users/show"
    get path, :url_params => params
  end

  def friends(user = nil, params = {})
    if user.is_a?(Hash)
      params = user
      user = nil
    end
    
    path = user ? "statuses/friends/#{user}" : "statuses/friends"
    get path, :url_params => params
  end

  def followers(user = nil, params = {})
    if user.is_a?(Hash)
      params = user
      user = nil
    end
    
    path = user ? "statuses/followers/#{user}" : "statuses/followers"
    get path, :url_params => params
  end
  
  def direct_messages(params = {})
    get "direct_messages", :url_params => params
  end
  
  def direct_messages_sent(params = {})
    get "direct_messages/sent", :url_params => params
  end
  
  def direct_messages_new(recipient, text)
    post_params = {:user => recipient, :text => text}
    post "direct_messages/new", :post => post_params
  end
  
  # Friendship methods
  # Authentication required for all
  
  # Follow is automatically set to true!
  # To override this, call create_friendship('ashrewdmint', :follow => false)
  def create_friendship(user = nil, params = {})
    if user.is_a?(Hash)
      params = user
      user = nil
    end
    
    path = user ? "friendships/create/#{user}" : "friendships/create"
    post path, :url_params => {:follow => true}.merge(params)
  end
  
  def destroy_friendship(user, params = {})
    if user.is_a?(Hash)
      params = user
      user = nil
    end
    
    path = user ? "friendships/create/#{user}" : "friendships/create"
    delete path, :url_params => params
  end
  
  # Returns true or false
  def friendship_exists?(able, baker)
    response = get "friendships/exists", :url_params => {:user_a => able, :user_b => baker}
    if response.ok?
      response.%('friends').inner_html == 'true'
    else
      response
    end
  end
  
  # Unfinished
  
  # Social graph methods
  
  # Account methods
  
  # Favorite methods
  # The ones I like the most
  
  # Notification methods
  
  # Block methods
  
  # Help methods

private

  def get(path, params = {})
    request params.merge({:path => path})
  end

  def post(path, params = {})
    request params.merge({:path => path, :method => 'post'})
  end

  def delete(path, params = {})
    request params.merge({:path => path, :method => 'delete'})
  end

  def request(params)
    # Default parameteres
    params = {:method => 'get', :url_params => {}}.merge(params)
  
    path     = @@root + params[:path] + '.xml?' + params[:url_params].to_url_params
    user = params[:user]
    password = params[:password]

    # Simple authentication
  
    if auth_supplied?
      path = 'https://' + @username + ':' + @password + '@' + path
    else
      path = 'http://' + path
    end
  
    # Call Twitter
  
    begin
      response = case params[:method]
        when 'get' then
          RestClient.get(path)
        when 'post' then
          RestClient.post(path, params[:post])
        when 'delete' then
          RestClient.delete(path)
      end
    rescue Exception => error
      status = {:ok => false, :error_message => error.message, :exception => error.class}
    end
  
    # Parse with Hpricot and check for errors
  
    if (response)
      response = Hpricot.XML(response)
      error = response.search('error')
      if (error.length > 0)
        status = {:ok => false, :error_message => error.first.inner_html.strip}
      end
    end
  
    status = {:ok => true} unless status
    
    class << response
      attr_accessor :path, :status
      @path = nil
      @status = nil
      
      def ok?
        status[:ok]
      end
    end
    
    response.path = path
    response.status = status
    response
  end
end
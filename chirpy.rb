require 'rubygems'
require 'restclient'
require 'hpricot'

# Adds to_url_params and from_url_params methods to the Hash class.
# I found the code from: http://www.ruby-forum.com/topic/69428
class Hash
  
  # Turns a hash into URL parameters, e.g. "key=value&another_key=another_value"
  def to_url_params
    elements = []
    keys.size.times do |i|
      elements << "#{keys[i]}=#{values[i]}"
    end
    elements.join('&')
  end
  
  # Takes a string of URL parameters and turns them into a hash
  def from_url_params(url_params)
    result = {}.with_indifferent_access
    url_params.split('&').each do |element|
      element = element.split('=')
      result[element[0]] = element[1]
    end
    result
  end
end

# Chirpy is a simple Twitter client for Ruby, written using RestClient and Hpricot.

class Chirpy
  @@root    = 'twitter.com/'
  @username = nil
  @password = nil
  
  # Makes a new instance of Chirpy
  #
  # Example: <tt>chirpy = Chirpy.new('username', 'password')</tt>
  #
  # Authentication, however, is not required.
  #
  # Example: <tt>chirpy = Chirpy.new</tt>
  
  def initialize(username = nil, password  = nil)
    authenticate(username, password) if username and password
  end
  
  #-- Authentication
  
  # Tells Chirpy to use authentication.
  #
  # Example: <tt>chirpy.authenticate('username', 'password)</tt>
  
  def authenticate(username, password)
    @username = username
    @password = password
  end
  
  # Turns authentication off.
  def unauthenticate()
    @username = nil
    @password = nil
  end
  
  #-- Timeline methods
  
  # Gets the public timeline. Authentication is not required for this.
  
  def public_timeline
    get "statuses/public_timeline"
  end
  
  # Gets the authenticated user's friends' timeline.
  #
  # Example: chirpy.friends_timeline :page => 2
  #
  # Authentication required.
  
  def friends_timeline(params = {})
    get "statuses/friends_timeline", :url_params => params
  end
  
  # Gets a list of status updates from a specific user.
  # If no user is supplied, the authenticated user will be used.
  #
  # Authentication required.

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
  
  # Gets mentions for the authenticated user.
  #
  # Authentication required.

  def mentions(params = {})
    get "statuses/mentions", :url_params => params
  end

  #-- Status methods
  
  # Shows a specific tweet. Authentication is only required if author is protected.
  
  def show_status(status_id)
    get "statuses/show/#{status_id}", params
  end
  
  # Updates the status of the authenticated user.
  #
  # Authentication required, silly.

  def update_status(status)
    post "statuses/update", :post => {:status => status}
  end
  
  # Destroys one of the authenticated user's tweets.
  #
  # Authentication required.
  
  def destroy_status(status_id)
    delete "statuses/destroy/#{status_id}"
  end

  #-- User methods
  
  # Shows details for a specific user. Authentication is only required if the user is protected.
  
  def show_user(user = nil, params = {})
    if user.is_a?(Hash)
        params = user.merge(params)
        user = nil
    end
    
    path = user ? "users/show/#{user}" : "users/show"
    get path, :url_params => params
  end
  
  # Gets a list of a user's friends.
  # If no user is supplied, the authenticated user will be used.

  def friends(user = nil, params = {})
    if user.is_a?(Hash)
      params = user
      user = nil
    end
    
    path = user ? "statuses/friends/#{user}" : "statuses/friends"
    get path, :url_params => params
  end
  
  # Gets a list of a user's followers.
  # If no user is supplied, the authenticated user will be used.
  # However, you need to authenticate whether or not you supply the user parameter.
  #
  # Authentication required.

  def followers(user = nil, params = {})
    if user.is_a?(Hash)
      params = user
      user = nil
    end
    
    path = user ? "statuses/followers/#{user}" : "statuses/followers"
    get path, :url_params => params
  end
  
  # Gets a list of the messages sent to the authenticated user.
  #
  # Authentication required.
  
  def direct_messages(params = {})
    get "direct_messages", :url_params => params
  end
  
  # Gets a list of the messages sent by the authenticated user.
  #
  # Authentication required.
  
  def direct_messages_sent(params = {})
    get "direct_messages/sent", :url_params => params
  end
  
  # Sends a direct message.
  #
  # Authentication required.
  
  def direct_messages_new(recipient, text)
    post_params = {:user => recipient, :text => text}
    post "direct_messages/new", :post => post_params
  end
  
  # --Friendship methods
  
  # Follow is automatically set to true!
  # To override this, call create_friendship('ashrewdmint', :follow => false)
  #
  # Authentication required
  
  def create_friendship(user = nil, params = {})
    if user.is_a?(Hash)
      params = user
      user = nil
    end
    
    path = user ? "friendships/create/#{user}" : "friendships/create"
    post path, :url_params => {:follow => true}.merge(params)
  end
  
  # Destroys a friendship between the authenticated user and another user.
  #
  # Authentication required.
  
  def destroy_friendship(user, params = {})
    if user.is_a?(Hash)
      params = user
      user = nil
    end
    
    path = user ? "friendships/create/#{user}" : "friendships/create"
    delete path, :url_params => params
  end
  
  # Checks if a friendship exists between two users; returns true or false if no error occured.
  # If an error did occur, it returns the usual object.
  #
  # Authentication required.
  
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
  
  # Returns true if username and password have been set.
  # Returns false if otherwise.
  
  def auth_supplied?
    @username and @password
  end
  
  # Calls request. By default, request will use the get method
  
  def get(path, params = {})
    request params.merge({:path => path})
  end
  
  # Calls request with post method
  
  def post(path, params = {})
    request params.merge({:path => path, :method => 'post'})
  end

  # Calls request with delete method
  
  def delete(path, params = {})
    request params.merge({:path => path, :method => 'delete'})
  end

  # Constructs the correct url (including authentication), uses RestClient to call Twitter,
  # parses the data with Hpricot, handles errors (both from RestClient and Twitter)
  # and returns the result, for great justice!
  
  # Resulting Hpricot objects have two custom methods, "status" and "ok?"
  # Call "ok?" to check if there are errors. If there are errors, you can look inside the
  # hash returned by the "status" method, which gives you information on what went wrong.
  
  def request(params)
    # Default parameteres
    params = {:method => 'get', :url_params => {}}.merge(params)
  
    url  = @@root + params[:path] + '.xml?' + params[:url_params].to_url_params
    user = params[:user]
    password = params[:password]

    # Simple authentication
  
    if auth_supplied?
      url = 'https://' + @username + ':' + @password + '@' + url
    else
      url = 'http://' + url
    end
  
    # Call Twitter
  
    begin
      response = case params[:method]
        when 'get' then
          RestClient.get(url)
        when 'post' then
          RestClient.post(url, params[:post])
        when 'delete' then
          RestClient.delete(url)
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
    Response.new(response, url, status)
  end
end

# A simple class to wrap around an API response.
# - Data is what you got from the API
# - URL is the URL of the API method
# - Status is a hash which holds error messages, if any
#
# Use the "ok?" method to check for errors.

class Response
  attr_reader :data, :url, :status
  
  @data   = nil
  @url    = nil
  @status = nil
  
  def initialize(data, url, status)
    @data   = data
    @url    = url
    @status = status
  end
  
  # Checks if there are any errors
  
  def ok?
    status[:ok]
  end
end
require 'cgi'
require 'rubygems'
require 'restclient'
require 'hpricot'
require 'htmlentities'

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
  
  # Returns the username and password in a hash.
  
  def authentication
    {:username => @username, :password => @password}
  end

  private :authentication
  
  #-- Utility methods
  
  # Search results have bold tags and links in them. This removes it all.
  
  def self.remove_crap(string)
    remove_tags(decode_entities(string))
  end
  
  # Removes tags.
  
  def self.remove_tags(string)
    string.gsub(/<[^>]+>/, '')
  end
  
  # Decodes HTML entities.
  
  def self.decode_entities(string)
    HTMLEntities.new.decode(string)
  end
  
  #-- Search methods
  
  # Searches Twitter. Supply a query and extra options in a hash (not required).
  # Available options (go here for more details: http://apiwiki.twitter.com/Twitter-Search-API-Method)
  # - :lang
  # - :rpp
  # - :page
  # - :since_id
  # - :geocode
  
  def self.search(query, params = {})
    get "search", params.merge({:q => query})
  end
  
  #-- Timeline methods
  
  # Gets the public timeline. Authentication is not required for this.
  
  def self.public_timeline
    get "statuses/public_timeline"
  end
  
  # Instance method for public timeline
  
  def public_timeline
    Chirpy.public_timeline
  end
  
  # Gets the authenticated user's friends' timeline. Authentication required.
  #
  # Optional parameters:
  # - :since_id
  # - :max_id
  # - :count
  # - :page
  
  def friends_timeline(params = {})
    get "statuses/friends_timeline", params
  end
  
  # Gets a list of status updates from a specific user.
  # If no user is supplied, the authenticated user will be used.
  # you may supply a hash as the only argument.
  # Authentication required.
  #
  # Optional parameters:
  # - :user_id
  # - :screen_name
  # - :since_id
  # - :max_id
  # - :count
  # - :page

  def user_timeline(user = nil, params = {})
    args = [user, params]
    get path_from_args('statuses/user_timeline', args), params_from_args(args)
  end
  
  # Gets mentions for the authenticated user. Authentication required.
  #
  # Optional parameters:
  # - :since_id
  # - :max_id
  # - :count
  # - :page

  def mentions(params = {})
    get "statuses/mentions", params
  end

  #-- Status methods
  
  # Shows a specific tweet. Authentication is only required if author is protected.
  
  def show_status(status_id)
    get "statuses/show/#{status_id}"
  end
  
  # Updates the status of the authenticated user. Authentication required, silly.

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
  # you may supply a hash as the only argument.
  #
  # Optional parameters:
  # - :user_id
  # - :screen_name
  
  def show_user(user = nil, params = {})
    args = [user, params]
    get path_from_args('users/show', args), params_from_args(params)
  end
  
  # Gets a list of a user's friends.
  # If no user is supplied, the authenticated user will be used.
  # you may supply a hash as the only argument.
  #
  # Optional parameters:
  # - :user_id
  # - :screen_name
  # - :page

  def friends(user = nil, params = {})
    args = [user, params]
    get path_from_args('statuses/friends', args), params_from_args(args)
  end
  
  # Gets a list of a user's followers.
  # If no user is supplied, the authenticated user will be used.
  # However, you need to authenticate whether or not you supply the user parameter.
  # Authentication required.
  # You may supply a hash as the only argument.
  #
  # Optional parameters:
  # - :user_id
  # - :screen_name
  # - :page

  def followers(user = nil, params = {})
    args = [user, params]
    get path_from_args('statuses/followers', args), params_from_args(args)
  end
  
  # Gets a list of the messages sent to the authenticated user.
  # Authentication required.
  #
  # Optional parameters:
  # - :since_id
  # - :max_id
  # - :count
  # - :page
  
  def direct_messages(params = {})
    get "direct_messages", params
  end
  
  # Gets a list of the messages sent by the authenticated user.
  # Authentication required.
  #
  # Optional parameters:
  # - :since_id
  # - :max_id
  # - :page
  
  def direct_messages_sent(params = {})
    get "direct_messages/sent", params
  end
  
  # Sends a direct message.
  #
  # Authentication required.
  
  def direct_messages_new(recipient, text)
    post_params = {:user => recipient, :text => text}
    post "direct_messages/new", post_params
  end
  
  # Destroys a direct message.
  # 
  # Authentication required.
  
  def destroy_direct_message(direct_message_id)
    delete "direct_messages/destroy/#{direct_message_id}"
  end
  
  #-- Friendship methods
  
  # Creates a friendship between authenticated user and another user.
  # You may supply a hash as the only argument.
  # Authentication required.
  #
  # Optional parameters:
  # - :user_id
  # - :screen_name
  # - :follow (automatically set to true)
  
  def create_friendship(user = nil, params = {})
    args = [user, params]
    post path_from_args('friendships/create', args), {:follow => true}.merge(params_from_args(args))
  end
  
  # Destroys a friendship between the authenticated user and another user.
  # You may supply a hash as the only argument.
  # Authentication required.
  #
  # Optional parameters:
  # - :user_id
  # - :screen_name
  
  def destroy_friendship(user, params = {})
    args = [user, params]
    delete path_from_args('friendships/destroy', args), params_from_args(args)
  end
  
  # Checks if a friendship exists between two users; returns true or false if no error occured.
  # If an error did occur, it returns the usual object.
  #
  # Authentication required.
  
  def friendship_exists?(user_a, user_b)
    response = get "friendships/exists", {:user_a => user_a, :user_b => user_b}
    if response.ok?
      response.data.%('friends').inner_html == 'true'
    else
      response
    end
  end
  
  #-- Social graph methods
  
  # Returns ids for someone's friends. You may supply a hash as the only argument.
  #
  # Optional parameters:
  # - :user_id
  # - :screen_name
  # - :page
  
  def friends_ids(user = nil, params = {})
    args = [user, params]
    get path_from_args('friends/ids', args), params_from_args(params)
  end
  
  # Returns ids for someone's followers. You may supply a hash as the only argument.
  #
  # Optional parameters:
  # - :user_id
  # - :screen_name
  # - :page
  
  def followers_ids(user = nil, params = {})
    args = [user, params]
    get path_from_args('followers/ids', args), params_from_args(params)
  end
  
  #-- Account methods
  
  # Use this to check if a username and password are valid.
  # Returns a Chirpy instance if valid, otherwise, false.
  
  def self.verify_credentials(username, password)
    chirpy = self.new(username, password)
    chirpy.verify_credentials
  end
  
  # Use this to check if an instance's username and password are valid.
  #
  # Authentication required.
  
  def verify_credentials
    if auth_supplied?
      response = get "account/verify_credentials"
      response.ok? ? response : false
    else
      false
    end
  end
  
  # Gets information on rate limiting.
  # Specify <tt>:authenticate => false</tt> to see rate limiting for current ip
  
  def rate_limit_status(params)
    get "account/rate_limit_status", params
  end
  
  # Ends the session of the authenticated user
  
  def end_session
    post "account/end_session", :post => {}
  end
  
  # Updates the authenticated user's delivery device. Must be one of:
  # - sms
  # - im
  # - none
  
  def update_delivery_device(device)
    post "account/update_delivery_device", :post => {:device => device}
  end
  
  # Updates the authenticated user's colors (on their Twitter page).
  #
  # Please supply a hash with hexadecimal colors (e.g. "fff" or "ffffff").
  # Don't include the "#" character in front of the color code.
  # Here are the different values you can customize:
  # - :background_color
  # - :text_color
  # - :sidebar_color
  # - :sidebar_fill_color
  # - :sidebar_border_color
  
  def update_profile_colors(colors)
    return unless colors.is_a?(Hash)
    post_data = {}
    
    colors.each_pair do |key, value|
      post_data.store("profile_#{key}", value.gsub(/#/, ''))
    end
    
    post "account/update_profile_colors", :post => post_data
  end
  
  #-- TODO: update_profile_image and update_profile_background_image
  #-- Methods delayed until I can figure out how to get RestClient working with them
  
  # Updates the user's profile information. Pass in a hash with symbols as keys.
  #
  # From: http://apiwiki.twitter.com/Twitter-REST-API-Method%3A-account%C2%A0update_profile
  # - :name, 20 characters max.
  # - :email, 40 characters max. Must be a valid email address.
  # - :url, 100 characters max. Will be prepended with "http://" if not present.
  # - :location, 30 characters max. The contents are not normalized or geocoded in any way.
  # - :descriptionm 160 characters max.
  
  def update_profile(params)
    post 'account/update_profile', :post => params
  end
  
  #-- Favorite methods
  
  # Gets a list of a user's favorites.
  # You may supply a hash as the only argument.
  # Authentication required.
  #
  # Optional parameters:
  # - :id
  # - :page
  
  def favorites(user = nil, params = {})
    args = [user, params]
    get path_from_args('favorites', args), params_from_args(args)
  end
  
  # Adds a tweet to the authenticated user's favorites.
  #
  # Authentication required.
  
  def create_favorite(id)
    post "favorites/create/#{id}", {}
  end
  
  # Removes a tweet from the authenticated user's favorites
  #
  # Authentication required, Strong Bad.
  
  def destroy_favorite(id)
    delete "favorites/destroy/#{id}"
  end
  
  #-- Notification methods
  
  # Makes the authenticated user follow a new person. Authentication required.
  # Pass a username or a hash with one of the following options:
  # - :user_id
  # - :screen_name
  
  def follow(user_or_params)
    args = [user_or_params]
    post path_from_args('notifications/follow', args), params_from_args(args).merge({:post => {}})
  end

  # Unfollows a person the authenticated user is following. Authentication required.
  # Pass a username or a hash with one of the following options:
  # - :user_id
  # - :screen_name
  
  def leave(user_or_params)
    args = [user_or_params]
    post path_from_args('notifications/leave', args), params_from_args(args).merge({:post => {}})
  end
  
  #-- Block methods
  
  # Makes the authenticated user block someone.
  # Authentication required.
  
  def block(user)
    post "blocks/create/#{user}"
  end
  
  # Removes the authenticated user's block.
  # Authentication required.
  
  def destroy_block(user)
    delete "blocks/destroy/#{user}"
  end
  
  # Checks if the authenticated user is blocking someone.
  # Pass in a username or a hash with one of the following options:
  # - :user_id
  # - :screen_name
  #
  # Authentication required.
  
  def block_exists(user_or_params)
    args = [user_or_params]
    get path_from_args('block/exists', args), params_from_args(args)
  end
  
  # Returns a list of people the authenticated user is blocking.
  # You can pass :page => x if you want to.
  #
  # Authentication required.
  
  def blocking(params = {})
    get "blocks/blocking", params
  end
  
  # Returns a list of the ids of the people the authenticated user is blocking.
  #
  # Authentication required.
  
  def blocking_ids
    get "blocks/blocking/ids"
  end
  
  #-- Help methods
  
  def self.test
    get "help/test"
  end

private
  
  # Concatenates the username onto the path if the former is found in the arguments.
  
  def path_from_args(path, args)
    username = nil
    args.each { |arg| username = arg if arg.is_a?(String) }
    username ? path + "/#{username}" : path
  end
  
  # Finds and returns the hash in the arguments, or an empty hash if nothing is found.

  def params_from_args(args)
    params = {}
    args.each { |arg| params = arg if arg.is_a?(Hash) and ! arg.empty? }
    params
  end
  
  # Calls request. By default, request will use the get method
  
  def get(path, params = {})
    Chirpy.request params.merge({:path => path, :method => 'get'}.merge(authentication))
  end
  
  # Calls request with post method
  
  def post(path, params = {})
    Chirpy.request params.merge({:path => path, :method => 'post'}.merge(authentication))
  end

  # Calls request with delete method
  
  def delete(path, params = {})
    Chirpy.request params.merge({:path => path, :method => 'delete'}.merge(authentication))
  end
  
  # Class method for get
  
  def self.get(path, params = {})
    request params.merge({:path => path, :method => 'get'})
  end

  # Constructs the correct url (including authentication), uses RestClient to call Twitter,
  # parses the data with Hpricot, handles errors (both from RestClient and Twitter)
  # and returns the result, for great justice!

  # Resulting objects have three methods, "status", "ok?", and "data".
  # Call "ok?" to check if there are errors. If there are errors, you can look inside the
  # hash returned by the "status" method, which gives you information on what went wrong.
  #
  # The Hpricot object can be retreived by calling the "data" method.
  
  def self.request(params)
    params = organize_params({:authenticate => true}.merge(params))
    url    = 'twitter.com/' + params[:path] + '.xml' + params[:url_params]
    
    if url =~ /search/
      url = 'search.' + url.sub(/xml/, 'atom')
    end
    
    username = params[:username]
    password = params[:password]
    
    auth_supplied      = !! username and !! password
    use_authentication = params[:authenticate]
    
    # Simple authentication
    
    if auth_supplied and use_authentication
      url = 'https://' + username + ':' + password + '@' + url
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
      status = {:ok => false, :error_message => error.message, :error_response => error.response, :exception => error.class}
    end
  
    # Parse with Hpricot and check for errors
    
    if (response)
      response = Hpricot.XML(response, :fixup_tags => true)
      error = response.search('error')
      if (error.length > 0)
        status = {:ok => false, :error_message => error.first.inner_html.strip}
      end
    end
    
    status = {:ok => true} unless status
    prepare_response(response, url, status)
  end
  
  # Tacks on handy methods to the response.
  # The status is a hash with error messages, if anything went wrong.
  # The URL is the url requested when Twitter was called.
  # Call the "ok?" method to quickly check if there was an error.
  
  def self.prepare_response(response, url, status)
    response = Hpricot('') unless response
    
    class << response
      attr_accessor :url, :status
      
      @url    = nil
      @status = nil
      
      def ok?
        status[:ok]
      end
    end
    
    response.url    = url
    response.status = status
    response
  end

  def self.organize_params(params)
    url_params_list = [
        :id,
        :user_id,
        :screen_name,
        :page,
        :since_id,
        :max,
        :count,
        :q,
        :lang,
        :rpp,
        :geo_code,
        :show_user
    ]
    url_params = {}
    
    # Escape query
    params[:q] = CGI.escape(params[:q]) if params[:q]

    params.each_pair do |key, value|
      if url_params_list.include?(key)
        url_params.store(key, value)
        params.delete(key)
      end
    end
    
    url_params = url_params.to_url_params
    url_params = '?' + url_params unless url_params == ''
    
    params = {:method => 'get', :url_params => url_params}.merge(params)
  end
  
end
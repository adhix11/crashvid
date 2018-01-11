class HomeController < ApplicationController
  before_filter :sign_in_check,only: [:checkout,:pay,:purchases,:download_video]
  before_filter :video_purchased, only: [:download_video]
  before_filter :event_video, only: [:add_to_cart,:download_video]
  layout "ordinary",only: [:checkout] 
  layout "search",only: [:index] 

  def index
  end

  def places
    request_url = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
    request_params = {:input=> params[:term],:type=> "geocode",:location=>"55.3781,3.4360",:radius=>"1500",:key=>"AIzaSyDwZKfz5bq_CeYqzb-YvgG-LD7PRr8t8Es"}
    api_response = HTTParty.get(request_url,:timeout => 60,:query =>request_params)
    @predictions = api_response.parsed_response["predictions"] 
  end

  def call_api(place_id,location)
    if place_id.nil? || place_id.empty?
      api_url = "https://maps.googleapis.com/maps/api/geocode/json"
      request_params = {:address => location,:radius => 1500,:types => "geocode",:key=>"AIzaSyDwZKfz5bq_CeYqzb-YvgG-LD7PRr8t8Es"}
      api_response = HTTParty.get(api_url,:query => request_params,:timeout => 10) 
      return api_response["results"][0]["geometry"]["location"]
    else
      api_url= "https://maps.googleapis.com/maps/api/place/details/json"
      request_params = {:placeid=>place_id, :key=>"AIzaSyDwZKfz5bq_CeYqzb-YvgG-LD7PRr8t8Es"}
      api_response = HTTParty.get(api_url,:query => request_params,:timeout => 10) 
      return api_response["result"]["geometry"]["location"]
    end 
  end
  
  def search_api
    
    params_location_flag = false
    api = Array.new
    origin = Array.new
    if not params[:place_id].nil? or not params[:location].nil?
      if not params[:place_id].empty? and not params[:location].empty?
        
        params_location_flag = true
        place_id = params[:place_id]
        location = params[:location]
        #puts request.remote_ip
        gon.search_flag = true
        lat_lng = call_api(place_id,location)
  
        
      else
        # throw an error
        
        params_location_flag = false
        lat_lng = call_api("","London")
      end
    else
      
      
      params_location_flag = false
      lat_lng = call_api("","London")
      #throw an error
    end
    

    origin.push(lat_lng["lat"])
    origin.push(lat_lng["lng"])
    
    api << origin
    puts params_location_flag
    puts gon.params_location_flag
    if params_location_flag == true
      if params[:search_date_of_occurence].nil? or params[:search_date_of_occurence].empty?
        @events = Event.select(:latitude,:location_name,:longitude,:id,:date_of_occurence)
      else
        date = Date.parse(params[:search_date_of_occurence])
        @events = Event.select(:latitude,:location_name,:longitude,:id,:date_of_occurence).where(:date_of_occurence => date)
      end
    else
      puts "No location working"
      if params[:search_date_of_occurence].nil? or params[:search_date_of_occurence].empty?
        @events = Event.select(:latitude,:location_name,:longitude,:id,:date_of_occurence)
      else
        date = Date.parse(params[:search_date_of_occurence])
        @events = Event.select(:latitude,:location_name,:longitude,:id,:date_of_occurence).where(:date_of_occurence => date)
      end
    end
    
    

    events_array = Array.new
    if @events.size == 0
      events_array.push([0,location,lat_lng["lat"],lat_lng["lng"]])
      
      api << events_array
      
      gon.markers_location = events_array
    else
      @events.each do |event|
        temp_array = Array.new
        temp_array.push(event.id)
        temp_array.push(event.location_name)
        temp_array.push(event.latitude.to_s)
        temp_array.push(event.longitude.to_s)
        temp_array.push(event.date_of_occurence.to_s)
        temp_array.push(event.event_videos.length)
        events_array.push(temp_array)
        puts events_array
      end
      gon.lat = lat_lng["lat"]
      gon.lng = lat_lng["lng"]
      
      api << events_array
    
    end
    camera_markers = Array.new
    unless current_user.nil?
      @static_cameras = current_user.static_cameras
      @static_cameras.each do |camera|
        temp_array = Array.new
        temp_array.push(camera.id)
        temp_array.push(camera.location_name)
        temp_array.push(camera.latitude.to_s)
        temp_array.push(camera.longitude.to_s)
        camera_markers.push(temp_array)
      end
    end
    
    api << camera_markers
    flag = Array.new
    flag.push(params_location_flag)
    api << flag
    render :json => api
  end

  def search_results
    if user_signed_in?
      gon.user_signed_in = true
    else
      gon.user_signed_in = false
    end
    if not params[:place_id].nil? or not params[:location].nil?
      if not params[:place_id].empty? and not params[:location].empty?
        place_id = params[:place_id]
        location = params[:location]
        #puts request.remote_ip
        gon.search_flag = true
      else
        #api_url = "http://ipinfo.io/" + request.remote_ip + "/json"
        api_url = "http://ipinfo.io/157.50.1.166/json"
        api_response = HTTParty.get(api_url, :timeout => 10)
        
        gon.latitude, gon.longitude = api_response["loc"].split(",")
      
        puts gon.latitude
        
        #place_id = ""
        location = api_response["loc"]
      end
    else
      puts "Ip Search"
      gon.search_flag = false
      api_url = "http://ipinfo.io/157.50.1.166/json"
      #api_url = "http://ipinfo.io/" + request.remote_ip + "/json"
      api_response = HTTParty.get(api_url, :timeout => 10)
      gon.latitude, gon.longitude = api_response["loc"].split(",")
      
      puts gon.latitude

      #place_id = ""
      location = api_response["loc"]
    end
    lat_lng = call_api(place_id,location)
    if not params[:lat].nil? or not params[:lng].nil?
      if not params[:lat].empty? and not params[:lng].empty?
        gon.latitude = params[:lat]
        gon.longitude = params[:lng]
      else
        gon.latitude = lat_lng["lat"]
        gon.longitude = lat_lng["lng"]
      end
    else
      gon.latitude = lat_lng["lat"]
      gon.longitude = lat_lng["lng"]
    end
    
    
    origin = Array.new
    origin.push(gon.latitude)
    origin.push(gon.longitude)
    
    @events = Event.select(:latitude,:location_name,:longitude,:id,:date_of_occurence)
    events_array = Array.new
    if @events.size == 0
      events_array.push([0,location,lat_lng["lat"],lat_lng["lng"]])
      gon.markers_location = events_array
    else
      @events.each do |event|
        temp_array = Array.new
        temp_array.push(event.id)
        temp_array.push(event.location_name)
        temp_array.push(event.latitude.to_s)
        temp_array.push(event.longitude.to_s)
        temp_array.push(event.date_of_occurence.to_s)
        temp_array.push(event.event_videos.length)
        events_array.push(temp_array)
      end
      gon.lat = lat_lng["lat"]
      gon.lng = lat_lng["lng"]
      gon.markers_location = events_array
    end
    camera_markers = Array.new
    unless current_user.nil?
      @static_cameras = current_user.static_cameras
      @static_cameras.each do |camera|
        temp_array = Array.new
        temp_array.push(camera.id)
        temp_array.push(camera.location_name)
        temp_array.push(camera.latitude.to_s)
        temp_array.push(camera.longitude.to_s)
        camera_markers.push(temp_array)
      end
    end
    gon.camera_markers_location = camera_markers
  end

  def add_to_cart
    if user_signed_in?
      if @event_video.user_id == current_user.id
        flash[:danger] = "Its the video you uploaded!!"
        redirect_to root_path
        return
      else
        if current_user.cart.nil?
          @cart = Cart.new
          @cart.user_id = current_user.id
          @cart.save
        else
          @cart = current_user.cart
          @cart.cart_items.each do |item|
            if item.event_video_id == @event_video.id
              flash[:danger] = "Video already exists in cart"
              redirect_to root_path
              return
            end
          end
        end
        @cart_item = CartItem.new
        @cart_item.cart_id = @cart.id
        @cart_item.event_video_id = @event_video.id
        if @cart_item.save
          redirect_to checkout_path
        else
          flash[:danger] = "Unable to add to cart"
          redirect_to root_path
        end
      end
    else
      session[:event_video_id] = params[:event_video_id]
      redirect_to new_user_session_path
    end
  end
  
  def remove_from_cart
    @cart = current_user.cart
    @item = @cart.cart_items.find_by_event_video_id(params[:item_id])
    if @item.delete
      puts "Deleted successfully"
      redirect_to checkout_path
    else
      puts "error"
      redirect_to checkout_path
    end
  end

  def checkout
    gon = []
    cart = current_user.cart
    if not cart.nil?
      @cart_items = current_user.cart.cart_items.includes(event_video: :user)
      if @cart_items.size == 0
        flash[:danger] = "Cart is empty"
        redirect_to root_path
      end
    else
      flash[:danger] = "Cart is empty"
      redirect_to root_path
    end
  end

  def purchases
    @purchases = current_user.purchases
  end

  def download_video
    @name = @event_video.name.gsub(" ","_")
    puts "#{Rails.root}/public/uploads/event_video/video/#{@event_video_id}/#{@name}"
    send_file(
      "#{Rails.root}/public/uploads/event_video/video/#{@event_video_id}/#{@name}.mp4",
      filename: "#{@name}.mp4",
      type: "video/mp4/avi"
    )
  end

  private

  def sign_in_check
    if not user_signed_in?
      redirect_to new_user_session_path
    end
  end

  def event_video
    _videoid = params[:event_video_id] || session[:event_video_id]
    @event_video = EventVideo.find(_videoid)
  end
end

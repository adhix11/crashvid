class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  before_filter :sign_in_check, only: [:create,:update,:destroy]
  # GET /events
  # GET /events.json
  def index
    @events = Event.all.includes(:categories)
  end

  # GET /events/1
  # GET /events/1.json
  def show
  end

  # GET /events/new
  def new
    @response = Hash.new
    if user_signed_in?
      @event = Event.new
      if not session[:redirect_to].nil? 
        redirect_url = session[:redirect_to]
        session[:redirect_to] = nil
        redirect_to redirect_url
      end
    else
      #session[:redirect_to] = request.referrer
      @response["status"] = 1
      @response["message"] = "Please sign in before creating video"
    end
  end

  # GET /events/1/edit
  def edit
    if not @event.user_id == current_user.id
      flash[:danger]  = "You are not authorized"
      redirect_to root_path
    end
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(event_params)
    @event.user_id = current_user.id
    @event.category_list = params[:event][:category_list]

    
    #Notify static camera users, if event is created near to user's static camera
    pos = [@event.latitude, @event.longitude]
    static_camera_users = StaticCamera.select(:user_id).within(50, :origin => pos).uniq
    user = Array.new
    
    static_camera_users.each do |u|
      user.push(u.user_id)
    end

    if @event.save
      UserMailer.static_camera_notify(user, @event).deliver_later
      flash[:success] = 'Event was successfully created.' 
      marker_array = [@event.id,@event.location_name,@event.latitude,@event.longitude]
      gon.markers_location = marker_array
      redirect_to root_path
    else
      flash[:success] = 'Error Creating Event' 
      redirect_to root_path
    end
  end

 
   # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update
    respond_to do |format|
      if @event.update(event_params)
        flash[:success] = 'Event was successfully updated.' 
        format.html { redirect_to @event}
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    if not @event.user_id == current_user.id
      flash[:danger]  = "You are not authorized"
      redirect_to root_path
    else
      @event.destroy
      respond_to do |format|
        format.html { redirect_to events_url, success: 'Event was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

  end

  def subscribe
    @event_id = params[:event_id]
    @user_id = current_user.id
    Subscription.create(user_id: @user_id, event_id: @event_id)
    respond_to do |format|
      format.js   { render :layout => false }
    end
  end 

  def unsubscribe
    @event_id = params[:event_id]
    @user_id = current_user.id
    subs = Subscription.where(user_id: @user_id, event_id: @event_id).first
    subs.destroy
    respond_to do |format|
      format.js   { render :layout => false }
    end
  end 

  private
  def sign_in_check
    if not user_signed_in?
      redirect_to new_user_session_path
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_event
    @event = Event.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def event_params
    params.require(:event).permit(:latitude, :longitude, :date_of_occurence, :time_of_occurence, :location_name,:place_id,:category_list,:description)
  end
end

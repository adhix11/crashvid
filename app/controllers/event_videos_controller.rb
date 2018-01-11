class EventVideosController < ApplicationController
  before_action :set_event_video, only: [:show, :edit, :update, :destroy]
  before_filter :sign_in_check,only:[:index,:edit,:create,:destroy]
  # GET /event_videos
  # GET /event_videos.json
  def index
    @event_videos = EventVideo.all
  end

  # GET /event_videos/1
  # GET /event_videos/1.json
  def show
    @spam = @event_video.spam.where(:user_id => current_user.id)
    @name = @event_video.name.gsub(" ","_")
    @url = "/uploads/event_video/video/#{@event_video.id}/#{@name}.mp4"
    @count = current_user.purchases.where("payment_status='completed' && event_video_id=#{@event_video.id}").count
    if @spam.length>0
      @spam_reported = true
    else
      @spam_reported = false
    end
  end

  # GET /event_videos/new
  def new
    @response = Hash.new
    if user_signed_in?
        @event_id = params[:event_id]
        @event_video = EventVideo.new
        gon.markers_location = []
    else
      session[:redirect_to] = request.referrer
      @response["status"] = 1
      @response["message"] = "Please sign in before continuing"
    end
  end

  # GET /event_videos/1/edit
  def edit
    if not @event_video.user_id == current_user.id
      flash[:danger] = "You are not authorzied"
      redirect_to root_path
    end
  end

  # POST /event_videos
  # POST /event_videos.json
  def create
    @event_video = EventVideo.new(event_video_params)
    @event_video.user_id = current_user.id
    @event_video.event_id = params[:event_id]
    @event_video.video = params[:event_video][:video]
    original_name_with_ext = params[:event_video][:video].original_filename
    full_name = File.basename(original_name_with_ext,File.extname(original_name_with_ext))
    
    #Notify user who created the event, if any video is uploaded to the event
    current_event = Event.find(@event_video.event_id)
    current_event_user = User.find(current_event.user_id)

    #Notify subscribed users in current event 
    subscribed_users = current_event.subscribed_users.all
    user = Array.new

    subscribed_users.each do |u|
      user.push(u.id)
    end

    @event_video.name = full_name 
      if @event_video.save
        
        UserMailer.event_video_upload(current_event_user, current_event).deliver_later
        UserMailer.subscribed_users_notify(user, current_event).deliver_later
        flash[:success] = "Event and Video was successfully saved"
        redirect_to root_path
      else
         flash[:success] = "#{@event_video.errors}"
        redirect_to root_path
      end
  end

  def upload_video
    @response = Hash.new
    if user_signed_in?
      @event = Event.new
      @event_video = EventVideo.new
    else
      @response["status"] = 1
      @response["message"] = "Please sign in"
    end
  end

  def save_video
    @event_video = EventVideo.new
    @event = Event.new
    @event.latitude = params[:event][:latitude]
    @event.longitude = params[:event][:longitude]
    @event.place_id = params[:event][:place_id]
    @event.location_name = params[:event][:location_name]
    @event.date_of_occurence = params[:event][:date_of_occurence]
    @event.time_of_occurence = params[:event][:time_of_occurence]
    @event.description = params[:event][:description]
    @event.user_id = current_user.id
    @event.category_list = params[:event][:category_list]
    if @event.save
      @event_video.event_id = @event.id
      @event_video.user_id = current_user.id
      @event_video.video = params[:event][:video]
      original_name_with_ext = params[:event][:video].original_filename
      full_name = File.basename(original_name_with_ext,File.extname(original_name_with_ext))
      @event_video.name = full_name 
      if @event_video.save 
        flash[:success] = "Event and Video was successfully saved"
        redirect_to root_path
      else
        puts "Error"
      end
    else
      puts "Error-event"
    end
  end

  # PATCH/PUT /event_videos/1
  # PATCH/PUT /event_videos/1.json
  def update
    if not params[:event_video][:video].nil?
      @event_video.video = params[:event_video][:video]
      original_name_with_ext = params[:event_video][:video].original_filename
      full_name = File.basename(original_name_with_ext,File.extname(original_name_with_ext))
      @event_video.name = full_name 
    end
    respond_to do |format|
      if @event_video.update(event_video_params)
        format.html { redirect_to @event_video, success: 'Event video was successfully updated.' }
        format.json { render :show, status: :ok, location: @event_video }
      else
        format.html { render :edit }
        format.json { render json: @event_video.errors, status: :unprocessable_entity }
      end
    end
  end

  def show_event_videos

    if user_signed_in?    
      @user_id = current_user.id
      @event_id = params[:event_id]

      #Check for subscription
      subs_check = Subscription.where(user_id: @user_id, event_id: @event_id) 
      if subs_check.empty?
        @subs_flag = false
      else
        @subs_flag = true
      end
      puts @subs_flag
    end

    @event_videos = EventVideo.where(:event_id => params[:event_id])
    @event = Event.where(:id => params[:event_id]).first
  end

  # DELETE /event_videos/1
  # DELETE /event_videos/1.json
  def destroy
    @event_video.destroy
    respond_to do |format|
      format.html { redirect_to event_videos_url, notice: 'Event video was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def report_spam
    @event_id = params[:event_video_id]
    @event_videos = EventVideo.where(:event_id => params[:event_video_id])
    @spam = Spam.new
  end

  def update_spam
    @spam = Spam.new
    @spam.event_video_id = params[:event_video_id]
    @spam.user_id = current_user.id
    @spam.spam_category = params[:spam][:spam_category]
    @spam.comment = params[:spam][:comment]
    if @spam.save
      redirect_to root_path
    end

  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_event_video
    @event_video = EventVideo.find(params[:id])
    @event = Event.where(:id => @event_video.event_id).includes(:categories).first
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def event_video_params
    params.require(:event_video).permit(:name, :video,:event_id)
  end

  def sign_in_check
    if not user_signed_in?
      redirect_to new_user_session_path
    end
  end
end

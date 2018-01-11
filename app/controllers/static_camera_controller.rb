class StaticCameraController < ApplicationController
	def new
		@response = Hash.new
	    if user_signed_in?
	    	if not session[:redirect_to].nil?
		        session_url = session[:redirect_to]
		        session[:redirect_to] = nil
		        redirect_to session_url
		      end
	        @camera = StaticCamera.new
	    else
	    	session[:redirect_to] = request.referrer
	      	@response["status"] = 1
	      	@response["message"] = "Please sign in before continuing"
	    end
	end

	def create
		@camera = StaticCamera.new
		@camera.latitude = params[:static_camera][:latitude]
	    @camera.longitude = params[:static_camera][:longitude]
	    @camera.place_id = params[:static_camera][:place_id]
	    @camera.location_name = params[:static_camera][:location_name]
		@camera.user_id = current_user.id
		puts @camera.user_id.class
	    if @camera.save
	        flash[:success] = 'Static Camera was successfully added.' 
	        marker_array = [@camera.id,@camera.location_name,@camera.latitude,@camera.longitude]
	        gon.markers_location = marker_array
	        redirect_to root_path
	    else
	      	flash[:alert] = 'Unable to create Static Camera.' 
	      	redirect_to root_path
	    end
	end
	def delete
		@camera = StaticCamera.new
	end
	def destroy
		@camera = StaticCamera.find(params[:static_camera][:id])
		if not @camera.user_id == current_user.id
	      flash[:danger]  = "You are not authorized"
	      redirect_to root_path
	    else
	      @camera.destroy
	      flash[:success]  = "Camera removed Successfully"
	      redirect_to root_path
	    end
		

	end

private
  def sign_in_check
    if not user_signed_in?
      redirect_to new_user_session_path
    end
  end
  def static_camera_params
  	puts params[:static_camera]
    params.require(:static_camera).permit(:latitude, :longitude,:location_name,:place_id)
  end
end
class UserAccountsController < ApplicationController
	before_action :check_user, only: [:edit, :update]
	before_action :sign_in_check
	before_action :set_user_account, only: [:edit, :update]
	before_action :set_user, only: [:uploaded_videos, :events, :cameras, :payments, :update_payment_info]
	
	def edit
		@countries  = { "United States (+1)" => "+1", "Switzerland (+41)" => "+41" }
	end

	def update
		if @user_account.update(user_account_params)
			redirect_to edit_user_account_path(@user_account), notice: 'Updated Successfully'
		else
			flash[:alert] = "Please Try Again."
			render 'edit'
		end
	end

	def uploaded_videos
		
		@videos = @user.event_videos
	end

	def events 
		@events = @user.events
		@subscribed_events = @user.subscribed_events
	end

	def cameras
		@cameras = @user.static_cameras
	end

	def payments
		@videos = @user.event_videos
	end

	def update_payment_info
		puts "user info"
		puts @user
		if @user.update(user_payment_info_params)
			redirect_to payments_path, notice: 'Updated Successfully'
		else
			flash[:alert] = "Please Try Again."
			render 'payments'
		end
	end

	private

	def check_user
		user_id = current_user.id
		check_user = UserAccount.where(user_id: user_id)
		if check_user.empty?
			UserAccount.create("user_id" => user_id)
		end
	end

	def sign_in_check
	    if not user_signed_in?
	      redirect_to new_user_session_path
	    end
    end

    def set_user
    	user_id = current_user.id
    	@user = User.find(user_id)
    end
    
    def set_user_account
    	user_id = current_user.id
    	@user_account = UserAccount.where("user_id" => user_id).first
    end

    def user_account_params
    	params.require(:user_account).permit(:first_name, :last_name, :address_line_1, :address_line_2, :city, :country, :zipcode, :country_code, :phone)
    end

    def user_payment_info_params
    	params.require(:user).permit(:paypal_email, :paypal_paykey)
    end
end

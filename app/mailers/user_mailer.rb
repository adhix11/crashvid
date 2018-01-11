class UserMailer < ApplicationMailer
	default from: 'no-reply@digiryte.com'

	def event_video_upload(user, event)
		@user = user
		@event = event
		mail(to: @user.email, subject: 'Video Uploaded')
	end

	def subscribed_users_notify(users, event)
		@event = event
		@users = users
		@users.each do |u|
			user = User.find(u)
            mail(to: user.email, subject: 'Video Uploaded on your subscribed event')
            
		end

	end
	def static_camera_notify(users, event)
		@event = event
		@users = users
		@users.each do |u|

			@user = User.find(u)
            mail(to: @user.email, subject: 'Event created near to your camera')
            
		end
	end
end

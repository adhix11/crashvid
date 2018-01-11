class OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def stripe_connect
    if user_signed_in?
      omniauth_response = request.env['omniauth.auth']
      stripe_user_id = omniauth_response["uid"]
      user = User.find(current_user.id)
      user.stripe_user_id = stripe_user_id
      user.save
      flash[:success] = "You have successfully connected your Stripe account with CrashVid"
      success_path = request.env['omniauth.origin'] || stored_location_for(resource) || root_path
      redirect_to success_path
    else
      flash[:danger] = "We are unable to establish connection to your Stripe account with CrashVid.Please try again later."
      redirect_to new_user_session_path
    end
  end

  # facebook callback
def facebook
  @user = User.create_from_provider_data(request.env['omniauth.auth'])
  if @user.persisted?
    sign_in_and_redirect @user
    set_flash_message(:notice, :success, kind: 'Facebook') if is_navigational_format?
  else
    flash[:error] = 'There was a problem signing you in through Facebook. Please register or try signing in later.'
    redirect_to new_user_registration_url
  end 
end

# google callback
def google_oauth2
  @user = User.create_from_provider_data(request.env['omniauth.auth'])
  if @user.persisted?
    sign_in_and_redirect @user
    set_flash_message(:notice, :success, kind: 'Google') if is_navigational_format?
  else
    flash[:error] = 'There was a problem signing you in through Google. Please register or try signing in later.'
    redirect_to new_user_registration_url
  end 
end

def failure
  flash[:error] = 'There was a problem signing you in. Please register or try signing in later.' 
  redirect_to new_user_registration_url
end

end

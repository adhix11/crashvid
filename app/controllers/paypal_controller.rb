class PaypalController < ApplicationController
	before_filter :sign_in_check,only: [:success,:execute,:cancelled,:setup_purchase]
	before_filter :set_up_gateway, only: [:setup_purchase,:success,:execute]
	def success
	   	response = @gateway.details_for_payment(
	   	:pay_key => params[:payKey]
	   	)
	   	res = JSON.parse(response.to_json)
	   	puts res
	   	primary_trans = res["response"]["payment_info_list"]["payment_info"][0]
	   	if primary_trans["transaction_status"] == "COMPLETED"
	      	@event_videos_purchased = update_purchases(params[:payKey],"COMPLETED")
	      	update_transaction(params[:payKey],res["response"]["sender"]["email"],res["response"]["sender"]["account_id"],primary_trans["transaction_id"],primary_trans["transaction_status"],res["response"]["status"])
	      	current_user.cart.cart_items.delete_all
	    end    
	end
	def execute
		
		response = @gateway.execute_payment(
	   		:pay_key => params[:payKey]
	   	)
	   	res = JSON.parse(response.to_json)
	end
	def cancelled
		flash[:danger] = "Payment process is cancelled"
		redirect_to checkout_path
	end
	def notification
		puts "test"
		notification = ActiveMerchant::Billing::Integrations::PaypalAdaptivePayment::Notification.new(request.raw_post)
		if notification.acknowledge
		   # finalize the payment
		   puts notification.acknowledge
		end
		head :ok
	end
	def setup_purchase
		recipients = [{:email => 'crashviddealer@crashvid.com',
		                 :amount => params[:amount],
		                 :primary => true},
		              {:email => 'crashvidcustomer@crashvid.com',
		                 :amount => 15,
		                 :primary => false}
                 	]
		  response = @gateway.setup_purchase(
		  	:action_type => "PAY_PRIMARY",
		    :return_url => "http://188.166.145.19/success?payKey=${payKey}",
		    :cancel_url => url_for(:action => 'cancelled', :only_path => false),
		    :ipn_notification_url => url_for(:action => 'notification', :only_path => false),
		    :receiver_list => recipients,
		    :currency_code => "GBP"
		  )
		  res = JSON.parse(response.to_json)
		  if res["response"]["payment_exec_status"] == "CREATED"
		  	@paykey = res["response"]["pay_key"]
		  	@transaction_id = record_transaction(current_user.id,@paykey,res["response"]["payment_exec_status"],params[:amount])
		  	if @transaction_id
		  		cart_items = current_user.cart.cart_items
		    	cart_items.each do |cart_item|
		      		record_purchase(@paykey,"CREATED",current_user.id,cart_item.event_video_id,@transaction_id,cart_item.event_video.price)
		    	end
		    end
		  	redirect_to @gateway.redirect_url_for(response['payKey'])
		  else
		  	flash[:danger] = "Error Processing payment.Contact support."
    		redirect_to checkout_path
    	end
	end


	private
	def sign_in_check
	    if not user_signed_in?
		    redirect_to new_user_session_path
		end
  	end
  	def set_up_gateway
  		@gateway =  ActiveMerchant::Billing::PaypalAdaptivePayment.new(
		  :login => "hello_api1.crashvid.com",
		  :password => "WT7MAKSZTKK5N95U",
		  :signature => "AQU0e5vuZCvSg-XJploSa.sGUDlpAg-MZG7F9fBlOiUIYNCnczMvhnIo",
		  :appid => "APP-80W284485P519543T" )
  	end
  	def record_purchase(paykey,charge_status,user_id,event_video_id,transaction_id,price)
	    purchase = Purchase.new
	    purchase.paypal_paykey = paykey
	    purchase.payment_status = charge_status
	    purchase.user_id = user_id
	    purchase.event_video_id = event_video_id
	    purchase.user_transaction_id = transaction_id
	    purchase.amount = price
	    purchase.currency_code = "GBP"
	    purchase.save
	end
	def record_transaction(user_id,paykey,status,price)
  		transaction = UserTransaction.new
  		transaction.user_id = user_id 
  		transaction.paykey = paykey
  		transaction.transaction_status = status
  		transaction.transaction_amount = price
  		transaction.currency_code = "GBP"
  		if transaction.save
  			return transaction.id
  		else
  			return false 
  		end
	end
	def update_purchases(paykey,status)
		@purchases = Purchase.where("paypal_paykey='#{paykey}'")
		event_videos_purchased = []
		@purchases.each do |purchase|
			event_videos_purchased << purchase.event_video
			purchase.payment_status = status
			purchase.save
		end
		return event_videos_purchased
	end
	def update_transaction(paykey,sender_mail_id,sender_account_id,primary_transaction_id,primary_transaction_status,transaction_status)
		@transaction = UserTransaction.find_by_paykey(paykey)
		@transaction.sender_mail_id = sender_mail_id
		@transaction.sender_account_id = sender_account_id
		@transaction.primary_transaction_id = primary_transaction_id
		@transaction.primary_transaction_status = primary_transaction_status
		@transaction.transaction_status = transaction_status
		@transaction.save
	end
end

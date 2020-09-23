class KlaviyoController < AuthenticatedController
	include ApplicationHelper

	def track
		@klaviyo = Klaviyo::Client.new(ENV['KLAVIYO_API_KEY'])
		@klaviyo.track('subscribe', email: params[:email])

		current_shop.update(subscribe_to_klaviyo: true)

		UserMailer.welcome_email(params[:email]).deliver ###sending email after subscribing to Klaviyo

		redirect_to root_path, notice: 'Email Added to Klaviyo'
	end
end

class UserMailer < ApplicationMailer
	def welcome_email(email)
	    mail(to: email, subject: 'You are subscribed to Klaviyo')
	end
end

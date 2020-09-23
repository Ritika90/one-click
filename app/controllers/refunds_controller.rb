class RefundsController < ApplicationController
	skip_before_action :verify_authenticity_token
	
	def create
		puts "You are here"
	end
end

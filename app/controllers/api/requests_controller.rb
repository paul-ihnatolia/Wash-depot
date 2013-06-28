class Api::RequestsController < ApplicationController
	
	respond_to :json

	before_filter :only_admin_manager, :only => :index
	before_filter :only_admin, :only => [:update, :delete]
	before_filter :retrieve_params, :only => [:update, :create]
	before_filter :get_request, :only => [:show, :update, :destroy]

	def index
		@requests = Request.all
	end

	def show
	end

	def create
		@request = Request.new @params_options

		respond_to do |format|
			if @request.save
				format.json {}
			else
				format.json {render :json => @request.errors.to_json }
			end
		end
	end

	def update
		respond_to do |format|
			if @request.update_attributes(@params_options)
				format.json { render :nothing => true }
			else
				format.json {render :json => @request.errors.to_json }
			end
		end 
	end

	def destroy
		respond_to do |format|
			if @request.destroy
				format.json { render :nothing => true }
			end
		end
	end

	private
	def only_admin_manager
		render "api/errors/permission_denied" if current_api_user.user_type == 0
	end

	def only_admin
		render "api/errors/permission_denied" if current_api_user.user_type != 2
	end

	def retrieve_params
		
		# make available mass assignment

		@params_options = {}

		unless params["current_status"].blank?
			current_status_name = params["current_status"]
			@params_options[:status_id] = Status.where(:name => current_status_name).first.id
		end

		unless params["completed"].blank?
			@params_options[:completed] = params["completed"]
		end

		unless params["last_review"].blank?
			last_review = params["last_review"].to_s
			@params_options[:last_reviewed] = DateTime.strptime(last_review,'%s') 
		end

		unless params['creation_date'].blank? 
			@params_options[:creation_date] = DateTime.strptime(params['creation_date'].to_s,'%s')
		end

		unless params['location'].blank?
			@params_options[:location_id] = Location.where(:name => params['location']).first.id
		end

		# &&&
		unless params['requested_by'].blank?
			@params_options['requested_by'] = Location.where(:name => params['location']).first.id
		end
		
		unless params['description'].blank?
			@params_options[:description] = params['description']
		end

		unless params['importance'].blank?
			@params_options[:importance] = params['importance']
		end

		unless params['problem_area'].blank?
			@params_options[:problem_area_id] = ProblemArea.where(:name => params['problem_area']).first.id
		end

		unless params['identifier'].blank?
			# Set request id
			@params_options[:id] = params['identifier']
		end
	end

	def get_request
		@request = Request.find params[:id]
	end
end

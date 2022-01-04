class Api::V1::MembersController < ApplicationController

	def index
		members = Member.order('created_at DESC')
		render json: {status: 'SUCCESS', message:'Displaying Members', data:members}, status: :ok
  end

  def show
  	member = Member.find(params[:id])
  	render json: {status: 'SUCCESS', message:'Displaying Member', data:member}, status: :ok
  end

  def create
		member = Member.new(member_params)
		if member.save!
			render json: {status: 'SUCCESS', message:'Saved Member', data:member}, status: :ok
		else
			render json: {status: 'ERROR', message:'Member not saved', data:member.errors}, status: :unprocessable_entity
		end
  end

  def destroy
		member = Member.find(params[:id])
		member.destroy
		render json: {status: 'SUCCESS', message:'Deleted Member', data:member}, status: :ok
  end

	def update
		member = Member.find(params[:id])
		if member.update(member_params)
			render json: {status: 'SUCCESS', message:'Updated Member', data:member}, status: :ok
		else
			render json: {status: 'ERROR', message:'Member not updated', data:member.errors}, status: :unprocessable_entity
		end
	end

	private

 	def member_params
 		params.require(:member).permit(:first_name, :last_name, :url, :email, :password)
 	end
end

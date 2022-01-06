class Api::V1::MembersController < ApplicationController
  
  def index
    members = Member.order('created_at DESC')
    render json: {status: 'SUCCESS', message:'Display Members', data:members}, status: :ok
  end

  def show
    member = Member.includes(:member_website, :friends).where(id: params[:id]).first
    render json: {status: 'SUCCESS', message:'loaded Member', data:{member: member, webiste: member.member_website, friends: member.friends}}, status: :ok
  end

  def create
    member = Member.create_member(member_params)
    if member.save!
      render json: {status: 'SUCCESS', message:'Saved Member', data: {member: member, website: member.member_website}}, status: :ok
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

  def add_friend
    result = Member.add_friend(params[:member_id], params[:friend_id])
    if result[:member].present?
      render json: {status: 'SUCCESS', message: result[:msg]}, status: :ok
    else
      render json: {status: 'ERROR', message:'Member not saved'}, status: :unprocessable_entity
    end
  end

  def get_friends
    # 	puts @current_member
    member = Member.where(id: params[:member_id]).first
    # member = @current_member
    if member.present?
      friends = member.friends
      render json: {status: 'SUCCESS', message:'Friends displayed successfully', data:{member: member, friends: friends}}, status: :ok
    else
      render json: {status: 'ERROR', message:'Friends can not be displayed'}, status: :unprocessable_entity
    end
  end

  private

  def member_params
    params.require(:member).permit(:first_name, :last_name, :url, :email, :password)
  end
end

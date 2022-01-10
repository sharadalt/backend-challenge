####################################################################################################################
#  This is the main Controller file from where all the API calls are initiated
#  Based on the routes.rb file the action will be determined. The standard actions/methods, index, show, create,
#  destroy, update are implemented. For general details on these standard methods, 
#  refer to ActionController Overview in https://guides.rubyonrails.org.
#  In addition to the standard methods, add_friend, get_friends, get_experts, login and a private method 
#  method, member_params are also there
#################################################################################################################### 

class Api::V1::MembersController < ApplicationController

  # Below line is for enabling the token verification for the API, for the methods indicated
  # validate_member_session_token method is in application_controller.rb
  before_action :validate_member_session_token, only: [:index, :destroy]


  ####################################################################################################################
  # create /Sign up method is a POST method. A member can be created using their name(first_name + last_name), personal website address, 
  # email address and password. email address and password are extra fields. This has to be the first method, as it creates the member
  # in postman for example if we say, http://localhost:3000/api/v1/members
  # with body content has follows and POST and send:

  # "first_name":"Lily",
  # "last_name":"Thomson",
  # "url":"https://www.w3schools.com/html/html_headings.asp",
  # "email": "lily34@example.com",
  # "password": "CheckPassw123456"
  # {
  #     "status": "SUCCESS",
  #     "message": "Saved Member",
  #     "data": {
  #         "member": {
  #             "id": 12,
  #             "first_name": "Lily",
  #             "last_name": "Thomson",
  #             "url": "https://www.w3schools.com/html/html_headings.asp",
  #             "email": "lily34@example.com",
  #             "password": "b752ee9a433756385dc523c115d620fa5eb56bcf2fc59e24241126ed76eb2392",
  #             "created_at": "2022-01-08T20:05:27.986Z",
  #             "updated_at": "2022-01-08T20:05:27.986Z",
  #             "salt": "e3c2aff071b6b5c2553fb32ef9ebcdfc9ef051363f66ea6bb2e316eff1e914a0",
  #             "auth_token": null,
  #             "is_token_valid": false
  #         },
  #         "website": {
  #             "id": 12,
  #             "member_id": 12,
  #             "website_url": "https://www.w3schools.com/html/html_headings.asp",
  #             "short_url": "https://bit.ly/31lOiJS",
  #             "heading_h1": "HTML Headings,Heading 1",
  #             "heading_h2": "Tutorials,References,Exercises and Quizzes,HTML Tutorial,HTML Forms,HTML Graphics,HTML Media,HTML APIs,HTML Examples,HTML References,Heading 2,HTML Headings,Headings Are Important,Bigger Headings,HTML Exercises,Test Yourself With Exercises,Exercise:,HTML Tag Reference,Report Error,Thank You For Helping Us!",
  #             "heading_h3": "HTML and CSS,Data Analytics,XML Tutorials,JavaScript,Programming,Server Side,Web Building,Data Analytics,XML Tutorials,HTML,CSS,JavaScript,Programming,Server Side,XML,Character Sets,Exercises,Quizzes,Courses,Certificates,Example,Heading 3,Example,Example",
  #             "created_at": "2022-01-08T20:05:28.429Z",
  #             "updated_at": "2022-01-08T20:05:28.429Z"
  #         }
  #     }
  # }
  def create
    member = Member.create_member(member_params)
    if member.save!
      render json: {status: 'SUCCESS', message:'Saved Member', data: {member: member, website: member.member_website}}, status: :ok
    else
      render json: {status: 'ERROR', message:'Member not saved', data:member.errors}, status: :unprocessable_entity
    end
  end

  ####################################################################################################################
  # login/sign_in method is a POST method: This creates the auth_token which can be used in APIs
  # In create method output we see the auth_token is null, that gets filled in this method.
  # This needs to be the 2nd method, as we get the auth_token to be used in our further API calls
  # In postman app if we say, http://localhost:3000/api/v1/members/login.json and in body if we
  # fill Usename and Password  and POST and send 
  # Username: "lily34@example.com"
  # Password: "*****************"

  # we get the output something like below:
  #  {
  #    "status": "SUCCESS",
  #    "data": {
  #        "member": {
  #            "auth_token": "c42d684980568044bcae26ade932f1ec520579f15c0d3e42bcc992d7a6569181",
  #            "is_token_valid": true,
  #            "id": 12,
  #            "email": "lily34@example.com",
  #            "password": "b752ee9a433756385dc523c115d620fa5eb56bcf2fc59e24241126ed76eb2392",
  #            "first_name": "Lily",
  #            "last_name": "Thomson",
  #            "url": "https://www.w3schools.com/html/html_headings.asp",
  #            "created_at": "2022-01-08T20:05:27.986Z",
  #            "updated_at": "2022-01-08T20:46:49.379Z",
  #            "salt": "e3c2aff071b6b5c2553fb32ef9ebcdfc9ef051363f66ea6bb2e316eff1e914a0"
  #        }
  #    }
  # }

  def login  
    credentials = Base64.decode64(request.headers['Authorization'].split(" ")[1]).split(":")
    email = credentials[0]
    password = credentials[1]
    member = Member.authenticate(email, password)
    if(member.present?)
      render json: {status: 'SUCCESS', data:{member: member}}, status: :ok
    else
      render json: {status: 'ERROR', message:'Incorrect username or password', }, status: 401
    end
  end

  ####################################################################################################################
  # index method lists all members with their name, short url and the number of friends.
  # in postman app if we say http://localhost:3000/api/v1/members  with the auth_token and send 
  # after the  the login to be done prior and the auth-token obtained to be provided
  # The results will be something like below:
  # "message": "Display Members",
  # "data": [
  #     {
  #         "name": "Lyda Orn",
  #         "short_url": "https://bit.ly/3q3OS8s",
  #         "no_of_friends": 1
  #     },
  #     {
  #         "name": "Wiley Strosin",
  #         "short_url": "https://bit.ly/3zAgYLP",
  #         "no_of_friends": 0
  #     },
  #     {
  #         .....
  #
  def index
    members = Member.member_details
    render json: {status: 'SUCCESS', message:'Display Members', data:members}, status: :ok
  end

  ####################################################################################################################
  # show method is a GET method.  displays name, website URL, shortening, website headings, and links to their friends' pages.
  # in postman app if we say, http://localhost:3000/api/v1/members/12 and GET and send 
  #     "message": "loaded Member",
  #     "data": {
  #         "member": [
  #             {
  #                 "name": "Linda Wallace",
  #                 "website_url": "http://www.example.com",
  #                 "short_url": "https://bit.ly/31lOiJS"
  #             }
  #         ],
  #         "website": [
  #             {
  #                 "headin_h1": "HTML Headings,Heading 1",
  #                 "headin_h2": "Tutorials,References,Exercises and Quizzes",
  #                 "headin_h3": "HTML and CSS,Data Analytics"
  #             }
  #         ],
  #         "friends": [
  #             {
  #                 "name": "Lyda Orn",
  #                 "friend_link": "http://localhost:3000/api/v1/members/1"
  #             }
  #         ]
  #     }
  # }

  def show
    #member = Member.includes(:friends).where(id:@current_member.id).first
    member = Member.includes(:member_website, :friends).where(id: params[:id]).first
    member_info = member.member_info
    friend_links = member.friend_with_links
    website_info = member.website_info
    render json: {status: 'SUCCESS', message:'loaded Member', data:{member: member_info, website: website_info, friends: friend_links}}, status: :ok
  end
  
  ####################################################################################################################
  # update method is a PUT/PATCH method which can be used to alter the fields
  # If we have http://localhost:3000/api/v1/members/12 in postman app,
  # if we have the body with whatever field to be altered, 
  # {
  #  "last_name":"John" and  send we see the out as below:

  #   "status": "SUCCESS",
  #     "message": "Updated Member",
  #     "data": {
  #         "last_name": "John",
  #         "id": 12,
  #         "email": "lily34@example.com",
  #         "password": "b752ee9a433756385dc523c115d620fa5eb56bcf2fc59e24241126ed76eb2392",
  #         "first_name": "Lily",
  #         "url": "https://www.w3schools.com/html/html_headings.asp",
  #         "created_at": "2022-01-08T20:05:27.986Z",
  #         "updated_at": "2022-01-08T22:04:42.045Z",
  #         "salt": "e3c2aff071b6b5c2553fb32ef9ebcdfc9ef051363f66ea6bb2e316eff1e914a0",
  #         "auth_token": "c42d684980568044bcae26ade932f1ec520579f15c0d3e42bcc992d7a6569181",
  #         "is_token_valid": true
  #     }
  # }
  def update
    # member = @current_member
    member = Member.find(params[:id])
    if member.update(member_params)
      render json: {status: 'SUCCESS', message:'Updated Member', data:member}, status: :ok
    else
      render json: {status: 'ERROR', message:'Member not updated', data:member.errors}, status: :unprocessable_entity
    end
  end

  ####################################################################################################################
  # delete method may never be used, it meight be a soft delete instead of destroy.
  # destroy method is a DELETE method.
  # If we have the following in postman app, http://localhost:3000/api/v1/members/3 with DELETE
  # and send with the auth_token. Make sure you login as the member to be deleted and the auth_token for that member
  # The output will be as follows:
  # {
  #   "status": "SUCCESS",
  #   "message": "Deleted Member",
  #   "data": {
  #       "id": 3,
  #       "first_name": "Garth",
  #       "last_name": "Feeney",
  #       "url": "http://example.com/carolyn_krajcik",
  #       "email": "maryland@spencer.com",
  #       "password": "fd699e5be71d24d3ddd1fd94f870a5ecd298a7c4d538e3ef67a18e569d4e239a",
  #       "created_at": "2022-01-07T21:56:14.460Z",
  #       "updated_at": "2022-01-07T21:56:14.460Z",
  #       "salt": "336ca8904e57905847959891584951a2604cd0bea30bb7024d40e872f68617ab",
  #       "auth_token": null,
  #       "is_token_valid": false
  #   }
  # }
  def destroy
    member = @current_member
    member.destroy
    render json: {status: 'SUCCESS', message:'Deleted Member', data:member}, status: :ok
  end

  ####################################################################################################################
  # add_friend is a POST method. As the name says, it adds a friend to the member
  # If we have this in the postman app, http://localhost:3000/api/v1/members/add_friend.json, POST
  # and the following in the body
  #{      
  #  "member_id":12
  #  "friend_id" :5
  #} 
  # We get the folowing output
  # {
  # "status": "SUCCESS",
  # "message": "Friend added successfully"
  # }
  #  Note: the member gets a friend also the friend gets the member as his friend.
  def add_friend
    result = Member.add_friend(params[:member_id],params[:friend_id])
    if result[:member].present?
      render json: {status: 'SUCCESS', message: result[:msg]}, status: :ok
    else
      render json: {status: 'ERROR', message: result[:msg], data: result[:member].errors}, status: :unprocessable_entity
    end
  end
 
  ####################################################################################################################
  # get_friends is a GET method. It displays the friends
  # if we have the following in postman http://localhost:3000/api/v1/members/get_friends.json, GET and we get 
  # the following results:
  #   "message": "Friends displayed successfully",
  #     "data": {
  #         "member": {
  #             "id": 12,
  #             "first_name": "Lily",
  #             "last_name": "John",
  #             "url": "https://www.w3schools.com/html/html_headings.asp",
  #             "email": "lily34@example.com",
  #             "password": "b752ee9a433756385dc523c115d620fa5eb56bcf2fc59e24241126ed76eb2392",
  #             "created_at": "2022-01-08T20:05:27.986Z",
  #             "updated_at": "2022-01-08T22:04:42.045Z",
  #             "salt": "e3c2aff071b6b5c2553fb32ef9ebcdfc9ef051363f66ea6bb2e316eff1e914a0",
  #             "auth_token": "c42d684980568044bcae26ade932f1ec520579f15c0d3e42bcc992d7a6569181",
  #             "is_token_valid": true
  #         },
  #         "friends": [
  #             {
  #                 "id": 1,
  #                 "first_name": "Lyda",
  #                 "last_name": "Orn",
  #                 "url": "http://example.com/magdalen_aufderhar",
  #                 "email": "hector@schneider-heaney.org",
  #                 "password": "fcbdd6584d75b2e45f02545109eb580e731ed3732981bf7d58bf7fad4f298462",
  #                 "created_at": "2022-01-07T21:56:13.098Z",
  #                 "updated_at": "2022-01-07T21:56:13.098Z",
  #                 "salt": "d8a726d0e6f60b9854f13bdf53e1843702f6fd55576427c087c03198ba956491",
  #                 "auth_token": null,
  #                 "is_token_valid": false
  #             },
  #             {
  #                 "id": 5,
  #                 "first_name": "Rolande",
  #                 "last_name": "Yundt",
  #                 "url": "http://example.com/kermit.marquardt",
  #                 "email": "edie_weber@kuhn-gleichner.co",
  #                 "password": "1d317f9d70d76c8ecbfd12919db5a287cdef5be5124c20e039db71a1a97b40a7",
  #                 "created_at": "2022-01-07T21:56:15.983Z",
  #                 "updated_at": "2022-01-07T21:56:15.983Z",
  #                 "salt": "8febe402314d66e2d5fa117849b3196eff7a0df92c7fb3f4c84ca634a3551909",
  #                 "auth_token": null,
  #                 "is_token_valid": false
  #             }
  #         ]
  #     }
  # }
  def get_friends
    member = Member.where(id: params[:member_id]).first
    if member.present?
      friends = member.friends
      render json: {status: 'SUCCESS', message:'Friends displayed successfully', data:{member: member, friends: friends}}, status: :ok
    else
      render json: {status: 'ERROR', message:'Friends can not be displayed', data:member.errors}, status: :unprocessable_entity
    end
  end

  #############################################################################################################################################
  # get_experts method is a GET method. This actually finds if there are any Headings(h1,h2,h3) of the member matches with that of 
  # friend's friends headings and accordingly return them. Here initially I tried breaking down the headings into words and tried matching them.
  # Later I felt, that is not what is expected, so I took the whole heading string and searched if there is a match.
  # if we have the following in postman http://localhost:3000/api/v1/members/get_experts.json, GET and we get 
  # the following results:

  # {
  #  "status": "SUCCESS",
  #     "data": {
  #         "member": {
  #             "id": 13,
  #             "first_name": "Jeremy",
  #             "last_name": "Thomson",
  #             "url": "http://example.com/frankie.emmerich",
  #             "email": "jthomson@example.com",
  #             "password": "946ad8fb4a2191e4f51b7c115142170ccc0641fe3c619b783daa4cf275e0b5a9",
  #             "created_at": "2022-01-08T23:34:57.674Z",
  #             "updated_at": "2022-01-08T23:34:57.674Z",
  #             "salt": "318a786a9381a4302437510c53284bc129f161332d30ba0632d256075eae8732",
  #             "auth_token": null,
  #             "is_token_valid": false
  #         },
  #         "get_experts": [
  #             {
  #                 "friends_friend_id": 2,
  #                 "link_id": "13->5->2",
  #                 "link_name": "Jeremy->Rolande->Wiley('Example Domain')",
  #                 "score": 10,
  #                 "matched_headings": [
  #                     [
  #                         "Example Domain"
  #                     ]
  #                 ]
  #             },
  #             {
  #                 "friends_friend_id": 4,
  #                 "link_id": "13->5->4",
  #                 "link_name": "Jeremy->Rolande->Marin('Example Domain')",
  #                 "score": 10,
  #                 "matched_headings": [
  #                     [
  #                         "Example Domain"
  #                     ]
  #                 ]
  #             }
  #         ]
  #     }
  # }
  def get_experts
    #member = @current_member
    member = Member.where(id: params[:member_id]).first
    if member.present?
      experts = member.get_experts
      render json: {status: 'SUCCESS', data:{member: member, get_experts:experts}}, status: :ok
    else
      render json: {status: 'ERROR', message:'Experts can not be displayed', data:member.errors}, status: :unprocessable_entity
    end
  end

  private

  def member_params
    params.require(:member).permit(:first_name, :last_name, :url, :email, :password)
  end
end

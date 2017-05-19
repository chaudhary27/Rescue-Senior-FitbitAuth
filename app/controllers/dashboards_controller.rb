require 'date'
class DashboardsController < ApplicationController
  before_action :authenticate_user!
  after_action  :update_refresh_token
  
  
  def index
    @user_name = current_user.fitbit_client.profile[:user][:display_name]
    # @devices = current_user.fitbit_client.devices
    # @devices.each do |device|
    #   @device_version = device[:device_version]
    #   @device_battery = device[:battery]
    # end
    # Daily Summary only works when the Fitbit is on for the day and
    # data is fetched. Turn it on to get the heart rate data
    # @daily_summary = current_user.fitbit_client.daily_activity_summary[:summary][:heart_rate_zones]
    
    # @resting_heart_rate = current_user.fitbit_client.daily_activity_summary[:summary][:resting_heart_rate]
    # @inactive_minutes = current_user.fitbit_client.daily_activity_summary[:summary][:sedentary_minutes]
    @step_count = current_user.fitbit_client.daily_activity_summary[:summary][:steps]
    # @very_active_minutes = current_user.fitbit_client.daily_activity_summary[:summary][:very_active_minutes]
    
    # Set timestamp in firebase
    @time_stamp = Time.now.strftime("%m/%d/%Y %l:%M:%S %p")
    time_stamp_ = Bigbertha::Ref.new( 'https://rescuesenior-d31bf.firebaseio.com/time_stamp')
    time_stamp_.set(@time_stamp)
    
    # Send heart rate data to firebase
    heart_rate_zones = Bigbertha::Ref.new( 'https://rescuesenior-d31bf.firebaseio.com/heart_rate_zones' )
    heart_rate_zones.set(@daily_summary)
    
    # user_device = Bigbertha::Ref.new( 'https://rescuesenior-d31bf.firebaseio.com/device' )
    # user_device.set(@device_version)
    
    # device_battery_ = Bigbertha::Ref.new( 'https://rescuesenior-d31bf.firebaseio.com/device_battery' )
    # device_battery_.set(@device_battery)
    
    # resting_hear_rate_ = Bigbertha::Ref.new( 'https://rescuesenior-d31bf.firebaseio.com/resting_heart_rate' )
    # resting_hear_rate_.set(@resting_heart_rate)
    
    # Send step count data to Firebase
    steps_count_ = Bigbertha::Ref.new( 'https://rescuesenior-d31bf.firebaseio.com/steps_count' )
    steps_count_.set(@step_count)
    
    # inactive_minutes_ = Bigbertha::Ref.new( 'https://rescuesenior-d31bf.firebaseio.com/inactive_minutes' )
    # inactive_minutes_.set(@inactive_minutes)
    # sleep 3
    
    redirect_to "http://localhost:3000/users/1"
  end
  
  
  private
  
  def update_refresh_token
    new_refresh_token = current_user.fitbit_client.token.refresh_token
    current_user.identity_for("fitbit_oauth2").update_attribute(:refresh_token, new_refresh_token)
  end
end

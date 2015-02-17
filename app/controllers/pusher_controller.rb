class PusherController < ApplicationController
  protect_from_forgery :except => [:auth, :channel] # stop rails CSRF protection for this action

  def auth
    response = Pusher[params[:channel_name]].authenticate(params[:socket_id], {
      user_id: session[:username],
      user_info: {
        name: session[:username],
        peer: session[:peer]
      }
    })
    render :json => response
  end

  def channel
    webhook = Pusher::WebHook.new(request)
    if webhook.valid?
      webhook.events.each do |event|
        #todo: more webhook work
        if event['name'] == 'channel_vacated'
          id = event['channel'].gsub('presence-','')
          casting = Casting.where(interview: id).first
          if (casting)
            casting.started_interview = nil
            casting.interview = nil
            casting.save

            Pusher["presence-casthire_#{casting.id}"].trigger('stop_interview', {})
          end
        end
      end
      render json: true
    else
      render 401
    end
  end
end

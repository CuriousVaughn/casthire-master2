class CastingsController < ApplicationController
  include ActionController::Live
  before_filter :authorize, except: [:apply, :private, :register, :wait]
  before_filter :authorize_creator, only: :show

  def index
    woopra.track 'viewed casting list', {}, true
    @castings = Casting.where(user: current_user)
    @casting = Casting.new
    gon.casting = @casting
  end

  def create
    woopra.track 'created casting ' + params[:casting][:name].to_s, {}, true
    casting = Casting.new(casting_params)
    casting.user = current_user
    casting.save
    redirect_to castings_path
  end

  def show
    woopra.track 'joined admin casting page ' + @casting.name.to_s, {}, true
    gon.casting = @casting
    gon.pusher_key = Pusher.key
    session[:username] = "Host"
    gon.username = "Host" #todo: use a name from the users profile.
  end

  def apply
    gon.username = session[:username] if session[:username]
    @casting = Casting.find(params[:id])
    woopra.track 'join casting page ' + @casting.name.to_s, {}, true
    @applicant = Applicant.new(params[:applicant])
    @applicant.casting = @casting
    @applicant.save
    gon.casting = @casting
    gon.pusher_key = Pusher.key
  end

  def kick
    @casting = Casting.find(params[:id])

    Pusher["presence-casthire_#{@casting.id}"].trigger('kick', {
        :peer => params[:peer]
    })
    render json: true
  end

  def interview
    @casting = Casting.find(params[:id])
    @casting.started_interview = Time.now
    interview = @casting.fetch_interview
    @casting.save

    Pusher["presence-casthire_#{@casting.id}"].trigger('interview', {
        :peers => params[:peers],
        :interview => interview,
        :time => @casting.started_interview
    })

    render json: { interview: interview }
  end

  def register
    session[:peer] = params[:peer]
    puts "setting session username to #{params[:username]}"
    session[:username] = params[:username]
    render json: { peer: session[:peer] }
  end

  def private
    @casting = Casting.find(params[:id])
    gon.private_id = params[:private_id]
    gon.casting = @casting
    gon.pusher_key = Pusher.key
    puts "setting session: #{session[:username]}"
    gon.username = session[:username] if !!session[:username]

    @back_path = @casting.user == current_user ? casting_path(@casting) : apply_casting_path(@casting)
  end

  def update
    woopra.track 'updated casting', {}, true
    Casting.update(params[:id], casting_params)
    redirect_to casting_path(params[:id])
  end

  def destroy
    woopra.track 'deleted casting', {}, true
    Casting.destroy(params[:id])
    flash[:success] = 'Successfully deleted Casting'
    redirect_to castings_path
  end

  private

  def authorize_creator
    @casting = Casting.find(params[:id])
    unless @casting.user == current_user
      redirect_to apply
    end
  end

  def casting_params
    params.require(:casting).permit(:name)
  end

  def applicant_params
    params.require(:applicant).permit(:name)
  end

  def sse(object, options = {})
    (options.map{|k,v| "#{k}: #{v}" } << "data: #{object.to_json}").join("\n") + "\n\n"
  end
end

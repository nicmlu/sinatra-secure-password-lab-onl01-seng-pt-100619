require "./config/environment"
require "./app/models/user"
class ApplicationController < Sinatra::Base

  configure do
    set :views, "app/views"
    enable :sessions
    set :session_secret, "password_security"
  end

  get "/" do
    erb :index
  end

  get "/signup" do
    erb :signup
  end

  post "/signup" do
    if params[:username]=="" || params[:password]==""
      redirect to "/failure"
    else
      user = User.new(params)
      user.balance = 0
      if user.save
        redirect to "/login"
      else
        redirect to "/failure"
      end
    end
  end

  get '/account' do
    @user = User.find(session[:user_id])
    erb :account
  end


  get "/login" do
    erb :login
  end

  post "/login" do
    if params[:username]=="" || params[:password]==""
      redirect to "/failure"
    else
      user = User.find_by(username:params[:username])
      if user && user.authenticate(params[:password])
        session[:user_id] = user.id
        redirect to "/account"
      else
        redirect to "/failure"
      end
    end
  end

  get "/failure" do
    erb :failure
  end

  get "/logout" do
    session.clear
    redirect "/"
  end

  get "/deposits" do
    @deposits = current_user.deposits
    erb :"/deposits/index"
  end

  get "/deposits/new" do
    erb :'deposits/new'
  end

  get "/deposits/:id" do
    @deposit = Deposit.find_by(id:params[:id],user_id:session[:user_id])
    if @deposit
      erb :'/deposits/show'
    else
      "Deposit information not found"
    end
  end

  post "/deposits" do
    @deposit = Deposit.new(params)
    @user = current_user
    @user.balance += params[:amount].to_f
    @deposit.user = current_user
    if @deposit.save && @user.save
      redirect to "/deposits/#{@deposit.id}"
    else
      redirect to "/failure"
    end
  end

  get "/withdrawals" do
    @withdrawals = current_user.withdrawals
    erb :"/withdrawals/index"
  end

  get "/withdrawals/new" do
    erb :'withdrawals/new'
  end

  get "/withdrawals/:id" do
    @withdrawal = Withdrawal.find_by(id:params[:id],user_id:session[:user_id])
    if @withdrawal
      erb :'/withdrawals/show'
    else
      "Withdrawal information not found"
    end
  end

  post "/withdrawals" do
    @withdrawal = Withdrawal.new(params)
    @user = current_user
    if params[:amount].to_f > @user.balance
      redirect to "/failure"
    else
      @user.balance -= params[:amount].to_f
      @withdrawal.user = current_user
      if @withdrawal.save && @user.save
        redirect to "/withdrawals/#{@withdrawal.id}"
      else
        redirect to "/failure"
      end
    end
  end

  helpers do
    def logged_in?
      !!session[:user_id]
    end

    def current_user
      User.find(session[:user_id])
    end
  end

end
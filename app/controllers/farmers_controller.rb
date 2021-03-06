class FarmersController < ApplicationController
  before_action :set_farmer, only: [:show, :edit, :update, :destroy]

  # GET /farmers
  # GET /farmers.json
  def index
    @farmers = Farmer.all
  end

  # GET /farmers/1
  # GET /farmers/1.json
  def show
    @farmer = Farmer.find(params[:id])
    @is_admin = current_user && current_user.id == @farmer.id
  end

  # GET /farmers/new
  # GET /farmers/new
  def new
    if current_user
      redirect_to root_path, :notice => "You are already registered"
    end
    @farmer = Farmer.new
  end

  # GET /farmers/1/edit
  # GET /farmers/1/edit
  def edit
    @farmer = Farmer.find(params[:id])
    if current_user.id != @farmer.id
      redirect_to @farmer
    end
  end

  # POST /farmers
  # POST /farmers.json
  # POST /farmers
  def create
    @farmer = Farmer.new(params[:farmer])

    if @farmer.save
      session[:farmer_id] = @farmer.id
      redirect_to @farmer, notice: 'Farmer was successfully created.'
    else
      render action: "new"
    end
  end

  # PATCH/PUT /farmers/1
  # PATCH/PUT /farmers/1.json
  def update
    respond_to do |format|
      if @farmer.update(farmer_params)
        format.html { redirect_to @farmer, notice: 'Farmer was successfully updated.' }
        format.json { render :show, status: :ok, location: @farmer }
      else
        format.html { render :edit }
        format.json { render json: @farmer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /farmers/1
  # DELETE /farmers/1.json
  def destroy
    @farmer.destroy
    respond_to do |format|
      format.html { redirect_to farmers_url, notice: 'Farmer was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_farmer
      @farmer = Farmer.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def farmer_params
      params.require(:farmer).permit(:name, :email, :password_hash, :farm, :produce, :produce_price, :wepay_access_token, :wepay_account_id)
    end

    #GET /farmers/oauth/1
    def oauth
      if !params[:code]
        return redirect_to('/')
      end

      redirect_uri = url_for(:controller => 'farmers', :action => 'oauth', :farmer_id => params[:farmer_id], :host => request.host_with_port)
      @farmer = Farmer.find(params[:farmer_id])
      begin
        @farmer.request_wepay_access_token(params[:code], redirect_uri)
      rescue Exception => e
        error = e.message
      end

      if error
        redirect_to @farmer, alert: error
      else
        redirect_to @farmer, notice: 'We successfully connected you to WePay!'
      end
    end

end

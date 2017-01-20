class MachineTypesController < ApplicationController
  before_action :set_machine_type, only: [:show, :edit, :update, :destroy]

  # GET /machine_types
  # GET /machine_types.json
  def index
    @machine_types = MachineType.all
  end

  # GET /machine_types/1
  # GET /machine_types/1.json
  def show
  end

  # GET /machine_types/new
  def new
    @machine_type = MachineType.new
  end

  # GET /machine_types/1/edit
  def edit
  end

  # POST /machine_types
  # POST /machine_types.json
  def create
    @machine_type = MachineType.new(machine_type_params)

    respond_to do |format|
      if @machine_type.save
        format.html { redirect_to @machine_type, notice: 'Machine type was successfully created.' }
        format.json { render :show, status: :created, location: @machine_type }
      else
        format.html { render :new }
        format.json { render json: @machine_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /machine_types/1
  # PATCH/PUT /machine_types/1.json
  def update
    respond_to do |format|
      if @machine_type.update(machine_type_params)
        format.html { redirect_to @machine_type, notice: 'Machine type was successfully updated.' }
        format.json { render :show, status: :ok, location: @machine_type }
      else
        format.html { render :edit }
        format.json { render json: @machine_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /machine_types/1
  # DELETE /machine_types/1.json
  def destroy
    @machine_type.destroy
    respond_to do |format|
      format.html { redirect_to machine_types_url, notice: 'Machine type was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_machine_type
      @machine_type = MachineType.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def machine_type_params
      params.require(:machine_type).permit(:name, :core_count, :memory_size, :provider_id)
    end
end

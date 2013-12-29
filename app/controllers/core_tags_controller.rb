class CoreTagsController < ApplicationController
  # GET /core_tags
  # GET /core_tags.json
  def index
    @core_tags = CoreTag.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @core_tags }
    end
  end

  # GET /core_tags/1
  # GET /core_tags/1.json
  def show
    @core_tag = CoreTag.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @core_tag }
    end
  end

  # GET /core_tags/new
  # GET /core_tags/new.json
  def new
    @core_tag = CoreTag.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @core_tag }
    end
  end

  # GET /core_tags/1/edit
  def edit
    @core_tag = CoreTag.find(params[:id])
  end

  # POST /core_tags
  # POST /core_tags.json
  def create
    @core_tag = CoreTag.new(params[:core_tag])

    respond_to do |format|
      if @core_tag.save
        format.html { redirect_to @core_tag, notice: 'Core tag was successfully created.' }
        format.json { render json: @core_tag, status: :created, location: @core_tag }
      else
        format.html { render action: "new" }
        format.json { render json: @core_tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /core_tags/1
  # PUT /core_tags/1.json
  def update
    @core_tag = CoreTag.find(params[:id])

    respond_to do |format|
      if @core_tag.update_attributes(params[:core_tag])
        format.html { redirect_to @core_tag, notice: 'Core tag was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @core_tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /core_tags/1
  # DELETE /core_tags/1.json
  def destroy
    @core_tag = CoreTag.find(params[:id])
    @core_tag.destroy

    respond_to do |format|
      format.html { redirect_to core_tags_url }
      format.json { head :no_content }
    end
  end
end

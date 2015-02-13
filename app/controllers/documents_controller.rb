class DocumentsController < ApplicationController
  before_action :set_document, only: [:edit, :update, :destroy]

  def index
    @documents = Document.with_attachment.page(params[:page])
    render 'documents/_documents', layout: false if request.xhr?
  end

  def new
    @document = Document.new
  end

  def edit
  end

  def create
    @document = Document.create!(document_params)
    render json: { id: @document.id }
  end

  def update
    respond_to do |format|
      if @document.update(document_params)
        format.html { redirect_to documents_url }
        format.json { render :index, status: :ok, location: @document }
      else
        format.html { render :edit }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @document.destroy
    head :ok
  end

  private
    def set_document
      @document = Document.find(params[:id])
    end

    def document_params
      params.require(:document).permit(:name)
    end
end

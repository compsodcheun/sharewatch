class WatchesController < ApplicationController
  def index
    @watches = current_user.watches
      .order_by(created_at: :desc)
      .paginate(:page => params[:page], :per_page => 8)
  end

  def new
    @watch = Watch.new
  end

  def edit
    @watch = Watch.find_by(id: params[:id])
  end

  def create
    @watch = Watch.new(create_params)
    if @watch.save
      if params[:watch][:images].present?
        @watch.images.destroy_all
        params[:watch][:images].each do |image_upload_file|
          new_image = Image.new
          new_image.assign_file(image_upload_file)
          @watch.images << new_image
        end
      end

      flash[:notice] = "Created watch successfully."
      redirect_to watches_path
    else
      flash.now[:alert] = @watch.errors.full_messages.join(',')
      render :new
    end
  end

  def update
    @watch = Watch.find_by(id: update_params[:id])

    if @watch.update(update_params)
      if params[:watch][:images].present?
        @watch.images.destroy_all
        params[:watch][:images].each do |image_upload_file|
          new_image = Image.new
          new_image.assign_file(image_upload_file)
          @watch.images << new_image
        end
      end

      flash[:notice] = "Updated watch successfully."
      redirect_to watches_path
    else
      flash.now[:alert] = @watch.errors.full_messages.join(',')
      render :edit
    end
  end

  def destroy
    @watch = Watch.find_by(id: params[:id])
    name = @watch.name
    @watch.destroy
    flash[:notice] = "Deleted #{name} successfully."
    redirect_to watches_path
  end

  def borrowing
    @watch = Watch.where(id: params[:id]).first
    @transaction = Transaction.new(
      watch: @watch,
      borrower: current_user,
      lender: @watch.present? ? @watch.owner : nil
    )

    if @transaction.save
      flash[:notice] = "You have borrowing #{@watch.name} successfully."
      redirect_to borrows_path
    else
      flash[:alert] = @transaction.errors.full_messages.join(',')
      redirect_to root_path
    end
  end

  private

  def create_params
    parameter = params.require(:watch).permit(:name, :detail, :owner)
    parameter.merge!(owner: current_user)
  end

  def update_params
    parameter = params.require(:watch).permit(:id, :name, :detail, :owner, :images)
    parameter.merge!(id: params[:id])
    parameter.merge!(owner: current_user)
  end
end

class BorrowsController < ApplicationController
  def index
    @transactions = current_user.borrowing
      .includes(:watch)
      .order_by(created_at: :desc)
      .order_by(state: :asc)
      .paginate(:page => params[:page], :per_page => 8)
  end

  def lending
    @transactions = current_user.lending
      .includes(:watch)
      .order_by(created_at: :desc)
      .order_by(state: :asc)
      .paginate(:page => params[:page], :per_page => 8)
  end

  def approve
    @transaction = Transaction.where(id: permit_params[:id]).first
    @transaction.state = Transaction::APPROVE
    @transaction.skip_flood = true
    if @transaction.save
      flash[:notice] = "You have approve #{@transaction.watch.name} successfully."
      redirect_to lending_path
    else
      flash[:alert] = @transaction.errors.full_messages.join(',')
      redirect_to lending_path
    end
  end

  def reject
    @transaction = Transaction.where(id: permit_params[:id]).first
    @transaction.state = Transaction::REJECT
    @transaction.skip_flood = true
    if @transaction.save
      flash[:notice] = "You have reject #{@transaction.watch.name} successfully."
      redirect_to lending_path
    else
      flash[:alert] = @transaction.errors.full_messages.join(',')
      redirect_to lending_path
    end
  end

  def destroy
    @transaction = Transaction.find_by(id: permit_params[:id])
    @transaction.destroy
    flash[:notice] = 'Your borrowing has been delete.'
    redirect_to borrows_path
  end

  private

  def permit_params
    params.permit(:id)
  end
end

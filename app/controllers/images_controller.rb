class ImagesController < ApplicationController
  def download
    watch = Watch.where(id: params[:watch_id]).first
    image = watch.images.where(id: params[:id]).first
    if params[:thumbnail].to_s == "true"
      send_data(image.get_thumbnail)
    elsif params[:thumbnail].to_s == "false"
      send_data(image.get_raw)
    else
      nil
    end
  end
end

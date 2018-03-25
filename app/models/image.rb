class Image
  include Mongoid::Document

  field :name, type: String
  field :raw_id, type: BSON::ObjectId
  field :thumbnail_id, type: BSON::ObjectId

  embedded_in :watch, class_name: "Watch"
  before_destroy :delete_grid_fs

  validates_presence_of :name

  def assign_file(file)
    f = Mongoid::GridFs.put(file)
    self.name = file.original_filename
    self.raw_id = f.id

    tmp_file = "#{Rails.root}/tmp/#{file.original_filename}"

    id = 0
    while File.exists?(tmp_file) do
      tmp_file = "#{Rails.root}/tmp/#{id}.#{file.original_filename}"
      id += 1
    end

    File.open(tmp_file, 'wb') do |f|
      f.write self.get_raw
    end

    thumbnail = MiniMagick::Image.open(tmp_file)
    thumbnail.combine_options do |c|
      c.resize '128x128^'
      c.gravity 'center'
      c.extent '128x128'
    end
    thumbnail.format "png"

    f = Mongoid::GridFs.put(thumbnail.path)
    self.thumbnail_id = f.id

    File.delete(tmp_file) if File.exist?(tmp_file)
  end

  def get_raw
    Mongoid::GridFs.get(raw_id).data
  end

  def delete_grid_fs
    Mongoid::GridFs.delete(raw_id)
    Mongoid::GridFs.delete(thumbnail_id)
  end

  def get_thumbnail
    Mongoid::GridFs.get(thumbnail_id).data
  end
end

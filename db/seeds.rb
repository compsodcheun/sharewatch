puts 'generating data...'

image_jpg_1 = Rack::Test::UploadedFile.new(
  File.open(File.join(Rails.root, '/spec/files/IMG_1.jpg'))
)
image_jpg_2 = Rack::Test::UploadedFile.new(
  File.open(File.join(Rails.root, '/spec/files/IMG_2.jpg'))
)
image_jpg_3 = Rack::Test::UploadedFile.new(
  File.open(File.join(Rails.root, '/spec/files/IMG_3.jpg'))
)
image1 = FactoryBot.build(:image)
image2 = FactoryBot.build(:image)
image3 = FactoryBot.build(:image)
watch = FactoryBot.build(:watch, name: 'Fitbit blaze', detail: 'ของใหม่มาก ผมมีหลายเรือนแบ่งเพื่อนๆ ไปใช้ครับ')

mart = User.create(
  name: 'Mart',
  email: 'mart@example.com',
  password: '12345678',
  password_confirmation: '12345678'
)
User.create(
  name: 'Handsome guy',
  email: 'test@example.com',
  password: '12345678',
  password_confirmation: '12345678'
)

image1.assign_file(image_jpg_1)
image2.assign_file(image_jpg_2)
image3.assign_file(image_jpg_3)
watch.images << [image1, image2, image3]
watch.owner = mart
watch.save

puts 'generated complete.'

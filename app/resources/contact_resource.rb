class ContactResource < JSONAPI::Resource
  attributes :name_first, :name_last, :email, :twitter
  has_many :phone_numbers, class_name: "PhoneNumber"
end

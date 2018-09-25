module Bar
  class PhoneNumberResource < JSONAPI::Resource
    model_name 'PhoneNumber'
    attributes :name, :phone_number
    #has_one :contact, class_name: '::Contact'

    #filter :contact
  end
end

module Bar
  class PhoneNumberResource < ApplicationResource
    include Pundit
    before_create { authorize(_model, :create?, policy_class: Bar::PhoneNumberPolicy) }

    model_name 'PhoneNumber'
    attributes :name, :phone_number
    has_one :contact

    filter :contact
  end
end

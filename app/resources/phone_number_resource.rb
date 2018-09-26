class PhoneNumberResource < ApplicationResource
  include Pundit

  before_create { authorize(_model, :create?) }

  attributes :name, :phone_number
  has_one :contact

  filter :contact
end

module Bar
  class PhoneNumberPolicy
    def initialize(user, phone_number)
      @user = user
      @phone_number = phone_number
    end

    def create?
      false
    end
  end
end

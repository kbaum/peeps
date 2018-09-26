class ApplicationResource < JSONAPI::Resource
  abstract

  def self.current_user(options)
    options.fetch(:context).fetch(:current_user)
  end

  private

  def current_user
    context.fetch(:current_user)
  end
end

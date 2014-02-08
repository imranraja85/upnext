OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, '132263183619935', 'd0ddda12df6e258b8f597cb28d07ee4a'
end

class PasswordsController < Devise::PasswordsController
  
  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)
    
    if not successfully_sent?(resource)
      @errors = resource.errors.full_messages
      render status: 422
    end
  end
  
  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    yield resource if block_given?

    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)
      flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
      set_flash_message(:notice, flash_message) if is_flashing_format?
      # sign_in(resource_name, resource)
      respond_with resource, location: after_resetting_password_path_for(resource)
    else
      respond_with resource
    end
  end
  
  protected
    def after_resetting_password_path_for(resource)
      root_path
    end
  
end

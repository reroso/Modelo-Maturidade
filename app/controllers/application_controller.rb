class ApplicationController < ActionController::Base
    skip_before_action :verify_authenticity_token

    def after_sign_in_path_for(resource)
      # Desloga todos os usuários, exceto o usuário atual
      sign_out_all_users_except(resource)

      # Redireciona baseado no tipo de recurso
      if resource.is_a?(Admin)
        main_screen_path  # Redireciona para o admin
      elsif resource.is_a?(User)
        selecionar_path  # Redireciona para o usuário
      elsif resource.is_a?(Appraiser)
        avaliar_path  # Redireciona para o usuário
      else

        super  # Chama o método da superclasse Devise::SessionsController
      end
    end

    private

    # Desloga todos os usuários autenticados, exceto o usuário fornecido
    def sign_out_all_users_except(current_user)
      # Desloga o admin se o atual usuário for um User
      if current_user.is_a?(User)
        sign_out(:admin) if admin_signed_in?
        sign_out(:appraiser) if appraiser_signed_in?
      end

      # Desloga o user se o atual usuário for um Admin
      if current_user.is_a?(Admin)
        sign_out(:user) if user_signed_in?
        sign_out(:appraiser) if appraiser_signed_in?
      end

      if current_user.is_a?(Appraiser)
        sign_out(:user) if user_signed_in?
        sign_out(:admin) if admin_signed_in?
      end
    end
  end

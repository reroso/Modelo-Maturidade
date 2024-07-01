class ApplicationController < ActionController::Base
    skip_before_action :verify_authenticity_token

    def after_sign_in_path_for(resource)
        # Desloga todos os usuários, exceto o usuário atual
        sign_out_all_users_except(resource)

        # Redireciona baseado no tipo de recurso
        if resource.is_a?(Admin)
            puts 'Um admin logou emmmmmmmmmm'
            main_screen_path  # Redireciona para o admin
        elsif resource.is_a?(User)
            puts 'Um usuário logou emmmmmmmm'
            aplicar_path  # Redireciona para o usuário
        else
            puts 'O superman chegouooooooooooooooooo'
            super  # Chama o método da superclasse Devise::SessionsController
        end
    end

    private

    # Desloga todos os usuários autenticados, exceto o usuário fornecido
    def sign_out_all_users_except(current_user)
    if user_signed_in? && current_user.is_a?(User)
        sign_out(:user) unless current_user == current_user
        sign_out(:admin) unless current_user == current_user
    end

    if admin_signed_in? && current_user.is_a?(Admin)
        sign_out(:admin) unless current_user == current_user
        sign_out(:user) unless current_user == current_user
    end
    end


end

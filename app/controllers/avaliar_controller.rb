class AvaliarController < ApplicationController
    before_action :authenticate_appraiser!
    def index
        @dimensaos = Dimensao.all
        @processos = Processo.all
        @resultados = Resultado.all
        @maturidades = Maturidade.all
        @opcao = params[:opcao].to_i
        @modelo_aplicados = ModeloAplicado.all
        @levels = Level.all
    end

    def atualizar_opcao

        @opcao = params[:opcao]
        redirect_url = url_for(controller: :avaliar, action: :index, opcao: @opcao)
        render json: { redirect_url: redirect_url }

    end


end

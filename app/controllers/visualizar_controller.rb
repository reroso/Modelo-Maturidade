class VisualizarController < ApplicationController
    before_action :authenticate_user!

    def index
        @dimensaos = Dimensao.all
        @processos = Processo.all
        @resultados = Resultado.all
        @maturidades = Maturidade.all
        @opcao = params[:opcao].to_i
        @modelo = params[:modelo].to_i
        @modelo_aplicado = ModeloAplicado.all
        @levels = Level.all
    end

    def atualizar_opcao

        @opcao = params[:opcao]
        @modelo = params[:modelo]
        redirect_url = url_for(controller: :visualizar, action: :index, opcao: @opcao, modelo: @modelo)
        render json: { redirect_url: redirect_url }

    end

end

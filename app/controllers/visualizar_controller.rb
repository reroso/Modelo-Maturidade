class VisualizarController < ApplicationController

    def index
        @dimensaos = Dimensao.all
        @processos = Processo.all
        @resultados = Resultado.all
        @maturidades = Maturidade.all
        @opcao = params[:opcao].to_i
        @dominios = Dominio.all
        @modelo_aplicados = ModeloAplicado.all
    end

    def atualizar_opcao

        @opcao = params[:opcao]
        redirect_url = url_for(controller: :visualizar, action: :index, opcao: @opcao)
        render json: { redirect_url: redirect_url } 

    end

end
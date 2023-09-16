class AplicarController < ApplicationController

    def index
        @dimensaos = Dimensao.all
        @processos = Processo.all
        @resultados = Resultado.all
        @maturidades = Maturidade.all
        @opcao = params[:opcao].to_i
        
    end

    def atualizar_opcao

        @opcao = params[:opcao]
        redirect_url = url_for(controller: :aplicar, action: :index, opcao: @opcao)
        render json: { redirect_url: redirect_url } 

    end
    
end

class EditarController < ApplicationController

    def index
        @dimensaos = Dimensao.all
        @processos = Processo.all
        @resultados = Resultado.all
        @maturidades = Maturidade.all
        @opcao = params[:opcao].to_i
        @dominios = Dominio.all
        @modelo_aplicados = ModeloAplicado.all
        @levels = Level.all
    end

    def atualizar_opcao

        @opcao = params[:opcao]
        redirect_url = url_for(controller: :editar, action: :index, opcao: @opcao)
        render json: { redirect_url: redirect_url } 

    end

    def incluir_nivel
        level = Level.find_by(index: params[:index], modelo_id: params[:modelo_id])

        if level.present?
            level.descricao = params[:descricao]
            level.save
        else
            level = Level.new
            level.index = params[:index]
            level.descricao = params[:descricao]
            level.modelo_id = params[:modelo_id]
            level.save
        end

    end

    def salvar_nivel
        level = Level.find(params[:id])
        level.descricao = params[:descricao]
        level.save

    end

end

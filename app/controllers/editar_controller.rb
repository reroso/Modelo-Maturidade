class EditarController < ApplicationController
    before_action :authenticate_admin!
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

    #niveis

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

    #modelos

    def salvar_maturidade
        maturidade = Maturidade.find(params[:id])
        maturidade.nome = params[:nome]
        maturidade.descricao = params[:descricao]
        maturidade.tipoNivel = params[:tipoNivel]
        maturidade.menorNivel = params[:menorNivel]
        maturidade.maiorNivel = params[:maiorNivel]
        maturidade.resultadoEscolha = params[:resultadoEscolha]
        maturidade.nivelEscolha = params[:nivelEscolha]
        maturidade.save

        redirect_to "/editar"
    end

    def excluir_maturidade
        maturidade = Maturidade.find(params[:id])
        maturidade.destroy
        redirect_to "/editar"
    end

end

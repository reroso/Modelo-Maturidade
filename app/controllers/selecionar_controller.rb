class SelecionarController < ApplicationController
    before_action :authenticate_user!

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
        redirect_url = url_for(controller: :selecionar, action: :index, opcao: @opcao)
        render json: { redirect_url: redirect_url }

    end

    #modelos aplicados

    def incluir_modelo_aplicado
        modelo_aplicado = ModeloAplicado.new
        modelo_aplicado.metodo = params[:metodo]
        modelo_aplicado.instituicao = params[:instituicao]
        modelo_aplicado.dominio_id = params[:dominio_id]
        modelo_aplicado.maturidade_id = params[:maturidade_id]
        modelo_aplicado.user_id = params[:user_id]
        modelo_aplicado.save

        redirect_to "/selecionar"
    end

    #dominio

    def incluir_dominio
        dominio = Dominio.new
        dominio.nome = params[:nome]
        dominio.save

        redirect_to "/selecionar"
    end

    def buscar_dominio
        term = params[:term]

        if term.present?
        dominios = Dominio.where("nome LIKE ?", "%#{term}%").pluck(:nome)
        else
        dominios = Dominio.all.pluck(:nome)
        end

        render json: dominios

    end

    def buscar_instituicao
        term = params[:term]

        if term.present?
        instituicaos = ModeloAplicado.where("instituicao LIKE ?", "%#{term}%").pluck(:instituicao)
        else
        instituicaos = ModeloAplicado.all.pluck(:instituicao)
        end

        render json: instituicaos

    end

end

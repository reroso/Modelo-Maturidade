class SelecionarController < ApplicationController
    before_action :authenticate_user!

    def index
        @dimensaos = Dimensao.all
        @processos = Processo.all
        @resultados = Resultado.all
        @maturidades = Maturidade.all
        @opcao = params[:opcao].to_i
        
        # Carregando apenas valores únicos para cada campo usando pluck e compact
        @expertise_areas = ExpertiseArea.all.pluck(:name)
        @dominios = ModeloAplicado.pluck(:dominio).compact.uniq.sort
        @instituicoes = ModeloAplicado.pluck(:instituicao).compact.uniq.sort
        @metodos = ModeloAplicado.pluck(:metodo).compact.uniq.sort
        
        # Debug
        Rails.logger.debug "Dominios: #{@dominios.inspect}"
        Rails.logger.debug "Instituicoes: #{@instituicoes.inspect}"
        Rails.logger.debug "Metodos: #{@metodos.inspect}"
        
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
        modelo_aplicado.dominio = params[:dominio]
        modelo_aplicado.maturidade_id = params[:maturidade_id]
        modelo_aplicado.user_id = params[:user_id]
        modelo_aplicado.save

        redirect_to "/selecionar"
    end

    def buscar_dominio
        term = params[:term]

        if term.present?
        dominios = ModeloAplicado.where("metodo LIKE ?", "%#{term}%").pluck(:dominio)
        else
        dominios = ModeloAplicado.all.pluck(:dominio)
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

    def buscar_metodo
        term = params[:term]

        if term.present?
        metodos = ModeloAplicado.where("metodo LIKE ?", "%#{term}%").pluck(:metodo)
        else
        metodos = ModeloAplicado.all.pluck(:metodo)
        end

        render json: metodos

    end

end

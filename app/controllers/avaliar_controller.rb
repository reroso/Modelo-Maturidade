class AvaliarController < ApplicationController
    before_action :authenticate_appraiser!
    layout 'application'

    def index
        # Busca as áreas de atuação do avaliador atual
        appraiser_domains = current_appraiser.expertise_areas.pluck(:name)
        
        # Filtra os modelos aplicados que correspondem às áreas de atuação do avaliador
        @modelo_aplicado = if appraiser_domains.any?
          ModeloAplicado.where(dominio: appraiser_domains)
        else
          ModeloAplicado.none # Se o avaliador não tiver áreas de atuação, não mostra nenhum modelo
        end

        @dimensaos = Dimensao.all
        @processos = Processo.all
        @resultados = Resultado.all
        @maturidades = Maturidade.all
        @opcao = params[:opcao].to_i
        @modelo = params[:modelo].to_i
        @levels = Level.all
    end

    def atualizar_opcao

        @opcao = params[:opcao]
        @modelo = params[:modelo]
        redirect_url = "/avaliar?opcao=#{@opcao}&modelo=#{@modelo}"
        render json: { redirect_url: redirect_url }

    end

    def salvar_classificacao_docs

        attachment = ActiveStorage::Attachment.find(params[:id])
        blob = attachment.blob  # Obtém o blob associado ao attachment
        blob.update(classificacao: params[:classificacao])

    end

    def show
        @modelo = ModeloAplicado.find(params[:id])
    end
end

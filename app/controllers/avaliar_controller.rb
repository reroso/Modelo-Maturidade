require_relative '../services/ai_document_evaluator_service'

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
        blob.update(classificacao: params[:classificacao], descricao_avaliador: params[:descricao_avaliador])
    end

    # Nova ação para avaliação por IA
    def avaliar_com_ia
        attachment = ActiveStorage::Attachment.find(params[:id])
        blob = attachment.blob

        # Determina se é processo ou resultado
        processo_or_resultado = if attachment.record_type == 'Processo'
          attachment.record
        else
          attachment.record # Para resultados
        end

        # Contexto adicional para a IA
        context = {
          expertise_area: current_appraiser.expertise_areas.pluck(:name).join(', '),
          nivel_selecionado: processo_or_resultado.nivel_selecionado
        }

        # Chama o serviço de IA
        ai_service = AiDocumentEvaluatorService.new
        result = ai_service.evaluate_document(blob, processo_or_resultado, context)

        if result[:success]
          # Salva a sugestão da IA
          blob.update(
            classificacao: result[:classification],
            descricao_avaliador: result[:description],
            ai_generated: true
          )

          render json: {
            success: true,
            classification: result[:classification],
            description: result[:description],
            message: "Avaliação por IA concluída. Revise e confirme se necessário."
          }
        else
          render json: {
            success: false,
            error: result[:error],
            message: "Erro na avaliação por IA. Proceda com avaliação manual."
          }
        end
    end

    # Nova ação para avaliar múltiplos documentos com IA
    def avaliar_lote_com_ia
        modelo_id = params[:modelo_id]

        # Busca todos os documentos não avaliados do modelo
        documentos_nao_avaliados = ActiveStorage::Blob.joins(:attachments)
                                                      .where(modelo: modelo_id, classificacao: nil)

        resultados = []

        documentos_nao_avaliados.each do |blob|
          attachment = blob.attachments.first
          processo_or_resultado = attachment.record

          context = {
            expertise_area: current_appraiser.expertise_areas.pluck(:name).join(', '),
            nivel_selecionado: processo_or_resultado.nivel_selecionado
          }

          ai_service = AiDocumentEvaluatorService.new
          result = ai_service.evaluate_document(blob, processo_or_resultado, context)

          if result[:success]
            blob.update(
              classificacao: result[:classification],
              descricao_avaliador: result[:description],
              ai_generated: true
            )
          end

          resultados << {
            documento: blob.filename,
            sucesso: result[:success],
            classificacao: result[:classification]
          }
        end

        render json: {
          message: "Avaliação em lote concluída",
          resultados: resultados
        }
    end

    def marcar_revisado
        attachment = ActiveStorage::Attachment.find(params[:id])
        blob = attachment.blob

        blob.update(
            reviewed_by_appraiser: true,
            appraiser_id: current_appraiser.id
        )

        render json: { success: true }
    end

    def show
        @modelo = ModeloAplicado.find(params[:id])
    end
end

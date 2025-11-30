class AplicarController < ApplicationController
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
        @expertise_areas = ModeloAplicado.distinct.pluck(:dominio).compact
        @instituicoes = ModeloAplicado.distinct.pluck(:instituicao).compact
        @metodos = ModeloAplicado.distinct.pluck(:metodo).compact
    end

    def atualizar_opcao

        @opcao = params[:opcao]
        @modelo = params[:modelo]
        redirect_url = url_for(controller: :aplicar, action: :index, opcao: @opcao, modelo: @modelo)
        render json: { redirect_url: redirect_url }

    end

    def salvar_processo_docs
        @processo = Processo.find(params[:id])
        @processo.docs.attach(params[:docs])

        documento_id = @processo.docs.last.id

        @attachment = ActiveStorage::Attachment.find(documento_id)
        blob = @attachment.blob
        blob.update(descricao: params[:descricao])
        blob.update(modelo: params[:modelo])

        @opcao = params[:opcao]
        @modelo = params[:modelo]
        @dimensao = @processo.dimensao

        respond_to do |format|
            format.html { redirect_to aplicar_path(opcao: @opcao, modelo: @modelo) }
            format.js
        end
    end

    def excluir_processo_docs

        attachment = ActiveStorage::Attachment.find(params[:id])  # Substitua params[:id] pelo ID correto
        attachment.purge

        opcao = params[:opcao]
        modelo = params[:modelo]

        redirect_to aplicar_path(opcao: opcao, modelo: modelo)
    end

    def salvar_resultado_docs
        @resultado = Resultado.find(params[:id])
        @resultado.docs.attach(params[:docs])

        documento_id = @resultado.docs.last.id

        @attachment = ActiveStorage::Attachment.find(documento_id)
        blob = @attachment.blob
        blob.update(descricao: params[:descricao])
        blob.update(modelo: params[:modelo])

        @opcao = params[:opcao]
        @modelo = params[:modelo]
        @dimensao = @resultado.processo.dimensao

        respond_to do |format|
            format.html { redirect_to aplicar_path(opcao: @opcao, modelo: @modelo) }
            format.js
        end
    end

    def excluir_resultado_docs
        attachment = ActiveStorage::Attachment.find(params[:id])
        attachment.purge

        opcao = params[:opcao]
        modelo = params[:modelo]

        respond_to do |format|
            format.html { redirect_to aplicar_path(opcao: opcao, modelo: modelo) }
            format.js
        end
    end

    def atualizar_descricao_doc
        attachment = ActiveStorage::Attachment.find(params[:id])
        blob = attachment.blob
        blob.update(descricao: params[:descricao])
        opcao = params[:opcao] || params[:modelo]
        modelo = params[:modelo] || params[:opcao]
        redirect_to aplicar_path(opcao: opcao, modelo: modelo)
    end

end

class CadastroController < ApplicationController
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

    #dimensao

    def incluir_dimensao
        dimensao = Dimensao.new
        dimensao.descricao = params[:descricao]
        dimensao.maturidade_id = params[:maturidade_id]
        dimensao.save
        
        redirect_to "/cadastro"
    end

    def salvar_dimensao
        dimensao = Dimensao.find(params[:id])
        dimensao.descricao = params[:descricao]
        dimensao.save

        redirect_to "/cadastro"
    end

    def excluir_dimensao
        dimensao = Dimensao.find(params[:id])
        dimensao.destroy
        redirect_to "/cadastro"
    end

    def alterar_dimensao
        dimensao = Dimensao.new
        dimensao.descricao = params[:descricao]
        dimensao.maturidade_id = params[:maturidade_id]
        dimensao.save

        redirect_to "/cadastro"
    end
        
        #processos

    def incluir_processo
        processo = Processo.new
        processo.descricao = params[:descricao]
        processo.dimensao_id = params[:dimensao_id]
        processo.save
        
        redirect_to "/cadastro"
    end

    def salvar_processo
        processo = Processo.find(params[:id])
        processo.descricao = params[:descricao]
        processo.save

        redirect_to "/cadastro"
    end

    def excluir_processo
        processo = Processo.find(params[:id])
        processo.destroy
        redirect_to "/cadastro"
    end

    def alterar_processo
        processo = Processo.new
        processo.descricao = params[:descricao]
        processo.save
    end

    def salvar_processo_docs
        processo = Processo.find(params[:id])
        processo.docs.attach(params[:docs])
        
        documento_id = processo.docs.last.id

        attachment = ActiveStorage::Attachment.find(documento_id)
        blob = attachment.blob  # Obtém o blob associado ao attachment
        blob.update(descricao: params[:descricao])
        

        redirect_to "/aplicar"
    end

    def salvar_processo_nivel
        processo = Processo.find(params[:id])
        processo.nivel_selecionado = params[:nivel_selecionado]
        processo.save
    end

    def excluir_processo_docs

        attachment = ActiveStorage::Attachment.find(params[:id])  # Substitua params[:id] pelo ID correto
        attachment.purge

        redirect_to "/aplicar"
    end


        #resultados

    def incluir_resultado
        resultado = Resultado.new
        resultado.descricao = params[:descricao]
        resultado.processo_id = params[:processo_id]
        resultado.save
        
        redirect_to "/cadastro"
    end

    def salvar_resultado
        resultado = Resultado.find(params[:id])
        resultado.descricao = params[:descricao]
        resultado.save

        redirect_to "/cadastro"
    end

    def excluir_resultado
        resultado = Resultado.find(params[:id])
        resultado.destroy
        redirect_to "/cadastro"
    end

    def alterar_resultado
        resultado = Resultado.new
        resultado.descricao = params[:descricao]
        resultado.save
    end

    def salvar_resultado_docs
        resultado = Resultado.find(params[:id])
        resultado.docs.attach(params[:docs])

        documento_id = resultado.docs.last.id

        attachment = ActiveStorage::Attachment.find(documento_id)
        blob = attachment.blob
        blob.update(descricao: params[:descricao])
        
        redirect_to "/aplicar"
    end

    def salvar_resultado_nivel
        resultado = Resultado.find(params[:id])
        resultado.nivel_selecionado = params[:nivel_selecionado]
        resultado.save

        redirect_to "/cadastro"
    end

    def excluir_resultado_docs

        attachment = ActiveStorage::Attachment.find(params[:id])  
        attachment.purge

        redirect_to "/aplicar"
    end

    def salvar_classificacao_docs

        attachment = ActiveStorage::Attachment.find(params[:id])
        blob = attachment.blob  # Obtém o blob associado ao attachment
        blob.update(classificacao: params[:classificacao])
        
    end

    def incluir_maturidade
        maturidade = Maturidade.new
        maturidade.nome = params[:nome]
        maturidade.descricao = params[:descricao]
        maturidade.tipoNivel = params[:tipoNivel]
        maturidade.menorNivel = params[:menorNivel]
        maturidade.maiorNivel = params[:maiorNivel]
        maturidade.resultadoEscolha = params[:resultadoEscolha]
        maturidade.nivelEscolha = params[:nivelEscolha]
        maturidade.save
        
        redirect_to "/main_screen"
    end

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

        redirect_to "/main_screen"
    end

    def excluir_maturidade
        maturidade = Maturidade.find(params[:id])
        maturidade.destroy
        redirect_to "/main_screen"
    end

    def atualizar_opcao

        @opcao = params[:opcao]
        render json: { redirect_url: root_path(opcao: @opcao) }

    end

    #modelos aplicados

    def incluir_modelo_aplicado
        modelo_aplicado = ModeloAplicado.new
        modelo_aplicado.metodo = params[:metodo]
        modelo_aplicado.instituicao = params[:instituicao]
        modelo_aplicado.dominio_id = params[:dominio_id]
        modelo_aplicado.maturidade_id = params[:maturidade_id]
        modelo_aplicado.save

        redirect_to "/aplicar"
    end

    #dominio

    def incluir_dominio
        dominio = Dominio.new
        dominio.nome = params[:nome]
        dominio.save
        
        redirect_to "/aplicar"
    end

end

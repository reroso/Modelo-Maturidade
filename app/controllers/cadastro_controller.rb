class CadastroController < ApplicationController
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

    #dimensao

    def incluir_dimensao
        dimensao = Dimensao.new
        dimensao.descricao = params[:descricao]
        dimensao.maturidade_id = params[:maturidade_id]
        dimensao.save

        opcao = params[:maturidade_id]
        redirect_to cadastro_path(opcao: opcao)
    end

    def salvar_dimensao
        dimensao = Dimensao.find(params[:id])
        dimensao.descricao = params[:descricao]
        dimensao.save

        opcao = params[:opcao]
        redirect_to cadastro_path(opcao: opcao)
    end

    def excluir_dimensao
        dimensao = Dimensao.find(params[:id])
        dimensao.destroy

        opcao = params[:opcao]
        redirect_to cadastro_path(opcao: opcao)
    end

    def alterar_dimensao
        dimensao = Dimensao.new
        dimensao.descricao = params[:descricao]
        dimensao.maturidade_id = params[:maturidade_id]
        dimensao.save

        redirect_to "/cadastro"
    end

    def salvar_dimensao_nivel
        dimensao = Dimensao.find(params[:id])
        dimensao.nivel_selecionado = params[:nivel_selecionado]
        dimensao.save
    end

        #processos

    def incluir_processo
        processo = Processo.new
        processo.descricao = params[:descricao]
        processo.dimensao_id = params[:dimensao_id]
        processo.save

        opcao = params[:opcao]
        redirect_to cadastro_path(opcao: opcao)
    end

    def salvar_processo
        processo = Processo.find(params[:id])
        processo.descricao = params[:descricao]
        processo.save

        opcao = params[:opcao]
        redirect_to cadastro_path(opcao: opcao)
    end

    def excluir_processo #######
        processo = Processo.find(params[:id])
        processo.destroy

        opcao = params[:opcao]
        redirect_to cadastro_path(opcao: opcao)
    end

    def alterar_processo
        processo = Processo.new
        processo.descricao = params[:descricao]
        processo.save
    end

    def salvar_processo_nivel
        processo = Processo.find(params[:id])
        processo.nivel_selecionado = params[:nivel_selecionado]
        processo.save
    end


        #resultados

    def incluir_resultado
        resultado = Resultado.new
        resultado.descricao = params[:descricao]
        resultado.processo_id = params[:processo_id]
        resultado.save

        opcao = params[:opcao]
        redirect_to cadastro_path(opcao: opcao)
    end

    def salvar_resultado
        resultado = Resultado.find(params[:id])
        resultado.descricao = params[:descricao]
        resultado.save

        opcao = params[:opcao]
        redirect_to cadastro_path(opcao: opcao)
    end

    def excluir_resultado
        resultado = Resultado.find(params[:id])
        resultado.destroy

        opcao = params[:opcao]
        redirect_to cadastro_path(opcao: opcao)
    end

    def alterar_resultado
        resultado = Resultado.new
        resultado.descricao = params[:descricao]
        resultado.save
    end

    def salvar_resultado_nivel
        resultado = Resultado.find(params[:id])
        resultado.nivel_selecionado = params[:nivel_selecionado]
        resultado.save
    end

    def salvar_classificacao_docs

        attachment = ActiveStorage::Attachment.find(params[:id])
        blob = attachment.blob  # Obtém o blob associado ao attachment
        blob.update(classificacao: params[:classificacao])

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
        render json: { redirect_url: cadastro_path(opcao: @opcao) }

    end

end

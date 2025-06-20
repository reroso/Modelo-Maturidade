class CadastroController < ApplicationController
    before_action :authenticate_admin!
    def index
        @dimensaos = Dimensao.all
        @processos = Processo.all
        @resultados = Resultado.all
        @maturidades = Maturidade.all
        @opcao = params[:opcao].to_i
        @modelo_aplicados = ModeloAplicado.all
        @levels = Level.all
    end

    #dimensao

    def incluir_dimensao
        dimensao = Dimensao.new
        dimensao.descricao = params[:descricao]
        dimensao.maturidade_id = params[:maturidade_id]
        dimensao.save

        respond_to do |format|
            format.html { redirect_to cadastro_path(opcao: params[:maturidade_id]) }
            format.json { render json: { id: dimensao.id, descricao: dimensao.descricao, maturidade_id: dimensao.maturidade_id } }
        end
    end

    def salvar_dimensao
        dimensao = Dimensao.find(params[:id])
        dimensao.descricao = params[:descricao]
        dimensao.save

        respond_to do |format|
            format.html { redirect_to cadastro_path(opcao: params[:opcao]) }
            format.json { render json: { id: dimensao.id, descricao: dimensao.descricao } }
        end
    end

    def excluir_dimensao
        dimensao = Dimensao.find(params[:id])
        dimensao.destroy

        respond_to do |format|
            format.html { redirect_to cadastro_path(opcao: params[:opcao]) }
            format.json { render json: { id: params[:id] } }
        end
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

        respond_to do |format|
            format.html {
                opcao = params[:opcao]
                redirect_to cadastro_path(opcao: opcao)
            }
            format.json {
                render json: { id: processo.id, descricao: processo.descricao, dimensao_id: processo.dimensao_id }
            }
        end
    end

    def salvar_processo
        processo = Processo.find(params[:id])
        processo.descricao = params[:descricao]
        processo.save

        respond_to do |format|
            format.html { opcao = params[:opcao]; redirect_to cadastro_path(opcao: opcao) }
            format.json { render json: { id: processo.id, descricao: processo.descricao, dimensao_id: processo.dimensao_id } }
        end
    end

    def excluir_processo
        processo = Processo.find(params[:id])
        dimensao_id = processo.dimensao_id
        processo.destroy

        respond_to do |format|
            format.html { opcao = params[:opcao]; redirect_to cadastro_path(opcao: opcao) }
            format.json { render json: { id: params[:id], dimensao_id: dimensao_id } }
        end
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
        begin
            Rails.logger.info "Parâmetros recebidos: #{params.inspect}"

            resultado = Resultado.new
            resultado.descricao = params[:descricao]
            resultado.processo_id = params[:processo_id]

            if resultado.save
                processo = resultado.processo
                dimensao = processo.dimensao

                respond_to do |format|
                    format.html {
                        redirect_to cadastro_path(opcao: params[:opcao])
                    }
                    format.json {
                        render json: {
                            id: resultado.id,
                            descricao: resultado.descricao,
                            processo_id: processo.id,
                            dimensao_id: dimensao.id
                        }, status: :created
                    }
                end
            else
                respond_to do |format|
                    format.html {
                        redirect_to cadastro_path(opcao: params[:opcao]), alert: 'Erro ao criar resultado'
                    }
                    format.json {
                        render json: {
                            message: 'Erro ao criar resultado',
                            errors: resultado.errors.full_messages
                        }, status: :unprocessable_entity
                    }
                end
            end
        rescue => e
            Rails.logger.error "Erro ao criar resultado: #{e.message}"
            Rails.logger.error e.backtrace.join("\n")

            respond_to do |format|
                format.html {
                    redirect_to cadastro_path(opcao: params[:opcao]), alert: 'Erro interno ao criar resultado'
                }
                format.json {
                    render json: {
                        message: 'Erro interno ao criar resultado',
                        error: e.message
                    }, status: :internal_server_error
                }
            end
        end
    end

    def salvar_resultado
        resultado = Resultado.find(params[:id])
        resultado.descricao = params[:descricao]
        resultado.save

        respond_to do |format|
            format.html {
                opcao = params[:opcao]
                redirect_to cadastro_path(opcao: opcao)
            }
            format.json {
                processo = resultado.processo
                dimensao = processo.dimensao
                render json: {
                    id: resultado.id,
                    descricao: resultado.descricao,
                    processo_id: processo.id,
                    dimensao_id: dimensao.id
                }
            }
        end
    end

    def excluir_resultado
        resultado = Resultado.find(params[:id])
        processo = resultado.processo
        dimensao = processo.dimensao
        resultado.destroy

        respond_to do |format|
            format.html { redirect_to cadastro_path(opcao: params[:opcao]) }
            format.json { render json: { id: params[:id], processo_id: processo.id, dimensao_id: dimensao.id } }
        end
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

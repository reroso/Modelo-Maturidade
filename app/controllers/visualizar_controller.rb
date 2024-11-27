class VisualizarController < ApplicationController
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

        if @modelo != 0
            prepare_chart_data
            @nivel_atual = avaliar_nivel_maturidade
        end
    end

    def atualizar_opcao
        @opcao = params[:opcao]
        @modelo = params[:modelo]
        redirect_url = url_for(controller: :visualizar, action: :index, opcao: @opcao, modelo: @modelo)
        render json: { redirect_url: redirect_url }
    end

    private

    def avaliar_nivel_maturidade
        return 0 if @modelo == 0

        modelo_aplicado = ModeloAplicado.find(@modelo)
        maturidade = Maturidade.find(modelo_aplicado.maturidade_id)
        vetor_resultado = []
        menor_contador = maturidade.maiorNivel.to_i

        # Itera sobre os níveis do menor ao maior
        while menor_contador >= maturidade.menorNivel.to_i
            case maturidade.nivelEscolha
            when "2" # Resultados
                @dimensaos.each do |dimensao|
                    if dimensao.maturidade_id == @opcao
                        @processos.each do |processo|
                            if dimensao.id == processo.dimensao_id
                                @resultados.each do |resultado|
                                    if processo.id == resultado.processo_id && resultado.nivel_selecionado.to_i == menor_contador
                                        resultado.docs.each do |doc|
                                            if doc.modelo == @modelo && (doc.classificacao == 3 || doc.classificacao == 2)
                                                vetor_resultado.push(menor_contador-1)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            when "1" # Processos
                @dimensaos.each do |dimensao|
                    if dimensao.maturidade_id == @opcao
                        @processos.each do |processo|
                            if dimensao.id == processo.dimensao_id && processo.nivel_selecionado.to_i == menor_contador
                                processo.docs.each do |doc|
                                    if doc.modelo == @modelo && (doc.classificacao == 3 || doc.classificacao == 2)
                                        vetor_resultado.push(menor_contador-1)
                                    end
                                end
                            end
                        end
                    end
                end
            when "3" # Dimensões
                @dimensaos.each do |dimensao|
                    if dimensao.maturidade_id == @opcao
                        @processos.each do |processo|
                            if dimensao.id == processo.dimensao_id && processo.nivel_selecionado.to_i == menor_contador
                                processo.docs.each do |doc|
                                    if doc.modelo == @modelo && (doc.classificacao == 3 || doc.classificacao == 2)
                                        vetor_resultado.push(menor_contador-1)
                                    end
                                end
                            end
                        end
                    end
                end
            end
            menor_contador -= 1
        end

        # Calcula o nível final
        if vetor_resultado.empty?
            nivel = maturidade.menorNivel
        else
            if maturidade.menorNivel.to_s < maturidade.maiorNivel.to_s
                if maturidade.menorNivel.to_s > vetor_resultado[0].to_s
                    nivel = maturidade.menorNivel
                else
                    nivel = vetor_resultado[0]
                end
            else
                if maturidade.menorNivel.to_s < vetor_resultado[0].to_s
                    nivel = maturidade.menorNivel
                else
                    nivel = vetor_resultado[0]
                end
            end
        end

        nivel
    end

    def prepare_chart_data
        # Inicializa contadores para cada classificação
        @nao_atende = 0
        @atende_parcialmente = 0
        @atende_totalmente = 0
        @nao_classificado = 0

        # Conta documentos por classificação
        @processos.each do |processo|
            processo.docs.each do |doc|
                if doc.modelo == @modelo
                    case doc.classificacao
                    when 1
                        @atende_totalmente += 1
                    when 2
                        @atende_parcialmente += 1
                    when 3
                        @nao_atende += 1
                    when nil
                        @nao_classificado += 1
                    end
                end
            end
        end

        # Prepara dados para o gráfico
        @chart_data = {
            labels: ['Não Atende', 'Atende Parcialmente', 'Atende Totalmente', 'Não Classificado'],
            datasets: [{
                data: [@nao_atende, @atende_parcialmente, @atende_totalmente, @nao_classificado],
                backgroundColor: ['#dc3545', '#ffc107', '#28a745', '#6c757d']
            }]
        }
    end
end
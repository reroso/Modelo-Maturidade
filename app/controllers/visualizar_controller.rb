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
        end
    end

    def atualizar_opcao
        @opcao = params[:opcao]
        @modelo = params[:modelo]
        redirect_url = url_for(controller: :visualizar, action: :index, opcao: @opcao, modelo: @modelo)
        render json: { redirect_url: redirect_url }
    end

    private

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

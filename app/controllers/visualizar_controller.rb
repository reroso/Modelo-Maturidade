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
            prepare_general_chart_data
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
        is_alpha = maturidade.menorNivel.to_s.match?(/[A-Za-z]/)
        if is_alpha
            nivel_atual = maturidade.menorNivel.upcase.ord - 64
            maior_nivel = maturidade.maiorNivel.upcase.ord - 64
            niveis = (maior_nivel..nivel_atual).to_a.reverse
        else
            nivel_atual = maturidade.menorNivel.to_i
            maior_nivel = maturidade.maiorNivel.to_i
            niveis = (nivel_atual..maior_nivel).to_a
        end

        nivel_resultado = nil
        resumo_docs = {}

        niveis.each_with_index do |nivel_num, idx|
            nivel = is_alpha ? (nivel_num + 64).chr : nivel_num.to_s
            docs_nivel = []
            case maturidade.nivelEscolha
            when "2"
                @dimensaos.each do |dimensao|
                    next unless dimensao.maturidade_id == @opcao
                    @processos.each do |processo|
                        next unless dimensao.id == processo.dimensao_id
                        @resultados.each do |resultado|
                            if processo.id == resultado.processo_id && resultado.nivel_selecionado.to_s == nivel.to_s
                                resultado.docs.each do |doc|
                                    docs_nivel << doc if doc.modelo == @modelo
                                end
                            end
                        end
                    end
                end
            when "1"
                @dimensaos.each do |dimensao|
                    next unless dimensao.maturidade_id == @opcao
                    @processos.each do |processo|
                        if dimensao.id == processo.dimensao_id && processo.nivel_selecionado.to_s == nivel.to_s
                            processo.docs.each do |doc|
                                docs_nivel << doc if doc.modelo == @modelo
                            end
                        end
                    end
                end
            when "3"
                @dimensaos.each do |dimensao|
                    next unless dimensao.maturidade_id == @opcao
                    @processos.each do |processo|
                        if dimensao.id == processo.dimensao_id && processo.nivel_selecionado.to_s == nivel.to_s
                            processo.docs.each do |doc|
                                docs_nivel << doc if doc.modelo == @modelo
                            end
                        end
                    end
                end
            end

            docs_avaliados = docs_nivel.select { |doc| [1, 2, 3].include?(doc.classificacao) }
            resumo_docs[nivel] = {
                total: docs_nivel.count,
                avaliados: docs_avaliados.count,
                classificacoes: docs_avaliados.map(&:classificacao)
            }

            # Se não houver documentos neste nível, para a avaliação
            if docs_nivel.empty? || docs_avaliados.empty?
                break
            end

            todos_atendem = docs_avaliados.all? { |doc| doc.classificacao == 1 }

            # Se for o menor nível e não atender totalmente, retorna imediatamente
            if idx == 0 && !todos_atendem
                return "Abaixo do nível mínimo"
            end

            # Só atualiza o nível resultado se todos atenderem
            if todos_atendem
                nivel_resultado = nivel_num
            else
                break
            end
        end

        # Se não atingiu nenhum nível, retorna abaixo do mínimo
        return "Abaixo do nível mínimo" if nivel_resultado.nil?
        is_alpha ? (nivel_resultado + 64).chr : nivel_resultado
    end

    def prepare_chart_data
        Rails.logger.debug "\n=== PREPARANDO DADOS DO GRÁFICO ==="
        Rails.logger.debug "Modelo selecionado: #{@modelo}"

        return if @modelo == 0

        modelo_aplicado = ModeloAplicado.find(@modelo)
        maturidade = Maturidade.find(modelo_aplicado.maturidade_id)

        # Determina os níveis disponíveis
        is_alpha = maturidade.menorNivel.to_s.match?(/[A-Za-z]/)
        if is_alpha
            nivel_atual = maturidade.menorNivel.upcase.ord - 64
            maior_nivel = maturidade.maiorNivel.upcase.ord - 64
            niveis = (maior_nivel..nivel_atual).to_a.reverse.map { |n| (n + 64).chr }
        else
            nivel_atual = maturidade.menorNivel.to_i
            maior_nivel = maturidade.maiorNivel.to_i
            niveis = (nivel_atual..maior_nivel).to_a
        end

        Rails.logger.debug "Níveis disponíveis: #{niveis.inspect}"

        @chart_data_por_nivel = {}

        niveis.each do |nivel|
            processos_do_nivel = []
            dados_processos = {}

            case maturidade.nivelEscolha
            when "2" # Resultados
                @dimensaos.each do |dimensao|
                    next unless dimensao.maturidade_id == @opcao

                    @processos.each do |processo|
                        next unless dimensao.id == processo.dimensao_id

                        @resultados.each do |resultado|
                            next unless processo.id == resultado.processo_id &&
                                      resultado.nivel_selecionado.to_s == nivel.to_s

                            # Adiciona o processo se ainda não estiver na lista
                            unless processos_do_nivel.include?(processo.descricao)
                                processos_do_nivel << processo.descricao
                                dados_processos[processo.descricao] = {
                                    total_docs: 0,
                                    docs_atende_totalmente: 0
                                }
                            end

                            # Conta os documentos deste processo
                            resultado.docs.each do |doc|
                                next unless doc.modelo == @modelo

                                dados_processos[processo.descricao][:total_docs] += 1
                                if doc.classificacao == 1 # Atende Totalmente
                                    dados_processos[processo.descricao][:docs_atende_totalmente] += 1
                                end
                            end
                        end
                    end
                end

            when "1" # Processos
                @dimensaos.each do |dimensao|
                    next unless dimensao.maturidade_id == @opcao

                    @processos.each do |processo|
                        next unless dimensao.id == processo.dimensao_id &&
                                  processo.nivel_selecionado.to_s == nivel.to_s

                        # Adiciona o processo
                        processos_do_nivel << processo.descricao
                        dados_processos[processo.descricao] = {
                            total_docs: 0,
                            docs_atende_totalmente: 0
                        }

                        # Conta os documentos deste processo
                        processo.docs.each do |doc|
                            next unless doc.modelo == @modelo

                            dados_processos[processo.descricao][:total_docs] += 1
                            if doc.classificacao == 1 # Atende Totalmente
                                dados_processos[processo.descricao][:docs_atende_totalmente] += 1
                            end
                        end
                    end
                end
            end

            next if processos_do_nivel.empty?

            # Calcula as porcentagens para cada processo
            porcentagens = processos_do_nivel.map do |processo|
                dados = dados_processos[processo]
                if dados[:total_docs] > 0
                    (dados[:docs_atende_totalmente].to_f / dados[:total_docs] * 100).round(1)
                else
                    0.0
                end
            end

            # Prepara dados do gráfico radar para este nível
            @chart_data_por_nivel[nivel] = {
                labels: processos_do_nivel,
                datasets: [{
                    label: "Atendimento Total dos Processos - Nível #{nivel}",
                    data: porcentagens,
                    fill: true,
                    backgroundColor: 'rgba(75, 192, 192, 0.2)',
                    borderColor: 'rgb(75, 192, 192)',
                    borderWidth: 2,
                    pointBackgroundColor: 'rgb(75, 192, 192)',
                    pointBorderColor: '#fff',
                    pointHoverBackgroundColor: '#fff',
                    pointHoverBorderColor: 'rgb(75, 192, 192)',
                    pointRadius: 5,
                    pointHoverRadius: 7
                }]
            }

            Rails.logger.debug "\nNível #{nivel}:"
            processos_do_nivel.each_with_index do |processo, index|
                Rails.logger.debug "  #{processo}:"
                Rails.logger.debug "    Total de documentos: #{dados_processos[processo][:total_docs]}"
                Rails.logger.debug "    Documentos que atendem totalmente: #{dados_processos[processo][:docs_atende_totalmente]}"
                Rails.logger.debug "    Porcentagem: #{porcentagens[index]}%"
            end
        end

        Rails.logger.debug "=== FIM DA PREPARAÇÃO DOS DADOS DO GRÁFICO ===\n"

        @chart_data_por_nivel
    end

    def prepare_general_chart_data
        Rails.logger.debug "\n=== PREPARANDO DADOS DO GRÁFICO GERAL ==="
        Rails.logger.debug "Modelo selecionado: #{@modelo}"

        return if @modelo == 0

        modelo_aplicado = ModeloAplicado.find(@modelo)
        maturidade = Maturidade.find(modelo_aplicado.maturidade_id)

        # Determina os níveis disponíveis
        is_alpha = maturidade.menorNivel.to_s.match?(/[A-Za-z]/)
        if is_alpha
            nivel_atual = maturidade.menorNivel.upcase.ord - 64
            maior_nivel = maturidade.maiorNivel.upcase.ord - 64
            niveis = (maior_nivel..nivel_atual).to_a.reverse.map { |n| (n + 64).chr }
        else
            nivel_atual = maturidade.menorNivel.to_i
            maior_nivel = maturidade.maiorNivel.to_i
            niveis = (nivel_atual..maior_nivel).to_a
        end

        Rails.logger.debug "Níveis disponíveis: #{niveis.inspect}"

        dados_niveis = {}

        niveis.each do |nivel|
            dados_niveis[nivel] = {
                total_docs: 0,
                docs_atende_totalmente: 0
            }

            case maturidade.nivelEscolha
            when "2" # Resultados
                @dimensaos.each do |dimensao|
                    next unless dimensao.maturidade_id == @opcao

                    @processos.each do |processo|
                        next unless dimensao.id == processo.dimensao_id

                        @resultados.each do |resultado|
                            next unless processo.id == resultado.processo_id &&
                                      resultado.nivel_selecionado.to_s == nivel.to_s

                            resultado.docs.each do |doc|
                                next unless doc.modelo == @modelo

                                dados_niveis[nivel][:total_docs] += 1
                                if doc.classificacao == 1 # Atende Totalmente
                                    dados_niveis[nivel][:docs_atende_totalmente] += 1
                                end
                            end
                        end
                    end
                end

            when "1" # Processos
                @dimensaos.each do |dimensao|
                    next unless dimensao.maturidade_id == @opcao

                    @processos.each do |processo|
                        next unless dimensao.id == processo.dimensao_id &&
                                  processo.nivel_selecionado.to_s == nivel.to_s

                        processo.docs.each do |doc|
                            next unless doc.modelo == @modelo

                            dados_niveis[nivel][:total_docs] += 1
                            if doc.classificacao == 1 # Atende Totalmente
                                dados_niveis[nivel][:docs_atende_totalmente] += 1
                            end
                        end
                    end
                end
            end
        end

        # Calcula as porcentagens para cada nível
        porcentagens = niveis.map do |nivel|
            dados = dados_niveis[nivel]
            if dados[:total_docs] > 0
                (dados[:docs_atende_totalmente].to_f / dados[:total_docs] * 100).round(1)
            else
                0.0
            end
        end

        # Prepara dados do gráfico radar geral
        @general_chart_data = {
            labels: niveis,
            datasets: [{
                label: "Porcentagem de Atendimento Total por Nível",
                data: porcentagens,
                fill: true,
                backgroundColor: 'rgba(54, 162, 235, 0.2)',
                borderColor: 'rgb(54, 162, 235)',
                borderWidth: 2,
                pointBackgroundColor: 'rgb(54, 162, 235)',
                pointBorderColor: '#fff',
                pointHoverBackgroundColor: '#fff',
                pointHoverBorderColor: 'rgb(54, 162, 235)',
                pointRadius: 5,
                pointHoverRadius: 7
            }]
        }

        Rails.logger.debug "\nDados do gráfico geral:"
        niveis.each_with_index do |nivel, index|
            Rails.logger.debug "  Nível #{nivel}:"
            Rails.logger.debug "    Total de documentos: #{dados_niveis[nivel][:total_docs]}"
            Rails.logger.debug "    Documentos que atendem totalmente: #{dados_niveis[nivel][:docs_atende_totalmente]}"
            Rails.logger.debug "    Porcentagem: #{porcentagens[index]}%"
        end
        Rails.logger.debug "=== FIM DA PREPARAÇÃO DOS DADOS DO GRÁFICO GERAL ===\n"

        @general_chart_data
    end

end

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
        
        # Determina se é alfanumérico ou numérico
        is_alpha = maturidade.menorNivel.to_s.match?(/[A-Za-z]/)
        
        if is_alpha
            # Converte letras para números (A=1, B=2, etc) para facilitar comparação
            nivel_atual = maturidade.menorNivel.upcase.ord - 64  # G = 7
            maior_nivel = maturidade.maiorNivel.upcase.ord - 64  # A = 1
            niveis = (maior_nivel..nivel_atual).to_a.reverse # [7,6,5,4,3,2,1] (G->A)
        else
            nivel_atual = maturidade.menorNivel.to_i
            maior_nivel = maturidade.maiorNivel.to_i
            niveis = (nivel_atual..maior_nivel).to_a # Do menor para o maior
        end

        Rails.logger.debug "\n=============================================="
        Rails.logger.debug "=== INICIANDO AVALIAÇÃO DE NÍVEL DE MATURIDADE ==="
        Rails.logger.debug "=============================================="
        Rails.logger.debug "Modelo ID: #{@modelo}"
        Rails.logger.debug "Maturidade ID: #{maturidade.id}"
        Rails.logger.debug "Nível Escolha: #{maturidade.nivelEscolha}"
        Rails.logger.debug "Menor Nível: #{maturidade.menorNivel} (#{nivel_atual})"
        Rails.logger.debug "Maior Nível: #{maturidade.maiorNivel} (#{maior_nivel})"
        Rails.logger.debug "É alfanumérico? #{is_alpha}"
        Rails.logger.debug "Níveis a avaliar: #{niveis.map { |n| is_alpha ? (n + 64).chr : n }.join(', ')}"
        Rails.logger.debug "Quantidade de níveis: #{niveis.count}"
        Rails.logger.debug "Array de níveis: #{niveis.inspect}"
        Rails.logger.debug "=============================================="

        Rails.logger.debug "\n=== VERIFICANDO DADOS INICIAIS ==="
        Rails.logger.debug "Dimensões disponíveis: #{@dimensaos.count}"
        Rails.logger.debug "Processos disponíveis: #{@processos.count}"
        Rails.logger.debug "Resultados disponíveis: #{@resultados.count if defined?(@resultados)}"
        Rails.logger.debug "Opção selecionada (@opcao): #{@opcao}"
        Rails.logger.debug "=============================================="

        nivel_resultado = nivel_atual # Começa com o menor nível
        ultimo_nivel_avaliado = nil
        algum_nivel_avaliado = false
        resumo_docs = {}

        # Itera sobre os níveis do menor ao maior
        niveis.each do |nivel_num|
            nivel = is_alpha ? (nivel_num + 64).chr : nivel_num.to_s
            Rails.logger.debug "\n------------------------------------------"
            Rails.logger.debug "AVALIANDO NÍVEL: #{nivel} (#{nivel_num})"
            Rails.logger.debug "Nível resultado atual: #{is_alpha ? (nivel_resultado + 64).chr : nivel_resultado}"
            Rails.logger.debug "Último nível avaliado: #{ultimo_nivel_avaliado ? (is_alpha ? (ultimo_nivel_avaliado + 64).chr : ultimo_nivel_avaliado) : 'nenhum'}"
            
            docs_nivel = []
            
            case maturidade.nivelEscolha
            when "2" # Resultados
                Rails.logger.debug "Modo de avaliação: Resultados"
                @dimensaos.each do |dimensao|
                    next unless dimensao.maturidade_id == @opcao
                    Rails.logger.debug "  Verificando dimensão #{dimensao.id}"
                    
                    @processos.each do |processo|
                        next unless dimensao.id == processo.dimensao_id
                        Rails.logger.debug "    Verificando processo #{processo.id}"
                        
                        @resultados.each do |resultado|
                            if processo.id == resultado.processo_id && resultado.nivel_selecionado.to_s == nivel.to_s
                                Rails.logger.debug "      Encontrado resultado com nível #{resultado.nivel_selecionado}"
                                resultado.docs.each do |doc|
                                    if doc.modelo == @modelo
                                        docs_nivel << doc
                                        Rails.logger.debug "        Documento encontrado: #{doc.id} (classificação: #{doc.classificacao})"
                                    end
                                end
                            end
                        end
                    end
                end
            when "1" # Processos
                Rails.logger.debug "Modo de avaliação: Processos"
                @dimensaos.each do |dimensao|
                    next unless dimensao.maturidade_id == @opcao
                    Rails.logger.debug "  Verificando dimensão #{dimensao.id}"
                    
                    @processos.each do |processo|
                        if dimensao.id == processo.dimensao_id && processo.nivel_selecionado.to_s == nivel.to_s
                            Rails.logger.debug "    Encontrado processo com nível #{processo.nivel_selecionado}"
                            processo.docs.each do |doc|
                                if doc.modelo == @modelo
                                    docs_nivel << doc
                                    Rails.logger.debug "      Documento encontrado: #{doc.id} (classificação: #{doc.classificacao})"
                                end
                            end
                        end
                    end
                end
            when "3" # Dimensões
                Rails.logger.debug "Modo de avaliação: Dimensões"
                @dimensaos.each do |dimensao|
                    next unless dimensao.maturidade_id == @opcao
                    Rails.logger.debug "  Verificando dimensão #{dimensao.id}"
                    
                    @processos.each do |processo|
                        if dimensao.id == processo.dimensao_id && processo.nivel_selecionado.to_s == nivel.to_s
                            Rails.logger.debug "    Encontrado processo com nível #{processo.nivel_selecionado}"
                            processo.docs.each do |doc|
                                if doc.modelo == @modelo
                                    docs_nivel << doc
                                    Rails.logger.debug "      Documento encontrado: #{doc.id} (classificação: #{doc.classificacao})"
                                end
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

            Rails.logger.debug "Documentos encontrados: #{docs_nivel.count}"
            
            # Se não houver documentos neste nível, mantém o nível anterior e para a avaliação
            if docs_nivel.empty?
                Rails.logger.debug "=> Nenhum documento encontrado neste nível"
                Rails.logger.debug "=> Parando avaliação e mantendo nível anterior: #{is_alpha ? (nivel_resultado + 64).chr : nivel_resultado}"
                break
            end

            # Verifica se há documentos avaliados (classificação 1, 2 ou 3)
            if docs_avaliados.empty?
                Rails.logger.debug "=> Nenhum documento avaliado neste nível"
                Rails.logger.debug "=> Parando avaliação e mantendo nível anterior: #{is_alpha ? (nivel_resultado + 64).chr : nivel_resultado}"
                break
            end

            algum_nivel_avaliado = true
            ultimo_nivel_avaliado = nivel_num
            
            # Verifica se todos os documentos deste nível atendem totalmente
            todos_atendem = docs_avaliados.all? { |doc| doc.classificacao == 1 }
            Rails.logger.debug "Documentos avaliados: #{docs_avaliados.count}"
            Rails.logger.debug "Classificações: #{docs_avaliados.map(&:classificacao).join(', ')}"
            Rails.logger.debug "Todos os documentos atendem? #{todos_atendem}"

            if todos_atendem
                # Se todos atendem, atualiza o nível atual
                nivel_resultado = nivel_num
                Rails.logger.debug "=> SUCESSO: Todos documentos atendem!"
                Rails.logger.debug "=> Atualizando nível para: #{is_alpha ? (nivel_resultado + 64).chr : nivel_resultado}"
            else
                # Se encontrar algum que não atende, mantém o nível anterior
                Rails.logger.debug "=> ATENÇÃO: Nem todos os documentos atendem"
                Rails.logger.debug "=> Parando avaliação e mantendo nível anterior: #{is_alpha ? (nivel_resultado + 64).chr : nivel_resultado}"
                break
            end
        end

        Rails.logger.debug "\n=============================================="
        Rails.logger.debug "=== RESULTADO FINAL ==="
        Rails.logger.debug "Nível final numérico: #{nivel_resultado}"
        Rails.logger.debug "Algum nível foi avaliado? #{algum_nivel_avaliado}"
        
        # Se for alfanumérico, converte o número de volta para letra
        if is_alpha
            nivel_resultado = (nivel_resultado + 64).chr
            Rails.logger.debug "Nível final convertido: #{nivel_resultado}"
        end
        
        Rails.logger.debug "\n=== RESUMO DE DOCUMENTOS POR NÍVEL ==="
        resumo_docs.each do |nivel, info|
            Rails.logger.debug "Nível #{nivel}:"
            Rails.logger.debug "  - Total de documentos: #{info[:total]}"
            Rails.logger.debug "  - Documentos avaliados: #{info[:avaliados]}"
            Rails.logger.debug "  - Classificações: #{info[:classificacoes].join(', ')}"
        end
        Rails.logger.debug "=============================================="
        
        nivel_resultado
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

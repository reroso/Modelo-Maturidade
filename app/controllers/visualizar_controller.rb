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
            prepare_artifact_data
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
        
        # Prepara dados para cada nível
        @chart_data_por_nivel = {}
        
        niveis.each do |nivel|
            classificacoes = {
                atende_totalmente: 0,   # 1
                atende_parcialmente: 0, # 2
                nao_atende: 0,         # 3
                nao_classificado: 0    # nil ou outro
            }
            
            total_docs = 0
            
            case maturidade.nivelEscolha
            when "2" # Resultados
                Rails.logger.debug "Modo de avaliação: Resultados - Nível #{nivel}"
                @dimensaos.each do |dimensao|
                    next unless dimensao.maturidade_id == @opcao
                    
                    @processos.each do |processo|
                        next unless dimensao.id == processo.dimensao_id
                        
                        @resultados.each do |resultado|
                            next unless processo.id == resultado.processo_id && 
                                      resultado.nivel_selecionado.to_s == nivel.to_s
                            
                            resultado.docs.each do |doc|
                                next unless doc.modelo == @modelo
                                
                                total_docs += 1
                                case doc.classificacao
                                when 1 then classificacoes[:atende_totalmente] += 1
                                when 2 then classificacoes[:atende_parcialmente] += 1
                                when 3 then classificacoes[:nao_atende] += 1
                                else classificacoes[:nao_classificado] += 1
                                end
                            end
                        end
                    end
                end
            when "1" # Processos
                Rails.logger.debug "Modo de avaliação: Processos - Nível #{nivel}"
                @dimensaos.each do |dimensao|
                    next unless dimensao.maturidade_id == @opcao
                    
                    @processos.each do |processo|
                        next unless dimensao.id == processo.dimensao_id && 
                                  processo.nivel_selecionado.to_s == nivel.to_s
                        
                        processo.docs.each do |doc|
                            next unless doc.modelo == @modelo
                            
                            total_docs += 1
                            case doc.classificacao
                            when 1 then classificacoes[:atende_totalmente] += 1
                            when 2 then classificacoes[:atende_parcialmente] += 1
                            when 3 then classificacoes[:nao_atende] += 1
                            else classificacoes[:nao_classificado] += 1
                            end
                        end
                    end
                end
            end

            Rails.logger.debug "\nContagem de documentos para nível #{nivel}:"
            Rails.logger.debug "Total de documentos: #{total_docs}"
            classificacoes.each do |tipo, contagem|
                Rails.logger.debug "#{tipo.to_s.humanize}: #{contagem}"
            end

            # Calcula porcentagens
            porcentagens = {}
            if total_docs > 0
                classificacoes.each do |tipo, contagem|
                    porcentagens[tipo] = (contagem.to_f / total_docs * 100).round(1)
                end
            else
                classificacoes.keys.each { |tipo| porcentagens[tipo] = 0.0 }
            end

            # Prepara dados do gráfico para este nível
            @chart_data_por_nivel[nivel] = {
                labels: ['Atende Totalmente', 'Atende Parcialmente', 'Não Atende', 'Não Classificado'],
                datasets: [{
                    label: "Distribuição de Classificações - Nível #{nivel}",
                    data: [
                        porcentagens[:atende_totalmente],
                        porcentagens[:atende_parcialmente],
                        porcentagens[:nao_atende],
                        porcentagens[:nao_classificado]
                    ],
                    fill: true,
                    backgroundColor: 'rgba(75, 192, 192, 0.2)',
                    borderColor: 'rgb(75, 192, 192)',
                    borderWidth: 2,
                    pointBackgroundColor: [
                        'rgb(75, 192, 192)',   # Verde para Atende Totalmente
                        'rgb(255, 205, 86)',   # Amarelo para Atende Parcialmente
                        'rgb(255, 99, 132)',   # Vermelho para Não Atende
                        'rgb(201, 203, 207)'   # Cinza para Não Classificado
                    ],
                    pointBorderColor: '#fff',
                    pointHoverBackgroundColor: '#fff',
                    pointHoverBorderColor: [
                        'rgb(75, 192, 192)',   # Verde
                        'rgb(255, 205, 86)',   # Amarelo
                        'rgb(255, 99, 132)',   # Vermelho
                        'rgb(201, 203, 207)'   # Cinza
                    ],
                    pointRadius: 5,
                    pointHoverRadius: 7
                }]
            }
        end
        
        Rails.logger.debug "\nDados dos gráficos gerados por nível:"
        @chart_data_por_nivel.each do |nivel, data|
            Rails.logger.debug "Nível #{nivel}: #{JSON.pretty_generate(data)}"
        end
        Rails.logger.debug "=== FIM DA PREPARAÇÃO DOS DADOS DO GRÁFICO ===\n"
        
        # Disponibiliza os dados para a view
        @chart_data_por_nivel
    end

    def prepare_artifact_data
        Rails.logger.debug "\n=== PREPARANDO DADOS DOS ARTEFATOS ==="
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

        # Prepara dados para cada nível
        @artifact_data_por_nivel = {}

        niveis.each do |nivel|
            artefatos = []

            case maturidade.nivelEscolha
            when "2" # Resultados
                Rails.logger.debug "Modo de avaliação: Resultados - Nível #{nivel}"
                @dimensaos.each do |dimensao|
                    next unless dimensao.maturidade_id == @opcao

                    @processos.each do |processo|
                        next unless dimensao.id == processo.dimensao_id

                        @resultados.each do |resultado|
                            next unless processo.id == resultado.processo_id && 
                                      resultado.nivel_selecionado.to_s == nivel.to_s

                            resultado.docs.each do |doc|
                                next unless doc.modelo == @modelo

                                artefatos << {
                                    descricao: doc.descricao,
                                    classificacao: doc.classificacao
                                }
                            end
                        end
                    end
                end
            when "1" # Processos
                Rails.logger.debug "Modo de avaliação: Processos - Nível #{nivel}"
                @dimensaos.each do |dimensao|
                    next unless dimensao.maturidade_id == @opcao

                    @processos.each do |processo|
                        next unless dimensao.id == processo.dimensao_id && 
                                  processo.nivel_selecionado.to_s == nivel.to_s

                        processo.docs.each do |doc|
                            next unless doc.modelo == @modelo

                            artefatos << {
                                descricao: doc.descricao,
                                classificacao: doc.classificacao
                            }
                        end
                    end
                end
            end

            @artifact_data_por_nivel[nivel] = artefatos
        end

        Rails.logger.debug "\nDados dos artefatos gerados por nível:"
        @artifact_data_por_nivel.each do |nivel, artefatos|
            Rails.logger.debug "Nível #{nivel}:"
            artefatos.each do |artefato|
                Rails.logger.debug "  - #{artefato[:descricao]}: #{artefato[:classificacao]}"
            end
        end
        Rails.logger.debug "=== FIM DA PREPARAÇÃO DOS DADOS DOS ARTEFATOS ===\n"

        @artifact_data_por_nivel
    end

end

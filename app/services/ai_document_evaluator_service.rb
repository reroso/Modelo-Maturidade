class AiDocumentEvaluatorService
  def initialize
    # Configuração do Ollama local
    @ollama_url = "http://localhost:11434"
  end

  def evaluate_document(document_blob, processo_or_resultado, context = {})
    begin
      # Extrai o conteúdo do documento
      content = extract_document_content(document_blob)

      # Gera o prompt baseado no contexto
      prompt = build_evaluation_prompt(content, processo_or_resultado, context)

      # Chama o Ollama para avaliar
      response = call_ollama(prompt)

      # Parse da resposta
      parse_ai_response(response)

    rescue => e
      Rails.logger.error "Erro na avaliação por IA: #{e.message}"
      {
        success: false,
        error: e.message,
        classification: nil,
        description: "Erro na avaliação automática. Avalie manualmente."
      }
    end
  end

  private

  def extract_document_content(blob)
    case blob.content_type
    when 'application/pdf'
      extract_pdf_content(blob)
    when 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
      extract_docx_content(blob)
    when 'text/plain'
      blob.download
    else
      # Para outros tipos, retorna informações básicas
      "Arquivo: #{blob.filename}\nTipo: #{blob.content_type}\nTamanho: #{blob.byte_size} bytes"
    end
  end

  def extract_pdf_content(blob)
    begin
      reader = PDF::Reader.new(StringIO.new(blob.download))
      content = ""
      reader.pages.each do |page|
        content += page.text + "\n"
      end
      content
    rescue => e
      "Erro ao extrair conteúdo do PDF: #{e.message}"
    end
  end

  def extract_docx_content(blob)
    begin
      doc = Docx::Document.open(StringIO.new(blob.download))
      doc.paragraphs.map(&:text).join("\n")
    rescue => e
      "Erro ao extrair conteúdo do DOCX: #{e.message}"
    end
  end

  def build_evaluation_prompt(content, processo_or_resultado, context)
    base_prompt = <<~PROMPT
      Você é um especialista em avaliação de maturidade organizacional. Sua tarefa é avaliar se um documento/evidência atende aos requisitos de um processo ou resultado específico.

      CONTEXTO DO PROCESSO/RESULTADO:
      Descrição: #{processo_or_resultado.descricao}

      CONTEÚDO DO DOCUMENTO:
      #{content.truncate(3000)}

      CRITÉRIOS DE AVALIAÇÃO:
      1 - Atende Totalmente: O documento apresenta evidências claras e completas que demonstram total conformidade com os requisitos
      2 - Atende Parcialmente: O documento apresenta algumas evidências, mas há lacunas ou informações incompletas
      3 - Não Atende: O documento não apresenta evidências suficientes ou não está relacionado aos requisitos

      INSTRUÇÕES:
      - Analise cuidadosamente o conteúdo do documento
      - Compare com os requisitos do processo/resultado
      - Forneça uma classificação (1, 2 ou 3)
      - Explique de forma clara e objetiva o motivo da classificação
      - Seja específico sobre o que atende ou não atende
      - Mantenha um tom profissional e construtivo

      RESPOSTA ESPERADA:
      Responda APENAS no formato JSON:
      {
        "classificacao": [1, 2 ou 3],
        "justificativa": "Explicação detalhada da avaliação, mencionando pontos específicos do documento"
      }
    PROMPT

    if context[:expertise_area]
      base_prompt += "\nÁREA DE EXPERTISE: #{context[:expertise_area]}"
    end

    if context[:nivel_selecionado]
      base_prompt += "\nNÍVEL DE MATURIDADE ESPERADO: #{context[:nivel_selecionado]}"
    end

    base_prompt
  end

  def call_ollama(prompt)
    Rails.logger.info "=== DEBUG: Iniciando chamada para Ollama ==="
    Rails.logger.info "Prompt: #{prompt[0..200]}..."

    begin
      require 'net/http'
      require 'json'

      uri = URI("#{@ollama_url}/api/generate")
      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = 120  # 2 minutos apenas
      http.open_timeout = 10   # 10 segundos para conectar

      request = Net::HTTP::Post.new(uri)
      request['Content-Type'] = 'application/json'
      request.body = {
        model: "phi3",
        prompt: prompt,
        stream: true,  # Usar streaming para resposta mais rápida
        options: {
          temperature: 0.3,
          top_p: 0.9,
          num_predict: 300,  # Reduzir ainda mais
          num_ctx: 1024      # Reduzir contexto
        }
      }.to_json

      Rails.logger.info "=== DEBUG: Enviando requisição para Ollama (streaming) ==="
      response = http.request(request)

      if response.code == '200'
        # Processar streaming response
        full_response = ""
        response.body.each_line do |line|
          next if line.strip.empty?
          begin
            chunk = JSON.parse(line)
            if chunk["response"]
              full_response += chunk["response"]
            end
            break if chunk["done"]  # Fim da resposta
          rescue JSON::ParserError
            next
          end
        end

        Rails.logger.info "=== DEBUG: Resposta completa (streaming) ==="
        Rails.logger.info full_response.inspect
        full_response
      else
        Rails.logger.error "Erro na resposta do Ollama: #{response.code} - #{response.body}"
        nil
      end

    rescue => e
      Rails.logger.error "=== DEBUG: Erro na chamada do Ollama ==="
      Rails.logger.error e.message
      nil
    end
  end

  def parse_ai_response(response_text)
    begin
      # Verifica se a resposta não é nula
      if response_text.nil? || response_text.empty?
        return {
          success: false,
          error: "Resposta da IA vazia ou nula",
          classification: nil,
          description: "Erro na avaliação automática. Avalie manualmente.",
          raw_response: response_text
        }
      end

      # Remove possíveis marcadores de código
      clean_response = response_text.gsub(/```json|```/, '').strip

      parsed = JSON.parse(clean_response)

      {
        success: true,
        classification: parsed["classificacao"],
        description: parsed["justificativa"],
        ai_generated: true
      }
    rescue JSON::ParserError => e
      # Se não conseguir parsear, tenta extrair informações básicas
      Rails.logger.error "Erro ao parsear resposta da IA: #{e.message}"
      Rails.logger.error "Resposta original: #{response_text}"

      {
        success: false,
        error: "Resposta da IA em formato inválido",
        classification: nil,
        description: "Erro na avaliação automática. Avalie manualmente.",
        raw_response: response_text
      }
    rescue => e
      # Captura qualquer outro erro
      Rails.logger.error "Erro inesperado ao processar resposta da IA: #{e.message}"
      Rails.logger.error "Resposta original: #{response_text}"

      {
        success: false,
        error: "Erro inesperado na avaliação por IA",
        classification: nil,
        description: "Erro na avaliação automática. Avalie manualmente.",
        raw_response: response_text
      }
    end
  end
end

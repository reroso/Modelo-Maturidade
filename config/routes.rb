Rails.application.routes.draw do
  root to: 'cadastro#index'
  get "/main_screen", to: "main_screen#index"
  get "/cadastro", to: "cadastro#index"
  get "/cadastroProcesso", to: "cadastro#indexProcesso"
  get "/cadastroResultado", to: "cadastro#indexResultado"
  get "/cadastroMaturidade", to: "cadastro#indexMaturidade"
  get "/cadastroDominio", to: "cadastro#indexDominio"
  get "/aplicar", to: "aplicar#index"
  get "/cadastroModeloAplicado", to: "aplicar#indexModeloAplicado"

  #dimensaos

  post "/cadastro/incluir_dimensao", to: "cadastro#incluir_dimensao"
  post "/cadastro/alterar_dimensao", to: "cadastro#alterar_dimensao"
  post "/cadastro/:id/salvar_dimensao", to: "cadastro#salvar_dimensao"
  get "/cadastro/:id/excluir_dimensao", to: "cadastro#excluir_dimensao"
  get '/cadastro/:id', to: 'cadastro#mostrar'

  #processos
  
  post "/cadastroProcesso/incluir_processo", to: "cadastro#incluir_processo"
  post "/cadastroProcesso/alterar_processo", to: "cadastro#alterar_processo"
  post "/cadastroProcesso/:id/salvar_processo", to: "cadastro#salvar_processo"
  get "/cadastroProcesso/:id/excluir_processo", to: "cadastro#excluir_processo"
  get '/cadastroProcesso/:id', to: 'cadastro#mostrar_processo'
  post "/cadastroProcesso/:id/salvar_processo_docs", to: "cadastro#salvar_processo_docs"
  post "/cadastroProcesso/:id/salvar_processo_nivel", to: "cadastro#salvar_processo_nivel"
  get "/cadastroProcesso/:id/excluir_processo_docs", to: "cadastro#excluir_processo_docs"

  #resultados
  
  post "/cadastroResultado/incluir_resultado", to: "cadastro#incluir_resultado"
  post "/cadastroResultado/alterar_resultado", to: "cadastro#alterar_resultado"
  post "/cadastroResultado/:id/salvar_resultado", to: "cadastro#salvar_resultado"
  get "/cadastroResultado/:id/excluir_resultado", to: "cadastro#excluir_resultado"
  get '/cadastroResultado/:id', to: 'cadastro#mostrar_resultado'
  post "/cadastroResultado/:id/salvar_resultado_docs", to: "cadastro#salvar_resultado_docs"
  post "/cadastroResultado/:id/salvar_resultado_nivel", to: "cadastro#salvar_resultado_nivel"
  post "/cadastroResultado/:id/excluir_resultado_docs", to: "cadastro#excluir_resultado_docs"
  
  #maturidades
  
  post "/cadastroMaturidade/incluir_maturidade", to: "cadastro#incluir_maturidade"
  post "/cadastroMaturidade/alterar_maturidade", to: "cadastro#alterar_maturidade"
  post "/cadastroMaturidade/:id/salvar_maturidade", to: "cadastro#salvar_maturidade"
  get "/cadastroMaturidade/:id/excluir_maturidade", to: "cadastro#excluir_maturidade"
  get '/cadastroMaturidade/:id', to: 'cadastro#mostrar_maturidade'

  #dominio

  post "/cadastroDominio/incluir_dominio", to: "cadastro#incluir_dominio"

  #modelos aplicados

  post "/cadastroModeloAplicado/incluir_modelo_aplicado", to: "cadastro#incluir_modelo_aplicado"

  #rotas auxiliares
  
  post "cadastro/atualizar_opcao", to:"cadastro#atualizar_opcao"
  post "aplicar/atualizar_opcao", to:"aplicar#atualizar_opcao"
end


Rails.application.routes.draw do
  root to: 'aplicar#index'

  get "/editar", to: "editar#index"
  get "/main_screen", to: "main_screen#index"
  get "/cadastro", to: "cadastro#index"
  get "/cadastroProcesso", to: "cadastro#indexProcesso"
  get "/cadastroResultado", to: "cadastro#indexResultado"
  get "/cadastroMaturidade", to: "cadastro#indexMaturidade"
  get "/cadastroDominio", to: "cadastro#indexDominio"
  get "/selecionar", to: "selecionar#index"
  get "/aplicar", to: "aplicar#index"
  get "/cadastroModeloAplicado", to: "aplicar#indexModeloAplicado"
  get "/avaliar", to: "avaliar#index"
  get "/visualizar", to: "visualizar#index"

  # Expertise Areas
  post "/appraisers/expertise_areas", to: "appraisers/expertise_areas#create"

  #dimensaos

  post "/cadastro/incluir_dimensao", to: "cadastro#incluir_dimensao"
  post "/cadastro/alterar_dimensao", to: "cadastro#alterar_dimensao"
  post "/cadastro/:id/salvar_dimensao", to: "cadastro#salvar_dimensao"
  get "/cadastro/:id/excluir_dimensao", to: "cadastro#excluir_dimensao"
  get '/cadastro/:id', to: 'cadastro#mostrar'
  post "/cadastro/:id/salvar_dimensao_nivel", to: "cadastro#salvar_dimensao_nivel"

  #processos

  post "/cadastroProcesso/incluir_processo", to: "cadastro#incluir_processo"
  post "/cadastroProcesso/alterar_processo", to: "cadastro#alterar_processo"
  post "/cadastroProcesso/:id/salvar_processo", to: "cadastro#salvar_processo"
  get "/cadastroProcesso/:id/excluir_processo", to: "cadastro#excluir_processo"
  get '/cadastroProcesso/:id', to: 'cadastro#mostrar_processo'
  post "/cadastroProcesso/:id/salvar_processo_nivel", to: "cadastro#salvar_processo_nivel"

  #resultados

  post "/cadastroResultado/incluir_resultado", to: "cadastro#incluir_resultado"
  post "/cadastroResultado/alterar_resultado", to: "cadastro#alterar_resultado"
  post "/cadastroResultado/:id/salvar_resultado", to: "cadastro#salvar_resultado"
  get "/cadastroResultado/:id/excluir_resultado", to: "cadastro#excluir_resultado"
  get '/cadastroResultado/:id', to: 'cadastro#mostrar_resultado'
  post "/cadastroResultado/:id/salvar_resultado_nivel", to: "cadastro#salvar_resultado_nivel"

  #maturidades

  post "/cadastroMaturidade/incluir_maturidade", to: "main_screen#incluir_maturidade"
  post "/cadastroMaturidade/alterar_maturidade", to: "cadastro#alterar_maturidade"
  get '/cadastroMaturidade/:id', to: 'cadastro#mostrar_maturidade'

  #dominio

  get '/cadastroDominio/buscar_dominio', to: 'selecionar#buscar_dominio'
  get '/cadastroDominio/buscar_instituicao', to: 'selecionar#buscar_instituicao'
  get '/cadastroDominio/buscar_metodo', to: 'selecionar#buscar_metodo'

  #documentos

  post "/cadastroProcesso/:id/salvar_processo_docs", to: "aplicar#salvar_processo_docs"
  get "/cadastroProcesso/:id/excluir_processo_docs", to: "aplicar#excluir_processo_docs"
  post "/cadastroResultado/:id/salvar_resultado_docs", to: "aplicar#salvar_resultado_docs"
  get "/cadastroResultado/:id/excluir_resultado_docs", to: "aplicar#excluir_resultado_docs"
  post "/avaliar/:id/salvar_classificacao_docs", to: "avaliar#salvar_classificacao_docs"

  #modelos aplicados

  post "/cadastroModeloAplicado/incluir_modelo_aplicado", to: "selecionar#incluir_modelo_aplicado"

  #nivel

  post "/editar/incluir_nivel", to: "editar#incluir_nivel"
  post "/editar/:id/salvar_nivel", to: "editar#salvar_nivel"

  #editar

  post "/editar/:id/salvar_maturidade", to: "editar#salvar_maturidade"
  get "/editar/:id/excluir_maturidade", to: "editar#excluir_maturidade"

  #rotas auxiliares

  post "cadastro/atualizar_opcao", to:"cadastro#atualizar_opcao"
  post "aplicar/atualizar_opcao", to:"aplicar#atualizar_opcao"
  post "visualizar/atualizar_opcao", to:"visualizar#atualizar_opcao"
  post "editar/atualizar_opcao", to:"editar#atualizar_opcao"
  post "avaliar/atualizar_opcao", to:"avaliar#atualizar_opcao"
  post "selecionar/atualizar_opcao", to:"selecionar#atualizar_opcao"

  # rotas para o devise

  devise_for :users, controllers: {
  sessions: 'users/sessions',
  registrations: 'users/registrations',
  passwords: 'users/passwords',
  confirmations: 'users/confirmations'
  }

  devise_for :admins, controllers: {
    sessions: 'admins/sessions',
    registrations: 'admins/registrations',
    passwords: 'admins/passwords',
    confirmations: 'admins/confirmations'
  }

  devise_for :appraisers, controllers: {
    sessions: 'appraisers/sessions',
    registrations: 'appraisers/registrations',
    passwords: 'appraisers/passwords',
    confirmations: 'appraisers/confirmations'
  }

  post "/aplicar/:id/atualizar_descricao_doc", to: "aplicar#atualizar_descricao_doc"

  # Rotas para avaliação com IA
  post '/avaliar/:id/avaliar_com_ia', to: 'avaliar#avaliar_com_ia', as: 'avaliar_com_ia'
  post '/avaliar/avaliar_lote_com_ia', to: 'avaliar#avaliar_lote_com_ia', as: 'avaliar_lote_com_ia'
  post '/avaliar/:id/marcar_revisado', to: 'avaliar#marcar_revisado'

end

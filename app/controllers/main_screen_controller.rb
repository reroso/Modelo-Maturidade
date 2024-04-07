class MainScreenController < ApplicationController
    #maturidades

    def incluir_maturidade
        maturidade = Maturidade.new
        maturidade.nome = params[:nome]
        maturidade.descricao = params[:descricao]
        maturidade.tipoNivel = params[:tipoNivel]
        maturidade.menorNivel = params[:menorNivel]
        maturidade.maiorNivel = params[:maiorNivel]
        maturidade.resultadoEscolha = params[:resultadoEscolha]
        maturidade.nivelEscolha = params[:nivelEscolha]
        maturidade.save
        
        redirect_to "/editar"
    end

end

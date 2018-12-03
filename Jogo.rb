#Jogo da Velha usando Minimax
#José Luiz Corrêa Junior

class EstadoJogo
  #criacao do metodo de acesso para varias variaveis de instacia, leitura e escrita
  #Visiveis a todos os metodos
  attr_accessor :jogador_atual, :tabuleiro, :movimentos, :rank

#Classe para os dados temporarios das "simulacoes"
  class Temporario
    #criacao do metodo de acesso, leitura e escrita
    attr_accessor :states
    def initialize
      @states = {}
    end
  end

  #Cria uma metaclasse, um objeto da propria classe
  class << self
    #criacao do metodo de acesso, leitura e escrita
    attr_accessor :temporario

  end
  #cria objeto da classe Temporario
  self.temporario = Temporario.new

  #metodo initialize, para definicao dos parametros
  #quando for criado um objeto ja chama esse metodo, automaticamente
  def initialize(jogador_atual, tabuleiro)
    #metodo self para chamar o metodo de acesso das variaveis de instancia
    self.jogador_atual = jogador_atual
    self.tabuleiro = tabuleiro
    #inicializa o vetor chamado movimentos que vai receber as jogadas
    self.movimentos = []
  end
  
  #Recebe true or false
  def rank
    @rank ||= resultado_final || resultado_intermediario
  end

  #Metodo chamando quando o turno pertence ao computador
  def proximo_movimento
  #Uso da nave espacial (<=>)
  #retorna -1 se a < b
  #retorna 0 se a = b
  #retorna 1 se a > b

    movimentos.max{ |a, b| a.rank <=> b.rank }
  end

#Metodo para retornar quem foi o vencedor
  def resultado_final
    #somente se ja estiver chegado no fim do jogo
    #ja que tambem eh usado para checar melhor opcao
    if fim_jogo?
      #retorna 0 se deu velha
      return 0 if velha?
      #retorna 1 se X ganhou e -1 se O
      vencedor == "X" ? 1 : -1
    end
  end

#Metodo que confere se acabou
  def fim_jogo?
  #se teve ganhador ou deu velha retorna true
    vencedor || velha?
  end

#metodo que confere se deu velha e retorna true ou false
  def velha?
    #Tira nil com .compact e conta quantos elementos tem
    tabuleiro.compact.size == 9 && vencedor.nil?

  end


#Metodo para mostrar os resultados intermediarios para cada jogada "simulada"
  def resultado_intermediario
    # recursion, baby
    ranks = movimentos.collect{ |estado_jogo| estado_jogo.rank }
    if jogador_atual == 'X'
      #retorna ranks.max se for o computador
      #para maximizar a jogada dele
      ranks.max
    else
      #retorna ranks.min se for a jogada do humano
      #para minimizar a jogada do humano
      ranks.min
    end
  end  

#funcao com as combinacoes vencedoras
  def vencedor

    @vencedor ||= [
     # combinacoes horizonatal
     [0, 1, 2],
     [3, 4, 5],
     [6, 7, 8],

     # combinacoes vertical
     [0, 3, 6],
     [1, 4, 7],
     [2, 5, 8],

     # combinacoes diagonal
     [0, 4, 8],
     [6, 4, 2]
    ].collect { |positions|
      ( tabuleiro[positions[0]] == tabuleiro[positions[1]] &&
        tabuleiro[positions[1]] == tabuleiro[positions[2]] &&
        tabuleiro[positions[0]] ) || nil
    }.compact.first
    #@vencedor recebe X se ele tiver ganhado, ou o que completou a coluna
    #se nao teve ganhador, permanece nil, por isso so o primeiro char do vetor
    #para a identificacao do vencedor
  end

end

#Classe que verifica as possibilidades futuras
#Aqui que acontece a magica do minimax
class ArvoreJogo
  def generate
    #Ja passa o jogador atual e o tabuleiro no metodo initialize
    estado_inicial = EstadoJogo.new('X', Array.new(9))
    gerador_movimentos(estado_inicial)
    estado_inicial #retorna o tabuleiro criado
  end


  #Metodo recursivo para gerar os movimentos futuros e avaliar resultados
  def gerador_movimentos(estado_jogo)
    #Encontra qual é o proximo jogador por meio do atual
    #Se o atual for X, o proximo é O senao o Proximo é X
    next_player = (estado_jogo.jogador_atual == 'X' ? 'O' : 'X')

    estado_jogo.tabuleiro.each_with_index do |player_at_position, indice_posicao|

      unless player_at_position
        #uso do metodo dup para duplicar o jogo atual
        next_board = estado_jogo.tabuleiro.dup

        next_board[indice_posicao] = estado_jogo.jogador_atual

        #sit proximo recebe a simulacao do proximo jogo
        sit_proximo = (EstadoJogo.temporario.states[next_board] ||= EstadoJogo.new(next_player, next_board))


        estado_jogo.movimentos << sit_proximo

        #Sendo um algoritmo recursivo ele  chama o proprio metodo
        #depois de ja ter gerado um das possibilidade
        gerador_movimentos(sit_proximo)
      end

    end

  end

end

#Classe jogo
class Jogo
  #Metodo para iniciar jogo
  def initialize
    
  @estado_jogo = @estado_inicial = ArvoreJogo.new.generate

  end

  #metodo turno para finalizar, dar direiro de jogar e coisas assim
  def turno

    #caso o retorno do metodo fim_jogo? seja true
    if @estado_jogo.fim_jogo?
      #mostra fim do jogo se estiver acabado mesmo
      mostra_fim_jogo
      puts "Jogar novamente? (Sim)(Nao)"
      #Pega valor lido do usuario e aplica metodo para deixar tudo minusculo
      resposta = gets.downcase
      #downcase em tudo e strip para remover os espacos em branco, caso existam
      if resposta.downcase.strip == 'sim' || resposta.downcase.strip == 's'
        #cria novo tabuleiro
        @estado_jogo = @estado_inicial
        turno
      else#caso a resposta seja nao
        exit
      end
    end

    #checa a quem pertence a proxima jogada
    #Se pertence 
    if @estado_jogo.jogador_atual == 'X'
      puts "\n•••••••••••••••••••••••"
      @estado_jogo = @estado_jogo.proximo_movimento
      puts "Jogada do computador(X):"
      #mostra o tabuleiro com a jogada do computador
      mostra_tabuleiro
      turno#Vai para o proximo turno
    else#se tiver sido a jogada do humano
      jogada_humano
      puts "Seu movimento:"
      #mostra o tabuleiro com a jogada do humano
      mostra_tabuleiro
      puts ""
      turno#vai para o proximo turno
    end

  end
  
  #Metodo para mostrar o tabuleiro
  def mostra_tabuleiro
    #Inicia string vazia para receber as entradas
    saida = ""
    #Laco de o ate 8 para as posicoes do tabuleiro
    0.upto(8) do |posicao|
      #Acrescente coisas na string de saida
      saida << " #{@estado_jogo.tabuleiro[posicao] || posicao} "

      #confere o resto da divisao por 3
      case posicao % 3
      #Se for 0 ou 1, precisa do pipe pq eh coluna esquerda ou meio
      when 0, 1 then saida << "|"
      #Se for 2, precisa pular linha depois e ja colocar a linha
      when 2 then saida << "\n-----------\n" unless posicao == 8
      end
    end
    #printa a string que contem o tabuleiro
    puts saida
  end

  #Metodo para pegar posicao escolhida pelo jogador humano
  def jogada_humano
    puts "Digite o numero para marcar:"
    #Le entrada do usuario
    escolha = gets
    #Confere se o movimento é valido, retorna true ou false
    move = @estado_jogo.movimentos.find{ |estado_jogo| estado_jogo.tabuleiro[escolha.to_i] == 'O' }
    if move#Caso seja uma posicao valida
      @estado_jogo = move
    else#Retorna metodo ate posicao valida
      puts "Movimento invalido!"
      #chama o metodo jogada_humano de novo
      jogada_humano
    end
  end

#Metodo para mostar resultado do jogo
def mostra_fim_jogo
    #caso seja velha
    if @estado_jogo.velha?
      puts "Deu velha!"
    #caso X(computador) ganhou
    elsif @estado_jogo.vencedor == 'X'
      puts "X Ganhou"
    #caso O(Jogador) ganhou
    else
      puts "O Ganhou"
    end
  end
end

#Novo turno
Jogo.new.turno

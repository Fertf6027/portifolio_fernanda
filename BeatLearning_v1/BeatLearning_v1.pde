import processing.opengl.*;
import ddf.minim.*;
import ddf.minim.ugens.*;
import g4p_controls.*;


// Declaração de objetos
Minim minim;
AudioOutput out;
Button playButton, pauseButton, tutorialButton, previousButton, nextButton, resetButton, lastNextButton, testButton, creditButton;
AudioPlayer somTeste;

// Declaração de variáveis
Sampler[] instruments = new Sampler[7]; // Array para os instrumentos
int[][] instrumentColors = new int[7][3]; // Matriz para armazenar as cores únicas para cada instrumento
String[] instrumentNames = {"BUMBO", "CAIXA", "CHIMBAL F.", "CHIMBAL A.", "PALMAS", "ATAQUE", "GROOVE :)"}; // Nomes dos instrumentos
boolean[][] instrumentRows = new boolean[16][7]; // Array bidimensional para os passos de cada instrumento
ArrayList<Rect> buttons = new ArrayList<Rect>();
int bpm = 120;
int beat; // qual batida estamos
int lastMouseY; // Para rastrear a posição do mouse anterior
int currentPage = 0; // Página atual do tutorial
boolean tutorialVisible = false; // Controla visibilidade da janela do tutorial
boolean creditVisible = false; // Controla a janela de Créditos


// Funções Principais
void setup() {
  size(1020, 960); // Aumentei a altura do canvas para acomodar os botões e nomes dos instrumentos
  minim = new Minim(this);
  out   = minim.getLineOut();
  setupCreditos(); // Carrega as imagens dos créditos
  
  somTeste = minim.loadFile("Teste.mp3"); //Carrega o som do teste
  
  // Definição das cores únicas para cada instrumento
  instrumentColors[0] = new int[]{180, 207, 250};   
  instrumentColors[1] = new int[]{102, 198, 28};   
  instrumentColors[2] = new int[]{172, 114, 247};   
  instrumentColors[3] = new int[]{235, 92, 82}; 
  instrumentColors[4] = new int[]{254, 255, 90}; 
  instrumentColors[5] = new int[]{239, 172, 70}; 
  instrumentColors[6] = new int[]{236, 91, 136}; 
  
  /*
    Carregua todas as nossas amostras, usando 4 vezes para cada uma.
    Isso ajudará a garantir que tenhamos vozes suficientes para lidar até com tempos muito rápidos.
  */
 
  instruments[0] = new Sampler( "BD.wav", 4, minim ); // Bass Drum
  instruments[1] = new Sampler( "SD.wav", 4, minim ); // Snare Drum
  instruments[2] = new Sampler( "CHH.wav", 4, minim ); // Closed Hi-hat
  instruments[3] = new Sampler( "OH.wav", 4, minim ); // Open Hi-hat
  instruments[4] = new Sampler( "CP.wav", 4, minim ); // Clap
  instruments[5] = new Sampler( "CR.wav", 4, minim ); // Crash
  instruments[6] = new Sampler( "KD.wav", 4, minim ); // Ride/Bassline
  
  // Conecta as amostras à saída
  for (Sampler instrument : instruments) {
    instrument.patch(out);
  }
  
  // Inicialização dos passos de cada instrumento
  for (int i = 0; i < instrumentRows.length; i++) {
    for (int j = 0; j < instrumentRows[i].length; j++) {
      instrumentRows[i][j] = false;
    }
  }
  
  // Criando os botões para cada instrumento
  for (int i = 0; i < 16; i++) {
    for (int j = 0; j < instruments.length; j++) {
      buttons.add(new Rect(30 + i * 48, 150 + j * 100, instrumentRows[i], j, 6)); // alterado para cantos arredondados com raio 3
    }
  }
  
  beat = 0;
  
  // Inicia o sequenciador
  out.setTempo( bpm );
  out.playNote( 0, 0.25f, new Tick() );
  
  // Posicionamento dos botões de Play e Pause
  playButton = new Button(230, 850, 160, 80, "PLAY");
  pauseButton = new Button(430, 850, 160, 80, "PAUSE");
  tutorialButton = new Button(630, 850, 160, 80, "TUTORIAL");
  resetButton = new Button(830, 850, 160, 80, "RESET");
  previousButton = new Button(120, 740, 200, 50, "ANTERIOR");
  nextButton = new Button(680, 740, 200, 50, "PRÓXIMO");
  lastNextButton = new Button(680, 740, 200, 50, "FECHAR");
  creditButton = new Button(830, 30, 160, 40, "CRÉDITOS");
}

void draw() {
  background(120); // Alteração do fundo para #555859

  textSize(60);
  textAlign(CENTER, CENTER);
  fill(#FF8C00);
  text("BEAT LEARNING", 510, 40);
  //texto(frameRate, width - 60, 20);
  fill(255);
  for(int i = 0; i < buttons.size(); ++i) {
    buttons.get(i).draw();
    drawInstrumentName(i);
  }
  
  stroke(128);
  
  if ( beat % 4 == 0 ) {
    fill(#ffd700);
  }
  else {
    fill(#FF8C00);
  }
    
  // Marcador de batida    
  rect(30+beat*48, 120, 40, 15, 6);
  
  // Desenha o campo BPM
  fill(#555859);
  rect(30, 30, 120, 40);
  fill(255);
  textSize(24);
  textAlign(LEFT, TOP);
  text("BPM: " + bpm, 45, 42);
  
  // Desenha os botões
  playButton.display();
  pauseButton.display();
  tutorialButton.display();
  resetButton.display();
  creditButton.display();
  teste();
  
  // Desenhar a janela do tutorial se estiver visível
  if (tutorialVisible) {
    drawTutorial();
    out.mute();
  }
  
  if (creditVisible) {
    drawCreditos();
    out.mute();
  }
}

void mousePressed() {
  for(int i = 0; i < buttons.size(); ++i)
  {
    buttons.get(i).mousePressed();
  }
  
  // Verifica se o botão de Play foi clicado
  if (playButton.isMouseOver(mouseX, mouseY)) {
    out.unmute(); // Resumindo a reprodução
  }
  
  // Verifica se o botão de Pause foi clicado
  if (pauseButton.isMouseOver(mouseX, mouseY)) {
    out.mute(); // Pausando a reprodução
  }
  
  // Alternar a visibilidade do tutorial se o botão Tutorial for clicado
  if (tutorialButton.isMouseOver(mouseX, mouseY)) {
    tutorialVisible = !tutorialVisible; 
    currentPage = 0;
  }
  
  // Alternar a visibilidade dos créditos se o botão créditos for clicado
  if (creditButton.isMouseOver(mouseX, mouseY)) {
    creditVisible = !creditVisible; 
    currentPage = 0;
  }
  
  // Navegação no Tutorial
  if (tutorialVisible) {
    if (previousButton.isMouseOver(mouseX, mouseY)) {
      if (currentPage > 0) {
        currentPage--; // Retrocede uma página
      }
    } 
    else if (nextButton.isMouseOver(mouseX, mouseY)) {
      if (currentPage < tutorialPages.length - 1) 
      {
        currentPage++; // Avança uma página
      }
      else if(currentPage == tutorialPages.length - 1)
      {
        tutorialVisible = !tutorialVisible; 
        currentPage = 0;
      }
    }
  }
  //Verifica se o botão de Teste foi clicado
  if (mouseX >= 30 && mouseX<= 190 && mouseY >= 850 && mouseY <= 930)
    {
     somTeste.play();
    }
    if (somTeste.position() == somTeste.length()){
      somTeste.rewind();
    }
}

void mouseWheel(MouseEvent event) {
  int e = event.getCount();
  if (e > 0) {
    bpm -= 1; // diminui BPM
  } else if (e < 0) {
    bpm += 1; // aumenta BPM
  }
  
  // Limita o BPM a um valor mínimo de 60 e máximo de 240
  bpm = constrain(bpm, 60, 240);
  
  // Define o novo tempo
  out.setTempo(bpm);
}

// Funções

void drawInstrumentName(int index) {
  if (index >= 0 && index < instrumentNames.length) { // Verifica se o índice é válido
    fill(instrumentColors[index][0], instrumentColors[index][1], instrumentColors[index][2]);
    rect(830, 150 + index * 100, 160, 40,6);
    textAlign(CENTER, CENTER);
    textSize(24);
    fill(#000000);
    text(instrumentNames[index], 910, 150 + index * 100 + 20);
  }
}


// Classes

/*
  Aqui está uma implementação de Instrument que usamos para acionar Samplers a cada dezesseis notas.
  Note como conseguimos usar apenas uma instância desta classe para ter uma criação de batida infinita
  fazendo com que a classe agende a si mesma para ser tocada no final de seu método noteOff.
*/

class Tick implements Instrument {
  void noteOn(float dur) {
    for (int i = 0; i < instruments.length; i++) {
      if (instrumentRows[beat][i]) {
        instruments[i].trigger();
      }
    }
  }
  
  void noteOff()
  {
    // próxima batida
    beat = (beat+1)%16;
    // define o novo tempo
    out.setTempo( bpm );
    // toque isso novamente agora, com uma duração de dezesseis notas
    out.playNote( 0, 0.25f, this );
  }
}

// Classe para interface gráfica
class Rect 
{
  int x, y, s; // s representa o tamanho do lado do quadrado
  boolean[] steps;
  int stepId;
  int cornerRadius; // raio dos cantos
  
  public Rect(int _x, int _y, boolean[] _steps, int _id, int _cornerRadius) {
    x = _x;
    y = _y;
    s = 40; // tamanho do lado do quadrado
    steps = _steps;
    stepId = _id;
    cornerRadius = _cornerRadius;
  }
  
  public void draw() {
    if ( steps[stepId] ) {
      fill(instrumentColors[stepId][0], instrumentColors[stepId][1], instrumentColors[stepId][2]); // Cor única para o instrumento
    }
    else {
      fill(#CBCCCC);
    }
    
    rect(x, y, s, s, cornerRadius); // desenha um quadrado com cantos arredondados
  }
  
  public void mousePressed() {
    if (!(tutorialVisible)){ // não ativar o som enquanto o tutorial estiver aberto
      if ( mouseX >= x && mouseX <= x+s && mouseY >= y && mouseY <= y+s ) {
          steps[stepId] = !steps[stepId];
        }
    }
    if (resetButton.isMouseOver(mouseX, mouseY)) {
      for (int i = 0; i < instrumentRows.length; i++) {
        for (int j = 0; j < 7; j++) {
          instrumentRows[i][j] = false;
        }
      }
    }
  }
}

// Classe para os botões
class Button {
  int x, y, w, h, c;
  String label;
  
  Button(int x, int y, int w, int h, String label) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.label = label;
    c = 6;
  }
  
  void display() {
    stroke(255);
    fill(#FF8C00);
    rect(x, y, w, h, c);
    fill(255);
    textAlign(CENTER, CENTER);
    fill(0);
    textSize(36);
    text(label, x + w/2, y + h/2);
  }
  
  boolean isMouseOver(int mx, int my) {
    return (mx > x && mx < x + w && my > y && my < y + h);
  }
}

String[] tutorialPages = {
  "Teoria Musical\n\nO que é música?\n\nÉ a arte de combinar os sons simultâneos e sucessivamente, com ordem,\nequilíbrio e proporção, dentro do tempo.\n\n“É a arte de manifestar os diversos afetos de nossa alma mediante o som.”\n\nA música é constituída em 4 partes:\n\nMELODIA – É a combinação dos SONS SUCESSIVOS (dados uns após outros).\nÉ a concepção horizontal da Música.\n\nHARMONIA – É a combinação dos SONS SIMULT NEOS (dados de uma só vez).\nÉ a concepção vertical da Música.\n\nCONTRAPONTO – É o conjunto de melodias dispostas em ordem simultânea.\nÉ a concepção ao mesmo tempo horizontal e vertical da Música.\n\nRÍTMO – É a combinação dos valores tempo.",
  "Notas musicais e Sistema de Notação\n\nAs NOTAS MUSICAIS são o coração da música e ela é composta por 7 notas:\nDó, Ré, Mi, Fá, Sol, Lá e Si. Elas são como letras do alfabeto musical e são usadas \npara criar todas as músicas que ouvimos. Cada uma dessas notas tem um som \núnico e é representada por uma letra.\n\nPara escrever uma música é desenhado sobre 5 linhas e 4 espaços horizontais \nparalelos e equidistantes. A estas linhas e espaços são chamadas de PAUTA \nMUSICAL ou PENTAGRAMA.\n\nLINHAS SUPLEMENTARES são linhas adicionais a PAUTA MUSICAL que expandem \nos horizontes musicais e permitem que qualquer nota seja escrita e executada.\n\nPARTITURA é uma representação gráfica completa de uma obra musical, incluindo \na melodia, ritmo, harmonia e outros elementos musicais. A pauta é uma parte da \npartitura.",
  "Claves Musicais\n\nUma CLAVE MUSICAL é um símbolo colocado no início da pauta musical que \ndefine a altura (grave ou aguda) das notas em relação às linhas e espaços da \npauta. É como uma chave que decifra o significado das posições na pauta.\nExistem quatro claves principais usadas na música:\n\nClave do Sol\nClave de Fá\nClave de Dó\nClave Neutra",
  "Ritmo e Notação Rítmica\n\nRITMO é o “batimento cardíaco” da música. É a organização dos sons no tempo. \nAssim como nós temos um batimento cardíaco regular, a música tem uma \npulsação constante chamada de “tempo”.\n\nO tempo é a unidade de medida do ritmo, e ele é dividido em pulsações regulares \nsemelhante a um relógio. A velocidade do tempo é medida em batimentos por \nminuto (BPM).\n\nFIGURAS RÍTMICAS são representações gráficas de durações das notas. As figuras \nmais comuns são semibreve, mínima, semínima, colcheia e a semicolcheia. Cada \numa delas dura a metade do tempo da anterior.\n\nPAUSAS RÍTMICAS são momentos de silêncio que têm a mesma duração das \nfiguras rítmicas correspondentes. Elas são tão importantes quanto as notas, pois \ndão a música sua articulação.",
  "Ritmo e Notação Rítmica (cont.)\n\nCOMPASSO é o esqueleto da música. Determina a maneira pelo qual o ritmo é \norganizado em grupos regulares de batidas. Os compassos podem ser simples, \ncom um único grupo de batidas, ou compostos, com dois ou mais grupos de \nbatidas.\n\nCompassos simples têm batidas divisíveis por 2, como 2/4.\nCompassos compostos têm batidas divisíveis por 3, como 6/8.\n\nASSINATURA DE TEMPO indica quantas batidas existem em cada compasso e \nqual figura rítmica representa uma batida.",
  "Composição e Arranjo Básico\n\nCOMPOSIÇÃO MUSICAL é o ato de criar uma música original. Pode envolver a \ncriação de melodias, harmonias, ritmos, e estruturas musicais. Cada compositor \ntem seu próprio processo criativo.\n\nMELODIA é a linha principal de uma música, a sequência de notas que é cantada \nou tocada. A HARMONIA é a combinação de acordes que acompanham a melodia. \nCompor envolve a interação entre a melodia e a harmonia.\n\nRITMO é o padrão rítmico que sustenta a composição musical. A ESTRUTURA \ndefine como a música é organizada, incluindo a divisão de versos, refrões e pontes.",
  "Composição e Arranjo Básico (cont.)\n\nARRANJO MUSICAL é a arte de adaptar uma composição por um grupo de músicos \nou instrumentos específicos. Isto envolve a escolha de vozes, instrumentos e a \ncriação de partes individuais para cada músico.\n\nExistem várias FERRAMENTAS DE COMPOSIÇÃO disponíveis, desde o tradicional,\npapel pautado até softwares de notação musical e programas de produção musical.",
  "Estes são os fundamentos da Teoria Musical.\n\nAgora é com você! Componha uma música usando o nosso BEATMAKER!"
};

void drawTutorial() {
  // Janela do tutorial
  fill(255);
  stroke(0);
  rect(60, 60, 900, 760);
  
  // Conteúdo do tutorial
  fill(0);
  textAlign(LEFT, TOP);
  textSize(24);
  text(tutorialPages[currentPage], 120, 120, 120);
  
  // Botões
  previousButton.display();
  if(currentPage < tutorialPages.length -1)
    {nextButton.display();}
  else
    {lastNextButton.display();}
  
}

float xr = 500;
float yr = 1600;
float tamanhoTexto = 30;
float distance = 75;
PImage photoAnaJ, photoDavi, photoEdu, photoFer, photoJafte, photoRenato;

void setupCreditos() {
  //size(252, 356); // tamanho das imagens
  //size(1000, 400);
  photoAnaJ = loadImage("Ana.jpg");
  photoDavi = loadImage("Davi.jpg");
  photoEdu = loadImage("Edu.jpg");
  photoFer = loadImage("Fernanda.jpg");
  photoJafte = loadImage("Jafte.jpg");
  photoRenato = loadImage("Renato.jpg");
}

void drawCreditos(){
  background(0);
  credito(30, 500);
  creditButton.display();
}

void credito(float tamanhoTexto, float distance){
  float fim = tamanhoTexto*6+distance*5+400;
  fill(255);
  textSize(tamanhoTexto);
  textAlign(CENTER);
  imageMode(CENTER);
  text("ESTE APLICATIVO FOI DESENVOLVIDO POR:", xr, yr - 500);
  image(photoAnaJ, xr, yr-220);
  text("Ana Jully da Silva Ávila",xr, yr);
  image(photoDavi, xr, yr+distance - 220);
  text("Davi Kazuhiro Natume",xr, yr+distance);
  image(photoEdu, xr, yr+distance*2 - 220);
  text("Eduardo Teodoro Moreira de Souza",xr, yr+distance*2);
  image(photoFer, xr, yr+distance*3-220);
  text("Fernanda Costa Moraes",xr, yr+distance*3);
  image(photoJafte, xr,yr+distance*4-220);
  text("Jafte Carneiro Fagundes da Silva",xr, yr+distance*4);
  image(photoRenato, xr, yr+distance*5-220);
  text("Renato Pestana de Gouveia",xr, yr+distance*5);
  text("PROJETO II - EXPERIÊNCIA CRIATIVA", xr, yr+distance*5+300);
  text("CIÊNCIA DA COMPUTAÇÃO - PUCPR", xr, yr+distance*5+350);
  if(yr > -fim){yr -= 3;}
  else yr = 1600;
}

void teste(){
  stroke(255);
  fill(#FF8C00);
  rect(30, 850, 160, 80, 6);
  if(instrumentRows[0][6] == true && 
    instrumentRows[2][2] == true &&
    instrumentRows[4][1] == true &&
    instrumentRows[6][2] == true &&
    instrumentRows[8][0] == true &&
    instrumentRows[10][3] == true &&
    instrumentRows[12][4] == true &&
    instrumentRows[14][3] == true &&
    instrumentRows[15][0] == true)
    {
      fill(#ffd700);
      rect(30, 850, 160, 80, 6); 
    }
  else
    {
      fill(#FF8C00);
    }
  fill(255);
  textAlign(CENTER, CENTER);
  fill(0);
  textSize(36);
  text("TESTE",110, 890);
}

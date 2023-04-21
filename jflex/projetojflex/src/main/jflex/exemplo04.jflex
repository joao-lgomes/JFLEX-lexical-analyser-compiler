enum Classe {
    cId,
    cInt,
    cReal,
    cPalRes,
    cDoisPontos,
    cAtribuicao,
    cMais,
    cMenos,
    cDivisao,
    cMultiplicacao,
    cMaior,
    cMenor,
    cMaiorIgual,
    cMenorIgual,
    cDiferente,
    cIgual,
    cVirgula,
    cPontoVirgula,
    cPonto,
    cParEsq,
    cParDir,
    cString,
    cEOF,
}


class Valor {

    private enum TipoValor {
        INTEIRO, DECIMAL, IDENTIFICADOR
    }

    private int valorInteiro;
    private double valorDecimal;
    private String valorIdentificador;
    private TipoValor tipo;

    public Valor() {
    }

    public Valor(int valorInteiro) {
        this.valorInteiro = valorInteiro;
        tipo = TipoValor.INTEIRO;
    }

    public Valor(String valorIdentificador) {
        this.valorIdentificador = valorIdentificador;
        tipo = TipoValor.IDENTIFICADOR;
    }

    public int getValorInteiro() {
        return valorInteiro;
    }

    public void setValorInteiro(int valorInteiro) {
        this.valorInteiro = valorInteiro;
        tipo = TipoValor.INTEIRO;
    }

    public double getValorDecimal() {
        return valorDecimal;
    }

    public void setValorDecimal(double valorDecimal) {
        this.valorDecimal = valorDecimal;
        tipo = TipoValor.DECIMAL;
    }

    public String getValorIdentificador() {
        return valorIdentificador;
    }

    public void setValorIdentificador(String valorIdentificador) {
        this.valorIdentificador = valorIdentificador;
        tipo = TipoValor.IDENTIFICADOR;
    }

    @Override
    public String toString() {
        if (tipo == TipoValor.INTEIRO) {
            return "ValorInteiro: " + valorInteiro;
        } else if (tipo == TipoValor.DECIMAL) {
            return "ValorDecimal: " + valorDecimal;
        } else {
            return "ValorIdentificador: " + valorIdentificador;
        }
    }

}

class Token {

    private Classe classe;
    private Valor valor;
    private int linha;
    private int coluna;

    public Token(int linha, int coluna, Classe classe) {
        this.linha = linha;
        this.coluna = coluna;
        this.classe = classe;
    }

    public Token(int linha, int coluna, Classe classe, Valor valor) {
        this.classe = classe;
        this.valor = valor;
        this.linha = linha;
        this.coluna = coluna;
    }

    public Classe getClasse() {
        return classe;
    }

    public void setClasse(Classe classe) {
        this.classe = classe;
    }

    public Valor getValor() {
        return valor;
    }

    public void setValor(Valor valor) {
        this.valor = valor;
    }

    public int getLinha() {
        return linha;
    }

    public void setLinha(int linha) {
        this.linha = linha;
    }

    public int getColuna() {
        return coluna;
    }

    public void setColuna(int coluna) {
        this.coluna = coluna;
    }

    @Override
    public String toString() {
        return "Token [classe: " + classe + ", " + valor + ", linha: " + linha + ", coluna: " + coluna + "]";
    }

}

%%

// %standalone
%class Lexico
// %function getToken
%type Token
%unicode
%line
%column
// %cup

DIGITO = [0-9]
LETRA = [A-Za-z]
INTEIRO = 0 | [1-9]{DIGITO}*
IDENTIFICADOR = {LETRA} ({LETRA} | {DIGITO})*
STRING = \"[^\"]*\"

REAL = {INTEIRO}\.{INTEIRO}
PALAVRA_RESERVADA = "and"|"array"|"begin"|"case"|"const"|"div"|"do"|"downto"|"else"|"end"|"file"|"for"|"function"|"goto"|"if"|"in"|"label"|"mod"|"nil"|"not"|"of"|"or"|"packed"|"procedure"|"program"|"record"|"repeat"|"set"|"then"|"to"|"type"|"until"|"var"|"while"|"with"
ATRIBUICAO = ":="
MAIOR_IGUAL = ">="
MENOR_IGUAL = "<="
DIFERENTE = "<>"
PARENTESE_ESQUERDO = "\("
PARENTESE_DIREITO = "\)"

FIMLINHA = \r|\n|\r\n
ESPACO = {FIMLINHA} | [ \t\f]

%{
public static void main(String[] argv) {
    if (argv.length == 0) {
      System.out.println("Usage : java Lexico [ --encoding <name> ] <inputfile(s)>");
    }
    else {
      int firstFilePos = 0;
      String encodingName = "UTF-8";
      if (argv[0].equals("--encoding")) {
        firstFilePos = 2;
        encodingName = argv[1];
        try {
          // Side-effect: is encodingName valid?
          java.nio.charset.Charset.forName(encodingName);
        } catch (Exception e) {
          System.out.println("Invalid encoding '" + encodingName + "'");
          return;
        }
      }
      for (int i = firstFilePos; i < argv.length; i++) {
        Lexico scanner = null;
        java.io.FileInputStream stream = null;
        java.io.Reader reader = null;
        try {
          stream = new java.io.FileInputStream(argv[i]);
          reader = new java.io.InputStreamReader(stream, encodingName);
          scanner = new Lexico(reader);
          while ( !scanner.zzAtEOF ) {
            System.out.println(scanner.yylex());
          }
        }
        catch (java.io.FileNotFoundException e) {
          System.out.println("File not found : \""+argv[i]+"\"");
        }
        catch (java.io.IOException e) {
          System.out.println("IO error scanning file \""+argv[i]+"\"");
          System.out.println(e);
        }
        catch (Exception e) {
          System.out.println("Unexpected exception:");
          e.printStackTrace();
        }
        finally {
          if (reader != null) {
            try {
              reader.close();
            }
            catch (java.io.IOException e) {
              System.out.println("IO error closing file \""+argv[i]+"\"");
              System.out.println(e);
            }
          }
          if (stream != null) {
            try {
              stream.close();
            }
            catch (java.io.IOException e) {
              System.out.println("IO error closing file \""+argv[i]+"\"");
              System.out.println(e);
            }
          }
        }
      }
    }
  }
%}

%%

{INTEIRO}       { return new Token(yyline + 1, yycolumn + 1, Classe.cInt, new Valor(Integer.parseInt(yytext()))); }
{IDENTIFICADOR} { return new Token(yyline + 1, yycolumn + 1, Classe.cId, new Valor(yytext())); }
{ESPACO}        { /* ignorar */ }

{STRING} = { return new Token(yyline + 1, yycolumn + 1, Classe.cString, new Valor(yytext())); }
{REAL} = { return new Token(yyline + 1, yycolumn + 1, Classe.cReal, new Valor(Integer.parseInt(yytext()))); }
{PALAVRA_RESERVADA} = { return new Token(yyline + 1, yycolumn + 1, Classe.cPalRes, new Valor(yytext())); }
":" { return new Token(yyline + 1, yycolumn + 1, Classe.cDoisPontos, new Valor(yytext())); }
{ATRIBUICAO} = { return new Token(yyline + 1, yycolumn + 1, Classe.cAtribuicao, new Valor(yytext())); }
"+" { return new Token(yyline + 1, yycolumn + 1, Classe.cMais); }
"-" { return new Token(yyline + 1, yycolumn + 1, Classe.cMenos, new Valor(yytext())); }
"=" { return new Token(yyline + 1, yycolumn + 1, Classe.cIgual, new Valor(yytext())); }
">" { return new Token(yyline + 1, yycolumn + 1, Classe.cMaior, new Valor(yytext())); }
"<" { return new Token(yyline + 1, yycolumn + 1, Classe.cMenor, new Valor(yytext())); }
{MAIOR_IGUAL} = { return new Token(yyline + 1, yycolumn + 1, Classe.cMaiorIgual, new Valor(yytext())); }
{MENOR_IGUAL} = { return new Token(yyline + 1, yycolumn + 1, Classe.cMenorIgual, new Valor(yytext())); }
"/" { return new Token(yyline + 1, yycolumn + 1, Classe.cDivisao, new Valor(yytext())); }
"*" { return new Token(yyline + 1, yycolumn + 1, Classe.cMultiplicacao, new Valor(yytext())); }
{DIFERENTE} = { return new Token(yyline + 1, yycolumn + 1, Classe.cDiferente, new Valor(yytext())); }
"," { return new Token(yyline + 1, yycolumn + 1, Classe.cVirgula, new Valor(yytext())); }
";" { return new Token(yyline + 1, yycolumn + 1, Classe.cPontoVirgula, new Valor(yytext())); }
"." { return new Token(yyline + 1, yycolumn + 1, Classe.cPonto, new Valor(yytext())); }
{PARENTESE_ESQUERDO} = { return new Token(yyline + 1, yycolumn + 1, Classe.cParEsq, new Valor(yytext())); }
{PARENTESE_DIREITO} = { return new Token(yyline + 1, yycolumn + 1, Classe.cParDir, new Valor(yytext())); }
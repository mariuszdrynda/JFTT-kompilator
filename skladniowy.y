%{
#define YYSTYPE std::string
#include <string>
#include <vector>
#include <iostream>
#include <cstdlib>
#include <fstream>
using namespace std;
int yylex(void);
extern int yylineno; 
void yyerror(char*);
class Zmienna{
public:
	string nazwaZmiennej;
	unsigned int nrKomorkiWPamieci;
	unsigned int dlugoscTablicy;
	bool isPartOfArray;
	bool isIterator;
	bool czyZainicjowana;
	Zmienna(){};
	Zmienna(string nazwaZmiennejT, int nrKomorkiWPamieciBedacyPoczatkiemTablicyT, 
	int dlugoscTablicyT, bool isPartOfArrayT, bool isIteratotT,bool czyZainicjowanaT){
		nazwaZmiennej = nazwaZmiennejT;
		nrKomorkiWPamieci = nrKomorkiWPamieciBedacyPoczatkiemTablicyT;
		dlugoscTablicy = dlugoscTablicyT;
		isPartOfArray = isPartOfArrayT;
		isIterator = isIteratotT;
		czyZainicjowana = czyZainicjowanaT;
	}
};
class Skok{
public:
	string tekstLinijki;
	unsigned int nrLinijkiDoEdycji;
	Skok(){};
	Skok(string tekstLinijkiT, int nrLinijkiDoEdycjiT){
		tekstLinijki = tekstLinijkiT;
		nrLinijkiDoEdycji = nrLinijkiDoEdycjiT;
	}
};
std::vector <int> dodanieDoTab;
std::vector <int> skokDoTylu;
std::vector <int> skokDoPrzodu;
std::vector <int> skokDoPrzoduIf;
std::vector <Skok> skokDoPrzoduEdycja;
std::vector <string> kodProgramu;
std::vector <Zmienna> tablicaZmiennych;
unsigned int nrWolnejKomorkiWPamieci = 5;
unsigned int nrLinii=0;
bool czyZmiennaIstnieje(string nazwaZmiennejT);
int zwrocIndeks(string nazwaZmiennejT, int dod);
string dajBin(string liczba);
bool czyTab(string nazwaZmiennejT);
void dzielenie();
void modulo();
void mnozenie();
bool czyIterator(string nazwaIteratora);
void usunIterator(string nazwaIteratora);
bool czyZmiennaZainicjowana(string nazwaZmiennejT);
void zainicjuj(string nazwaZmiennejT);
void dajNum(string nazwa);
%}
%token DODAWANIE ODEJMOWANIE MNOZENIE DZIELENIE MODULO
%token ROWNY ROZNY MNIEJSZY WIEKSZY WIEKSZYROWNY MNIEJSZYROWNY
%token PRZYPISANIE LEWYNAWIAS PRAWYNAWIAS VAR BEG END
%token FOR FROM DOWNTO TO ENDFOR IF THEN ELSE ENDIF WHILE ENDWHILE DO
%token READ WRITE PIDENTIFIER SREDNIK NUM
%%
program
: VAR vdeclarations BEG commands END {kodProgramu.push_back("HALT");nrLinii++;}
;

vdeclarations
: vdeclarations PIDENTIFIER {
	if(czyZmiennaIstnieje($2)){
		cerr<<"Błąd w linijce "<<yylineno<<". Zmienna już zostala zadeklarowana."<<endl;
		exit(1);
	}
	Zmienna zmienna;
	zmienna.nazwaZmiennej=$2;
	zmienna.nrKomorkiWPamieci=nrWolnejKomorkiWPamieci;
	zmienna.dlugoscTablicy=1;
	zmienna.isPartOfArray=false;
	zmienna.isIterator=false;
	zmienna.czyZainicjowana=false;
	nrWolnejKomorkiWPamieci++;
	tablicaZmiennych.push_back(zmienna);}
| vdeclarations PIDENTIFIER LEWYNAWIAS NUM PRAWYNAWIAS {
	if(czyZmiennaIstnieje($2)){
		cerr<<"Błąd w linijce "<<yylineno<<". Tablica już zostala zadeklarowana."<<endl;
		exit(1);
	}
	int dlugosc = stoi($4);
	Zmienna zmienna;
	zmienna.nazwaZmiennej=$2;
	zmienna.nrKomorkiWPamieci=nrWolnejKomorkiWPamieci;
	zmienna.dlugoscTablicy=dlugosc;
	zmienna.isPartOfArray=true;
	zmienna.isIterator=false;
	zmienna.czyZainicjowana=true;
	nrWolnejKomorkiWPamieci=nrWolnejKomorkiWPamieci+dlugosc;
	tablicaZmiennych.push_back(zmienna);}
| {}
;

commands
: commands command {}
| command {}
;

command
: identifier PRZYPISANIE expression SREDNIK {
	if(czyIterator($2)){
		cerr<<"Błąd w linijce "<<yylineno<<". Nie mozna modyfikowac iteratora."<<endl;
		exit(1);
	}
	int s1=0;
	if(czyTab($1)){s1=dodanieDoTab.back();dodanieDoTab.pop_back();}
	zainicjuj($1);
	kodProgramu.push_back("STORE "+to_string(zwrocIndeks($1,s1)));
	nrLinii++;}
| PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS PRZYPISANIE expression SREDNIK {
	if(!czyZmiennaZainicjowana($1)||!czyZmiennaZainicjowana($3)){
		cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	if(!czyTab($1)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako tablica."<<endl;exit(1);}
	kodProgramu.push_back("STORE 0");nrLinii++;
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($1,0)))) dajNum(to_string(zwrocIndeks($1,0)));
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($1,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($3,0)));
	kodProgramu.push_back("STORE 1");
	kodProgramu.push_back("LOAD 0");
	kodProgramu.push_back("STOREI 1");nrLinii+=5;
}
| IF condition THEN {
	kodProgramu.push_back("WKLEIC");
	skokDoPrzodu.push_back(nrLinii);
	nrLinii++;}
if {}
| WHILE {
	skokDoTylu.push_back(nrLinii);} 
condition DO {
	kodProgramu.push_back("WKLEIC");
	skokDoPrzodu.push_back(nrLinii);
	nrLinii++;} 
commands ENDWHILE {
	kodProgramu.push_back("JUMP "+to_string(skokDoTylu.back()));
	Skok skok;
	skok.tekstLinijki="JZERO "+to_string(nrLinii+1);
	skok.nrLinijkiDoEdycji=skokDoPrzodu.back();
	skokDoPrzoduEdycja.push_back(skok);
	skokDoPrzodu.pop_back();
	nrLinii++;skokDoTylu.pop_back();}
//FOR TO
| FOR PIDENTIFIER FROM value TO value DO {
	if(czyZmiennaIstnieje($2)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako iterator."<<endl;exit(1);}
	else if(!czyZmiennaZainicjowana($4)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	else if(!czyZmiennaZainicjowana($6)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	else{
		int s4=0, s6=0;
		if(czyTab($6)){s6=dodanieDoTab.back();dodanieDoTab.pop_back();}
		if(czyTab($4)){s4=dodanieDoTab.back();dodanieDoTab.pop_back();}
		Zmienna zmienna;
		zmienna.nazwaZmiennej=$2;
		zmienna.nrKomorkiWPamieci=nrWolnejKomorkiWPamieci;
		zmienna.dlugoscTablicy=1;
		zmienna.isPartOfArray=false;
		zmienna.isIterator=true;
		zmienna.czyZainicjowana=true;
		nrWolnejKomorkiWPamieci++;
		tablicaZmiennych.push_back(zmienna);
		kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($6,s6)));
		kodProgramu.push_back("INC");
		kodProgramu.push_back("STORE "+to_string(nrWolnejKomorkiWPamieci));
		kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($4,s4)));
		kodProgramu.push_back("STORE "+to_string(zwrocIndeks($2,0)));
		kodProgramu.push_back("LOAD "+to_string(nrWolnejKomorkiWPamieci));
		kodProgramu.push_back("SUB "+to_string(zwrocIndeks($2,0)));
		kodProgramu.push_back("WKLEIC");
		skokDoPrzodu.push_back(nrLinii+7);
		nrWolnejKomorkiWPamieci++;skokDoTylu.push_back(nrLinii+5);nrLinii+=8;
	}} 
commands ENDFOR {
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($2,0)));
	kodProgramu.push_back("INC");
	kodProgramu.push_back("STORE "+to_string(zwrocIndeks($2,0)));
	kodProgramu.push_back("JUMP "+to_string(skokDoTylu.back()));
	Skok skok;
	skok.tekstLinijki="JZERO "+to_string(nrLinii+4);
	skok.nrLinijkiDoEdycji=skokDoPrzodu.back();
	skokDoPrzoduEdycja.push_back(skok);
	nrLinii+=4;
	skokDoTylu.pop_back();
	skokDoPrzodu.pop_back();
	usunIterator($2);}
| FOR PIDENTIFIER FROM PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS TO PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS DO {
	if(czyZmiennaIstnieje($2)){ cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako iterator."<<endl;}
	if(!czyZmiennaZainicjowana($4)||!czyZmiennaZainicjowana($6)||!czyZmiennaZainicjowana($9)||!czyZmiennaZainicjowana($11)){
		cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	if(!czyTab($4)||!czyTab($9)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako tablica."<<endl;exit(1);}
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($4,0)))) dajNum(to_string(zwrocIndeks($4,0)));
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($9,0)))) dajNum(to_string(zwrocIndeks($9,0)));
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($4,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($6,0)));
	kodProgramu.push_back("STORE 0");
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($9,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($11,0)));
	kodProgramu.push_back("STORE 1");nrLinii+=6;
		Zmienna zmienna;
		zmienna.nazwaZmiennej=$2;
		zmienna.nrKomorkiWPamieci=nrWolnejKomorkiWPamieci;
		zmienna.dlugoscTablicy=1;
		zmienna.isPartOfArray=false;
		zmienna.isIterator=true;
		zmienna.czyZainicjowana=true;
		nrWolnejKomorkiWPamieci++;
		tablicaZmiennych.push_back(zmienna);
		kodProgramu.push_back("LOADI 1");
		kodProgramu.push_back("INC");
		kodProgramu.push_back("STORE "+to_string(nrWolnejKomorkiWPamieci));
		kodProgramu.push_back("LOADI 0");
		kodProgramu.push_back("STORE "+to_string(zwrocIndeks($2,0)));
		kodProgramu.push_back("LOAD "+to_string(nrWolnejKomorkiWPamieci));
		kodProgramu.push_back("SUB "+to_string(zwrocIndeks($2,0)));
		kodProgramu.push_back("WKLEIC");
		skokDoPrzodu.push_back(nrLinii+7);
		nrWolnejKomorkiWPamieci++;skokDoTylu.push_back(nrLinii+5);nrLinii+=8;
}
commands ENDFOR {
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($2,0)));
	kodProgramu.push_back("INC");
	kodProgramu.push_back("STORE "+to_string(zwrocIndeks($2,0)));
	kodProgramu.push_back("JUMP "+to_string(skokDoTylu.back()));
	Skok skok;
	skok.tekstLinijki="JZERO "+to_string(nrLinii+4);
	skok.nrLinijkiDoEdycji=skokDoPrzodu.back();
	skokDoPrzoduEdycja.push_back(skok);
	nrLinii+=4;skokDoTylu.pop_back();
	skokDoPrzodu.pop_back();
	usunIterator($2);}
| FOR PIDENTIFIER FROM value TO PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS DO {
	if(czyZmiennaIstnieje($2)){ cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako iterator."<<endl;}
	if(!czyZmiennaZainicjowana($4)||!czyZmiennaZainicjowana($6)||!czyZmiennaZainicjowana($8)){
		cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	if(!czyTab($6)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako tablica."<<endl;exit(1);}
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($6,0)))) dajNum(to_string(zwrocIndeks($6,0)));
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($6,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($8,0)));
	kodProgramu.push_back("STORE 0");nrLinii+=3;
		int s4=0;
		if(czyTab($4)){s4=dodanieDoTab.back();dodanieDoTab.pop_back();}
		Zmienna zmienna;
		zmienna.nazwaZmiennej=$2;
		zmienna.nrKomorkiWPamieci=nrWolnejKomorkiWPamieci;
		zmienna.dlugoscTablicy=1;
		zmienna.isPartOfArray=false;
		zmienna.isIterator=true;
		zmienna.czyZainicjowana=true;
		nrWolnejKomorkiWPamieci++;
		tablicaZmiennych.push_back(zmienna);
		kodProgramu.push_back("LOADI 0");
		kodProgramu.push_back("INC");
		kodProgramu.push_back("STORE "+to_string(nrWolnejKomorkiWPamieci));
		kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($4,s4)));
		kodProgramu.push_back("STORE "+to_string(zwrocIndeks($2,0)));
		kodProgramu.push_back("LOAD "+to_string(nrWolnejKomorkiWPamieci));
		kodProgramu.push_back("SUB "+to_string(zwrocIndeks($2,0)));
		kodProgramu.push_back("WKLEIC");
		skokDoPrzodu.push_back(nrLinii+7);
		nrWolnejKomorkiWPamieci++;skokDoTylu.push_back(nrLinii+5);nrLinii+=8;
}
commands ENDFOR {
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($2,0)));
	kodProgramu.push_back("INC");
	kodProgramu.push_back("STORE "+to_string(zwrocIndeks($2,0)));
	kodProgramu.push_back("JUMP "+to_string(skokDoTylu.back()));
	Skok skok;
	skok.tekstLinijki="JZERO "+to_string(nrLinii+4);
	skok.nrLinijkiDoEdycji=skokDoPrzodu.back();
	skokDoPrzoduEdycja.push_back(skok);
	nrLinii+=4;skokDoTylu.pop_back();
	skokDoPrzodu.pop_back();
	usunIterator($2);}
| FOR PIDENTIFIER FROM PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS TO value DO {
	if(czyZmiennaIstnieje($2)){ cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako iterator."<<endl;}
	if(!czyZmiennaZainicjowana($4)||!czyZmiennaZainicjowana($6)||!czyZmiennaZainicjowana($9)){
		cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	if(!czyTab($4)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako tablica."<<endl;exit(1);}
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($4,0)))) dajNum(to_string(zwrocIndeks($4,0)));
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($4,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($6,0)));
	kodProgramu.push_back("STORE 0");nrLinii+=3;
	int s9=0;
	if(czyTab($9)){s9=dodanieDoTab.back();dodanieDoTab.pop_back();}
		Zmienna zmienna;
		zmienna.nazwaZmiennej=$2;
		zmienna.nrKomorkiWPamieci=nrWolnejKomorkiWPamieci;
		zmienna.dlugoscTablicy=1;
		zmienna.isPartOfArray=false;
		zmienna.isIterator=true;
		zmienna.czyZainicjowana=true;
		nrWolnejKomorkiWPamieci++;
		tablicaZmiennych.push_back(zmienna);
		kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($9,s9)));
		kodProgramu.push_back("INC");
		kodProgramu.push_back("STORE "+to_string(nrWolnejKomorkiWPamieci));
		kodProgramu.push_back("LOADI 0");
		kodProgramu.push_back("STORE "+to_string(zwrocIndeks($2,0)));
		kodProgramu.push_back("LOAD "+to_string(nrWolnejKomorkiWPamieci));
		kodProgramu.push_back("SUB "+to_string(zwrocIndeks($2,0)));
		kodProgramu.push_back("WKLEIC");
		skokDoPrzodu.push_back(nrLinii+7);
		nrWolnejKomorkiWPamieci++;skokDoTylu.push_back(nrLinii+5);nrLinii+=8;
}
commands ENDFOR {
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($2,0)));
	kodProgramu.push_back("INC");
	kodProgramu.push_back("STORE "+to_string(zwrocIndeks($2,0)));
	kodProgramu.push_back("JUMP "+to_string(skokDoTylu.back()));
	Skok skok;
	skok.tekstLinijki="JZERO "+to_string(nrLinii+4);
	skok.nrLinijkiDoEdycji=skokDoPrzodu.back();
	skokDoPrzoduEdycja.push_back(skok);
	nrLinii+=4;skokDoTylu.pop_back();
	skokDoPrzodu.pop_back();
	usunIterator($2);}
//FOR DOWNTO
| FOR PIDENTIFIER FROM value DOWNTO value DO {
	if(czyZmiennaIstnieje($2)){ cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako iterator."<<endl;}
	else if(!czyZmiennaZainicjowana($4)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	else if(!czyZmiennaZainicjowana($6)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	else{
		int s4=0, s6=0;
		if(czyTab($6)){s6=dodanieDoTab.back();dodanieDoTab.pop_back();}
		if(czyTab($4)){s4=dodanieDoTab.back();dodanieDoTab.pop_back();}
		Zmienna zmienna;
		zmienna.nazwaZmiennej=$2;
		zmienna.nrKomorkiWPamieci=nrWolnejKomorkiWPamieci;
		zmienna.dlugoscTablicy=1;
		zmienna.isPartOfArray=false;
		zmienna.isIterator=true;
		zmienna.czyZainicjowana=true;
		nrWolnejKomorkiWPamieci++;
		tablicaZmiennych.push_back(zmienna);
		kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($6,s6)));
		kodProgramu.push_back("STORE "+to_string(nrWolnejKomorkiWPamieci));
		kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($4,s4)));
		kodProgramu.push_back("STORE "+to_string(zwrocIndeks($2,0)));
		kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($2,0)));
		kodProgramu.push_back("INC");
		kodProgramu.push_back("SUB "+to_string(nrWolnejKomorkiWPamieci));
		kodProgramu.push_back("WKLEIC");
		skokDoPrzodu.push_back(nrLinii+7);
		nrWolnejKomorkiWPamieci++;skokDoTylu.push_back(nrLinii+5);nrLinii+=8;
	}} 
commands ENDFOR {
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($2,0)));
	kodProgramu.push_back("JZERO "+to_string(nrLinii+5));
	kodProgramu.push_back("DEC");
	kodProgramu.push_back("STORE "+to_string(zwrocIndeks($2,0)));
	kodProgramu.push_back("JUMP "+to_string(skokDoTylu.back()));
	Skok skok;
	skok.tekstLinijki="JZERO "+to_string(nrLinii+5);
	skok.nrLinijkiDoEdycji=skokDoPrzodu.back();
	skokDoPrzoduEdycja.push_back(skok);
	nrLinii+=5;
	skokDoTylu.pop_back();
	skokDoPrzodu.pop_back();
	usunIterator($2);}
| FOR PIDENTIFIER FROM PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS DOWNTO PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS DO {
	if(czyZmiennaIstnieje($2)){ cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako iterator."<<endl;}
	if(!czyZmiennaZainicjowana($4)||!czyZmiennaZainicjowana($6)||!czyZmiennaZainicjowana($9)||!czyZmiennaZainicjowana($11)){
		cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	if(!czyTab($4)||!czyTab($9)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako tablica."<<endl;exit(1);}
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($4,0)))) dajNum(to_string(zwrocIndeks($4,0)));
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($9,0)))) dajNum(to_string(zwrocIndeks($9,0)));
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($4,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($6,0)));
	kodProgramu.push_back("STORE 0");
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($9,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($11,0)));
	kodProgramu.push_back("STORE 1");nrLinii+=6;
		Zmienna zmienna;
		zmienna.nazwaZmiennej=$2;
		zmienna.nrKomorkiWPamieci=nrWolnejKomorkiWPamieci;
		zmienna.dlugoscTablicy=1;
		zmienna.isPartOfArray=false;
		zmienna.isIterator=true;
		zmienna.czyZainicjowana=true;
		nrWolnejKomorkiWPamieci++;
		tablicaZmiennych.push_back(zmienna);
		kodProgramu.push_back("LOADI 1");
		kodProgramu.push_back("STORE "+to_string(nrWolnejKomorkiWPamieci));
		kodProgramu.push_back("LOADI 0");
		kodProgramu.push_back("STORE "+to_string(zwrocIndeks($2,0)));
		kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($2,0)));
		kodProgramu.push_back("INC");
		kodProgramu.push_back("SUB "+to_string(nrWolnejKomorkiWPamieci));
		kodProgramu.push_back("WKLEIC");
		skokDoPrzodu.push_back(nrLinii+7);
		nrWolnejKomorkiWPamieci++;skokDoTylu.push_back(nrLinii+5);nrLinii+=8;}
commands ENDFOR {
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($2,0)));
	kodProgramu.push_back("JZERO "+to_string(nrLinii+5));
	kodProgramu.push_back("DEC");
	kodProgramu.push_back("STORE "+to_string(zwrocIndeks($2,0)));
	kodProgramu.push_back("JUMP "+to_string(skokDoTylu.back()));
	Skok skok;
	skok.tekstLinijki="JZERO "+to_string(nrLinii+5);
	skok.nrLinijkiDoEdycji=skokDoPrzodu.back();
	skokDoPrzoduEdycja.push_back(skok);
	nrLinii+=5;skokDoTylu.pop_back();
	skokDoPrzodu.pop_back();
	usunIterator($2);}
| FOR PIDENTIFIER FROM PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS DOWNTO value DO {
	if(czyZmiennaIstnieje($2)){ cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako iterator."<<endl;}
	if(!czyZmiennaZainicjowana($4)||!czyZmiennaZainicjowana($6)||!czyZmiennaZainicjowana($9)){
		cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	if(!czyTab($4)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako tablica."<<endl;exit(1);}
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($4,0)))) dajNum(to_string(zwrocIndeks($4,0)));
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($4,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($6,0)));
	kodProgramu.push_back("STORE 0");nrLinii+=3;
		int s9=0;
		if(czyTab($9)){s9=dodanieDoTab.back();dodanieDoTab.pop_back();}
		Zmienna zmienna;
		zmienna.nazwaZmiennej=$2;
		zmienna.nrKomorkiWPamieci=nrWolnejKomorkiWPamieci;
		zmienna.dlugoscTablicy=1;
		zmienna.isPartOfArray=false;
		zmienna.isIterator=true;
		zmienna.czyZainicjowana=true;
		nrWolnejKomorkiWPamieci++;
		tablicaZmiennych.push_back(zmienna);
		kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($9,s9)));
		kodProgramu.push_back("STORE "+to_string(nrWolnejKomorkiWPamieci));
		kodProgramu.push_back("LOADI 0");
		kodProgramu.push_back("STORE "+to_string(zwrocIndeks($2,0)));
		kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($2,0)));
		kodProgramu.push_back("INC");
		kodProgramu.push_back("SUB "+to_string(nrWolnejKomorkiWPamieci));
		kodProgramu.push_back("WKLEIC");
		skokDoPrzodu.push_back(nrLinii+7);
		nrWolnejKomorkiWPamieci++;skokDoTylu.push_back(nrLinii+5);nrLinii+=8;
}
commands ENDFOR {
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($2,0)));
	kodProgramu.push_back("JZERO "+to_string(nrLinii+5));
	kodProgramu.push_back("DEC");
	kodProgramu.push_back("STORE "+to_string(zwrocIndeks($2,0)));
	kodProgramu.push_back("JUMP "+to_string(skokDoTylu.back()));
	Skok skok;
	skok.tekstLinijki="JZERO "+to_string(nrLinii+5);
	skok.nrLinijkiDoEdycji=skokDoPrzodu.back();
	skokDoPrzoduEdycja.push_back(skok);
	nrLinii+=5;skokDoTylu.pop_back();
	skokDoPrzodu.pop_back();
	usunIterator($2);}
| FOR PIDENTIFIER FROM value DOWNTO PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS DO {
	if(czyZmiennaIstnieje($2)){ cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako iterator."<<endl;}
	if(!czyZmiennaZainicjowana($4)||!czyZmiennaZainicjowana($6)||!czyZmiennaZainicjowana($8)){
		cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	if(!czyTab($6)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako tablica."<<endl;exit(1);}
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($6,0)))) dajNum(to_string(zwrocIndeks($6,0)));
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($6,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($8,0)));
	kodProgramu.push_back("STORE 0");nrLinii+=3;
		int s4=0;
		if(czyTab($4)){s4=dodanieDoTab.back();dodanieDoTab.pop_back();}
		Zmienna zmienna;
		zmienna.nazwaZmiennej=$2;
		zmienna.nrKomorkiWPamieci=nrWolnejKomorkiWPamieci;
		zmienna.dlugoscTablicy=1;
		zmienna.isPartOfArray=false;
		zmienna.isIterator=true;
		zmienna.czyZainicjowana=true;
		nrWolnejKomorkiWPamieci++;
		tablicaZmiennych.push_back(zmienna);
		kodProgramu.push_back("LOADI 0");
		kodProgramu.push_back("STORE "+to_string(nrWolnejKomorkiWPamieci));
		kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($4,s4)));
		kodProgramu.push_back("STORE "+to_string(zwrocIndeks($2,0)));
		kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($2,0)));
		kodProgramu.push_back("INC");
		kodProgramu.push_back("SUB "+to_string(nrWolnejKomorkiWPamieci));
		kodProgramu.push_back("WKLEIC");
		skokDoPrzodu.push_back(nrLinii+7);
		nrWolnejKomorkiWPamieci++;skokDoTylu.push_back(nrLinii+5);nrLinii+=8;
}
commands ENDFOR {
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($2,0)));
	kodProgramu.push_back("JZERO "+to_string(nrLinii+5));
	kodProgramu.push_back("DEC");
	kodProgramu.push_back("STORE "+to_string(zwrocIndeks($2,0)));
	kodProgramu.push_back("JUMP "+to_string(skokDoTylu.back()));
	Skok skok;
	skok.tekstLinijki="JZERO "+to_string(nrLinii+5);
	skok.nrLinijkiDoEdycji=skokDoPrzodu.back();
	skokDoPrzoduEdycja.push_back(skok);
	nrLinii+=5;skokDoTylu.pop_back();
	skokDoPrzodu.pop_back();
	usunIterator($2);}
//READ
| READ identifier SREDNIK {
	if(czyIterator($2)){cerr<<"Błąd w linijce "<<yylineno<<". Nie mozna modyfikowac iteratora."<<endl;exit(1);}
	int s2=0;
	if(czyTab($2)){s2=dodanieDoTab.back();dodanieDoTab.pop_back();}
	zainicjuj($2);
	kodProgramu.push_back("GET");
	kodProgramu.push_back("STORE "+to_string(zwrocIndeks($2,s2)));
	nrLinii+=2;	
	}
| READ PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS SREDNIK {
	if(!czyZmiennaZainicjowana($2)||!czyZmiennaZainicjowana($4)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	if(!czyTab($2)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako tablica."<<endl;exit(1);}
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($2,0)))) dajNum(to_string(zwrocIndeks($2,0)));
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($2,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($4,0)));
	kodProgramu.push_back("STORE 0");
	kodProgramu.push_back("GET");
	kodProgramu.push_back("STOREI 0");
	nrLinii+=5;
	}
| WRITE value SREDNIK {
	if(!czyZmiennaZainicjowana($2)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana."<<endl;exit(1);}
	int s2=0;
	if(czyTab($2)){s2=dodanieDoTab.back();dodanieDoTab.pop_back();}
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($2,s2)));
	kodProgramu.push_back("PUT");
	nrLinii+=2;
	}
| WRITE PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS SREDNIK {
	if(!czyZmiennaZainicjowana($2)||!czyZmiennaZainicjowana($4)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	if(!czyTab($2)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako tablica."<<endl;exit(1);}
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($2,0)))) dajNum(to_string(zwrocIndeks($2,0)));
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($2,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($4,0)));
	kodProgramu.push_back("STORE 0");
	kodProgramu.push_back("LOADI 0");
	kodProgramu.push_back("PUT");
	nrLinii+=5;
	}
;

if
: commands ELSE {
	kodProgramu.push_back("WKLEIC");
	skokDoPrzoduIf.push_back(nrLinii);
	Skok skok;
	skok.tekstLinijki="JZERO "+to_string(nrLinii+1);
	skok.nrLinijkiDoEdycji=skokDoPrzodu.back();
	skokDoPrzoduEdycja.push_back(skok);
	nrLinii++;skokDoPrzodu.pop_back();}
commands ENDIF {
	Skok skok;
	skok.tekstLinijki="JUMP "+to_string(nrLinii);
	skok.nrLinijkiDoEdycji=skokDoPrzoduIf.back();
	skokDoPrzoduEdycja.push_back(skok);
	skokDoPrzoduIf.pop_back();}
| commands ENDIF {
	Skok skok;
	skok.tekstLinijki="JZERO "+to_string(nrLinii);
	skok.nrLinijkiDoEdycji=skokDoPrzodu.back();
	skokDoPrzoduEdycja.push_back(skok);
	skokDoPrzodu.pop_back();}
;

expression
: value {
	if(!czyZmiennaZainicjowana($1)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	int s1=0;
	if(czyTab($1)){s1=dodanieDoTab.back();dodanieDoTab.pop_back();}
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($1,s1)));
	nrLinii++;
	}
| PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS {
	if(!czyZmiennaZainicjowana($1)||!czyZmiennaZainicjowana($3)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	if(!czyTab($1)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako tablica."<<endl;exit(1);}
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($1,0)))) dajNum(to_string(zwrocIndeks($1,0)));
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($1,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($3,0)));
	kodProgramu.push_back("STORE 0");
	kodProgramu.push_back("LOADI 0");
	nrLinii+=4;
	}
//DODAWANIE
| value DODAWANIE value {
	if(!czyZmiennaZainicjowana($1)||!czyZmiennaZainicjowana($3)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	int s1=0,s3=0;
	if(czyTab($3)){s3=dodanieDoTab.back();dodanieDoTab.pop_back();}
	if(czyTab($1)){s1=dodanieDoTab.back();dodanieDoTab.pop_back();}
	if($3=="1"){
		kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($1,s1)));
		kodProgramu.push_back("INC");
		nrLinii+=2;
	}
	else{
		kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($1,s1)));
		kodProgramu.push_back("ADD "+to_string(zwrocIndeks($3,s3)));
		nrLinii+=2;
	}
}
| PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS DODAWANIE PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS {
	if(!czyZmiennaZainicjowana($1)||!czyZmiennaZainicjowana($3)||!czyZmiennaZainicjowana($6)||!czyZmiennaZainicjowana($8)){
		cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	if(!czyTab($1)||!czyTab($6)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako tablica."<<endl;exit(1);}
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($1,0)))) dajNum(to_string(zwrocIndeks($1,0)));
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($6,0)))) dajNum(to_string(zwrocIndeks($6,0)));
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($1,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($3,0)));
	kodProgramu.push_back("STORE 0");
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($6,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($8,0)));
	kodProgramu.push_back("STORE 1");
	kodProgramu.push_back("LOADI 0");
	kodProgramu.push_back("ADDI 1");
	nrLinii+=8;}
| value DODAWANIE PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS {
	if(!czyZmiennaZainicjowana($1)||!czyZmiennaZainicjowana($3)||!czyZmiennaZainicjowana($5)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	if(!czyTab($3)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako tablica."<<endl;exit(1);}
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($3,0)))) dajNum(to_string(zwrocIndeks($3,0)));
	int s1=0;
	if(czyTab($1)){s1=dodanieDoTab.back();dodanieDoTab.pop_back();}
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($3,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($5,0)));
	kodProgramu.push_back("STORE 0");
	kodProgramu.push_back("LOADI 0");
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($1,s1)));
	nrLinii+=5;}
| PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS DODAWANIE value {
	if(!czyZmiennaZainicjowana($1)||!czyZmiennaZainicjowana($3)||!czyZmiennaZainicjowana($6)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowan/niezadeklarowanaa."<<endl;exit(1);}
	if(!czyTab($1)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako tablica."<<endl;exit(1);}
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($1,0)))) dajNum(to_string(zwrocIndeks($1,0)));
	int s6=0;
	if(czyTab($6)){s6=dodanieDoTab.back();dodanieDoTab.pop_back();}
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($1,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($3,0)));
	kodProgramu.push_back("STORE 0");
	kodProgramu.push_back("LOADI 0");
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($6,s6)));
	nrLinii+=5;}
//ODEJMOWANIE
| value ODEJMOWANIE value {
	if(!czyZmiennaZainicjowana($1)||!czyZmiennaZainicjowana($3)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	int s1=0,s3=0;
	if(czyTab($3)){s3=dodanieDoTab.back();dodanieDoTab.pop_back();}
	if(czyTab($1)){s1=dodanieDoTab.back();dodanieDoTab.pop_back();}
	if($3=="1"){
		kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($1,s1)));
		kodProgramu.push_back("DEC");
		nrLinii+=2;
	}
	else{
		kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($1,s1)));
		kodProgramu.push_back("SUB "+to_string(zwrocIndeks($3,s3)));
		nrLinii+=2;}
	}
| PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS ODEJMOWANIE PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS {
	if(!czyZmiennaZainicjowana($1)||!czyZmiennaZainicjowana($3)||!czyZmiennaZainicjowana($6)||!czyZmiennaZainicjowana($8)){
		cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	if(!czyTab($1)||!czyTab($6)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako tablica."<<endl;exit(1);}
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($1,0)))) dajNum(to_string(zwrocIndeks($1,0)));
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($6,0)))) dajNum(to_string(zwrocIndeks($6,0)));
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($1,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($3,0)));
	kodProgramu.push_back("STORE 0");
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($6,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($8,0)));
	kodProgramu.push_back("STORE 1");
	kodProgramu.push_back("LOADI 0");
	kodProgramu.push_back("SUBI 1");
	nrLinii+=8;}
| value ODEJMOWANIE PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS {
	if(!czyZmiennaZainicjowana($1)||!czyZmiennaZainicjowana($3)||!czyZmiennaZainicjowana($5)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	if(!czyTab($3)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako tablica."<<endl;exit(1);}
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($3,0)))) dajNum(to_string(zwrocIndeks($3,0)));
	int s1=0;
	if(czyTab($1)){s1=dodanieDoTab.back();dodanieDoTab.pop_back();}
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($3,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($5,0)));
	kodProgramu.push_back("STORE 0");
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($1,s1)));
	kodProgramu.push_back("SUBI 0");
	nrLinii+=5;}
| PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS ODEJMOWANIE value {
	if(!czyZmiennaZainicjowana($1)||!czyZmiennaZainicjowana($3)||!czyZmiennaZainicjowana($6)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	if(!czyTab($1)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako tablica."<<endl;exit(1);}
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($1,0)))) dajNum(to_string(zwrocIndeks($1,0)));
	int s6=0;
	if(czyTab($6)){s6=dodanieDoTab.back();dodanieDoTab.pop_back();}
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($1,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($3,0)));
	kodProgramu.push_back("STORE 0");
	kodProgramu.push_back("LOADI 0");
	kodProgramu.push_back("SUB "+to_string(zwrocIndeks($6,s6)));
	nrLinii+=5;}
//MNOZENIE
| value MNOZENIE value {
	if(!czyZmiennaZainicjowana($1)||!czyZmiennaZainicjowana($3)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	int s1=0,s3=0;
	if(czyTab($3)){s3=dodanieDoTab.back();dodanieDoTab.pop_back();}
	if(czyTab($1)){s1=dodanieDoTab.back();dodanieDoTab.pop_back();}
	if($3=="2"){
		kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($1,s1)));
		kodProgramu.push_back("SHL");
		nrLinii+=2;
	}
	else if($1=="2"){
		kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($3,s3)));
		kodProgramu.push_back("SHL");
		nrLinii+=2;
	}
	else{
		kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($3,s3)));
		kodProgramu.push_back("SUB "+to_string(zwrocIndeks($1,s1)));
		kodProgramu.push_back("JZERO "+to_string(nrLinii+8));
		kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($3,s3)));
		kodProgramu.push_back("STORE 1");
		kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($1,s1)));
		kodProgramu.push_back("STORE 2");
		kodProgramu.push_back("JUMP "+to_string(nrLinii+12));
		kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($1,s1)));
		kodProgramu.push_back("STORE 1");
		kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($3,s3)));
		mnozenie();
		nrLinii+=29;
	}}
| PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS MNOZENIE PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS {
	if(!czyZmiennaZainicjowana($1)||!czyZmiennaZainicjowana($3)||!czyZmiennaZainicjowana($6)||!czyZmiennaZainicjowana($8)){
		cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	if(!czyTab($1)||!czyTab($6)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako tablica."<<endl;exit(1);}
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($1,0)))) dajNum(to_string(zwrocIndeks($1,0)));
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($6,0)))) dajNum(to_string(zwrocIndeks($6,0)));
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($1,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($3,0)));
	kodProgramu.push_back("STORE 3");
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($6,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($8,0)));
	kodProgramu.push_back("STORE 4");nrLinii+=6;
	kodProgramu.push_back("LOADI 4");
	kodProgramu.push_back("SUBI 3");
	kodProgramu.push_back("JZERO "+to_string(nrLinii+8));
	kodProgramu.push_back("LOADI 4");
	kodProgramu.push_back("STORE 1");
	kodProgramu.push_back("LOADI 3");
	kodProgramu.push_back("STORE 2");
	kodProgramu.push_back("JUMP "+to_string(nrLinii+12));
	kodProgramu.push_back("LOADI 3");
	kodProgramu.push_back("STORE 1");
	kodProgramu.push_back("LOADI 4");
	mnozenie();
	nrLinii+=29;}
| value MNOZENIE PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS {
	if(!czyZmiennaZainicjowana($1)||!czyZmiennaZainicjowana($3)||!czyZmiennaZainicjowana($5)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	if(!czyTab($3)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako tablica."<<endl;exit(1);}
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($3,0)))) dajNum(to_string(zwrocIndeks($3,0)));
	int s1=0;
	if(czyTab($1)){s1=dodanieDoTab.back();dodanieDoTab.pop_back();}
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($3,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($5,0)));
	kodProgramu.push_back("STORE 3");nrLinii+=3;
	kodProgramu.push_back("LOADI 3");
	kodProgramu.push_back("SUB "+to_string(zwrocIndeks($1,s1)));
	kodProgramu.push_back("JZERO "+to_string(nrLinii+8));
	kodProgramu.push_back("LOADI 3");
	kodProgramu.push_back("STORE 1");
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($1,s1)));
	kodProgramu.push_back("STORE 2");
	kodProgramu.push_back("JUMP "+to_string(nrLinii+12));
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($1,s1)));
	kodProgramu.push_back("STORE 1");
	kodProgramu.push_back("LOADI 3");
	mnozenie();
	nrLinii+=29;}
| PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS MNOZENIE value {
	if(!czyZmiennaZainicjowana($1)||!czyZmiennaZainicjowana($3)||!czyZmiennaZainicjowana($6)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	if(!czyTab($1)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako tablica."<<endl;exit(1);}
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($1,0)))) dajNum(to_string(zwrocIndeks($1,0)));
	int s6=0;
	if(czyTab($6)){s6=dodanieDoTab.back();dodanieDoTab.pop_back();}
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($1,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($3,0)));
	kodProgramu.push_back("STORE 3");nrLinii+=3;
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($6,s6)));
	kodProgramu.push_back("SUBI 3");
	kodProgramu.push_back("JZERO "+to_string(nrLinii+8));
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($6,s6)));
	kodProgramu.push_back("STORE 1");
	kodProgramu.push_back("LOADI 3");
	kodProgramu.push_back("STORE 2");
	kodProgramu.push_back("JUMP "+to_string(nrLinii+12));
	kodProgramu.push_back("LOADI 3");
	kodProgramu.push_back("STORE 1");
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($6,s6)));
	mnozenie();
	nrLinii+=29;}
//DZIELENIE
| value DZIELENIE value {
	if(!czyZmiennaZainicjowana($1)||!czyZmiennaZainicjowana($3)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	int s1=0,s3=0;
	if(czyTab($3)){s3=dodanieDoTab.back();dodanieDoTab.pop_back();}
	if(czyTab($1)){s1=dodanieDoTab.back();dodanieDoTab.pop_back();}
	if($3=="2"){
		kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($1,s1)));
		kodProgramu.push_back("SHR");
		nrLinii+=2;
	}
	else if($3=="0"){
		kodProgramu.push_back("ZERO");
		nrLinii+=1;
	}
	else{
		kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($1,s1)));
		kodProgramu.push_back("STORE 1");
		kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($3,s3)));
		kodProgramu.push_back("JZERO "+to_string(nrLinii+37));
		dzielenie();
		kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($3,s3)));
		kodProgramu.push_back("SUB 2");
		kodProgramu.push_back("JZERO "+to_string(nrLinii+15));
		kodProgramu.push_back("LOAD 0");
		nrLinii+=36;
	}}
| PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS DZIELENIE PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS {
	if(!czyZmiennaZainicjowana($1)||!czyZmiennaZainicjowana($3)||!czyZmiennaZainicjowana($6)||!czyZmiennaZainicjowana($8)){
		cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	if(!czyTab($1)||!czyTab($6)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako tablica."<<endl;exit(1);}
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($1,0)))) dajNum(to_string(zwrocIndeks($1,0)));
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($6,0)))) dajNum(to_string(zwrocIndeks($6,0)));
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($1,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($3,0)));
	kodProgramu.push_back("STORE 3");
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($6,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($8,0)));
	kodProgramu.push_back("STORE 4");nrLinii+=6;
	kodProgramu.push_back("LOADI 3");
	kodProgramu.push_back("STORE 1");
	kodProgramu.push_back("LOADI 4");
	kodProgramu.push_back("JZERO "+to_string(nrLinii+37));
	dzielenie();
	kodProgramu.push_back("LOADI 4");
	kodProgramu.push_back("SUB 2");
	kodProgramu.push_back("JZERO "+to_string(nrLinii+15));
	kodProgramu.push_back("LOAD 0");
	nrLinii+=36;}
| value DZIELENIE PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS {
	if(!czyZmiennaZainicjowana($1)||!czyZmiennaZainicjowana($3)||!czyZmiennaZainicjowana($5)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	if(!czyTab($3)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako tablica."<<endl;exit(1);}
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($3,0)))) dajNum(to_string(zwrocIndeks($3,0)));
	int s1=0;
	if(czyTab($1)){s1=dodanieDoTab.back();dodanieDoTab.pop_back();}
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($3,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($5,0)));
	kodProgramu.push_back("STORE 3");nrLinii+=3;
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($1,s1)));
	kodProgramu.push_back("STORE 1");
	kodProgramu.push_back("LOADI 3");
	kodProgramu.push_back("JZERO "+to_string(nrLinii+37));
	dzielenie();
	kodProgramu.push_back("LOADI 3");
	kodProgramu.push_back("SUB 2");
	kodProgramu.push_back("JZERO "+to_string(nrLinii+15));
	kodProgramu.push_back("LOAD 0");
	nrLinii+=36;}
| PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS DZIELENIE value {
	if(!czyZmiennaZainicjowana($1)||!czyZmiennaZainicjowana($3)||!czyZmiennaZainicjowana($6)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	if(!czyTab($1)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako tablica."<<endl;exit(1);}
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($1,0)))) dajNum(to_string(zwrocIndeks($1,0)));
	int s6=0;
	if(czyTab($6)){s6=dodanieDoTab.back();dodanieDoTab.pop_back();}
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($1,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($3,0)));
	kodProgramu.push_back("STORE 3");nrLinii+=3;
	kodProgramu.push_back("LOADI 3");
	kodProgramu.push_back("STORE 1");
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($6,s6)));
	kodProgramu.push_back("JZERO "+to_string(nrLinii+37));
	dzielenie();
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($6,s6)));
	kodProgramu.push_back("SUB 2");
	kodProgramu.push_back("JZERO "+to_string(nrLinii+15));
	kodProgramu.push_back("LOAD 0");
	nrLinii+=36;}
//MODULO
| value MODULO value{
	if(!czyZmiennaZainicjowana($1)||!czyZmiennaZainicjowana($3)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	int s1=0,s3=0;
	if(czyTab($3)){s3=dodanieDoTab.back();dodanieDoTab.pop_back();}
	if(czyTab($1)){s1=dodanieDoTab.back();dodanieDoTab.pop_back();}
	if($3=="2"){
		kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($1,s1)));
		kodProgramu.push_back("JODD "+to_string(nrLinii+4));
		kodProgramu.push_back("ZERO");
		kodProgramu.push_back("JUMP "+to_string(nrLinii+6));
		kodProgramu.push_back("ZERO");
		kodProgramu.push_back("INC");nrLinii+=6;
	}
	else{
		kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($1,s1)));
		kodProgramu.push_back("STORE 1");
		kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($3,s3)));
		kodProgramu.push_back("JZERO "+to_string(nrLinii+28));
		modulo();
		kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($3,s3)));
		kodProgramu.push_back("SUB 2");
		kodProgramu.push_back("JZERO "+to_string(nrLinii+13));
		kodProgramu.push_back("LOAD 1");
		nrLinii+=27;	
	}
}
| PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS MODULO PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS {
	if(!czyZmiennaZainicjowana($1)||!czyZmiennaZainicjowana($3)||!czyZmiennaZainicjowana($6)||!czyZmiennaZainicjowana($8)){
		cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	if(!czyTab($1)||!czyTab($6)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako tablica."<<endl;exit(1);}
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($1,0)))) dajNum(to_string(zwrocIndeks($1,0)));
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($6,0)))) dajNum(to_string(zwrocIndeks($6,0)));
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($1,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($3,0)));
	kodProgramu.push_back("STORE 3");
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($6,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($8,0)));
	kodProgramu.push_back("STORE 4");nrLinii+=6;
	kodProgramu.push_back("LOADI 3");
	kodProgramu.push_back("STORE 1");
	kodProgramu.push_back("LOADI 4");
	kodProgramu.push_back("JZERO "+to_string(nrLinii+28));
	modulo();
	kodProgramu.push_back("LOADI 4");
	kodProgramu.push_back("SUB 2");
	kodProgramu.push_back("JZERO "+to_string(nrLinii+13));
	kodProgramu.push_back("LOAD 1");
	nrLinii+=27;}
| value MODULO PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS {
	if(!czyZmiennaZainicjowana($1)||!czyZmiennaZainicjowana($3)||!czyZmiennaZainicjowana($5)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	if(!czyTab($3)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako tablica."<<endl;exit(1);}
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($3,0)))) dajNum(to_string(zwrocIndeks($3,0)));
	int s1=0;
	if(czyTab($1)){s1=dodanieDoTab.back();dodanieDoTab.pop_back();}
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($3,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($5,0)));
	kodProgramu.push_back("STORE 3");nrLinii+=3;
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($1,s1)));
	kodProgramu.push_back("STORE 1");
	kodProgramu.push_back("LOADI 3");
	kodProgramu.push_back("JZERO "+to_string(nrLinii+28));
	modulo();
	kodProgramu.push_back("LOADI 3");
	kodProgramu.push_back("SUB 2");
	kodProgramu.push_back("JZERO "+to_string(nrLinii+13));
	kodProgramu.push_back("LOAD 1");
	nrLinii+=27;}
| PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS MODULO value {
	if(!czyZmiennaZainicjowana($1)||!czyZmiennaZainicjowana($3)||!czyZmiennaZainicjowana($6)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	if(!czyTab($1)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako tablica."<<endl;exit(1);}
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($1,0)))) dajNum(to_string(zwrocIndeks($1,0)));
	int s6=0;
	if(czyTab($6)){s6=dodanieDoTab.back();dodanieDoTab.pop_back();}
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($1,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($3,0)));
	kodProgramu.push_back("STORE 3");nrLinii+=3;
	kodProgramu.push_back("LOADI 3");
	kodProgramu.push_back("STORE 1");
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($6,s6)));
	kodProgramu.push_back("JZERO "+to_string(nrLinii+28));
	modulo();
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($6,s6)));
	kodProgramu.push_back("SUB 2");
	kodProgramu.push_back("JZERO "+to_string(nrLinii+13));
	kodProgramu.push_back("LOAD 1");
	nrLinii+=27;}
;

condition //a=0 <==> false
//ROWNY
: value ROWNY value {
	if(!czyZmiennaZainicjowana($1)||!czyZmiennaZainicjowana($3)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	int s1=0,s3=0;
	if(czyTab($3)){s3=dodanieDoTab.back();dodanieDoTab.pop_back();}
	if(czyTab($1)){s1=dodanieDoTab.back();dodanieDoTab.pop_back();}
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($1,s1)));
	kodProgramu.push_back("SUB "+to_string(zwrocIndeks($3,s3)));
	kodProgramu.push_back("STORE 0");
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($3,s3)));
	kodProgramu.push_back("SUB "+to_string(zwrocIndeks($1,s1)));
	kodProgramu.push_back("ADD 0");
	kodProgramu.push_back("STORE 0");
	kodProgramu.push_back("ZERO");
	kodProgramu.push_back("INC");
	kodProgramu.push_back("SUB 0");
	nrLinii+=10;}
| PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS ROWNY PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS {
	if(!czyZmiennaZainicjowana($1)||!czyZmiennaZainicjowana($3)||!czyZmiennaZainicjowana($6)||!czyZmiennaZainicjowana($8)){
		cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	if(!czyTab($1)||!czyTab($6)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako tablica."<<endl;exit(1);}
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($1,0)))) dajNum(to_string(zwrocIndeks($1,0)));
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($6,0)))) dajNum(to_string(zwrocIndeks($6,0)));
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($1,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($3,0)));
	kodProgramu.push_back("STORE 0");
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($6,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($8,0)));
	kodProgramu.push_back("STORE 1");
	kodProgramu.push_back("LOADI 0");
	kodProgramu.push_back("SUBI 1");
	kodProgramu.push_back("STORE 2");
	kodProgramu.push_back("LOADI 1");
	kodProgramu.push_back("SUBI 0");
	kodProgramu.push_back("ADD 2");
	kodProgramu.push_back("STORE 2");
	kodProgramu.push_back("ZERO");
	kodProgramu.push_back("INC");
	kodProgramu.push_back("SUB 2");
	nrLinii+=16;}
| value ROWNY PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS {
	if(!czyZmiennaZainicjowana($1)||!czyZmiennaZainicjowana($3)||!czyZmiennaZainicjowana($5)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	if(!czyTab($3)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako tablica."<<endl;exit(1);}
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($3,0)))) dajNum(to_string(zwrocIndeks($3,0)));
	int s1=0;
	if(czyTab($1)){s1=dodanieDoTab.back();dodanieDoTab.pop_back();}
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($3,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($5,0)));
	kodProgramu.push_back("STORE 1");
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($1,s1)));
	kodProgramu.push_back("SUBI 1");
	kodProgramu.push_back("STORE 0");
	kodProgramu.push_back("LOADI 1");
	kodProgramu.push_back("SUB "+to_string(zwrocIndeks($1,s1)));
	kodProgramu.push_back("ADD 0");
	kodProgramu.push_back("STORE 0");
	kodProgramu.push_back("ZERO");
	kodProgramu.push_back("INC");
	kodProgramu.push_back("SUB 0");
	nrLinii+=13;}
| PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS ROWNY value {
	if(!czyZmiennaZainicjowana($1)||!czyZmiennaZainicjowana($3)||!czyZmiennaZainicjowana($6)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	if(!czyTab($1)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako tablica."<<endl;exit(1);}
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($1,0)))) dajNum(to_string(zwrocIndeks($1,0)));
	int s6=0;
	if(czyTab($6)){s6=dodanieDoTab.back();dodanieDoTab.pop_back();}
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($1,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($3,0)));
	kodProgramu.push_back("STORE 1");
	kodProgramu.push_back("LOADI 1");
	kodProgramu.push_back("SUB "+to_string(zwrocIndeks($6,s6)));
	kodProgramu.push_back("STORE 0");
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($6,s6)));
	kodProgramu.push_back("SUBI 1");
	kodProgramu.push_back("ADD 0");
	kodProgramu.push_back("STORE 0");
	kodProgramu.push_back("ZERO");
	kodProgramu.push_back("INC");
	kodProgramu.push_back("SUB 0");
	nrLinii+=13;}
//ROZNY
| value ROZNY value {
	if(!czyZmiennaZainicjowana($1)||!czyZmiennaZainicjowana($3)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	int s1=0,s3=0;
	if(czyTab($3)){s3=dodanieDoTab.back();dodanieDoTab.pop_back();}
	if(czyTab($1)){s1=dodanieDoTab.back();dodanieDoTab.pop_back();}
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($1,s1)));
	kodProgramu.push_back("SUB "+to_string(zwrocIndeks($3,s3)));
	kodProgramu.push_back("STORE 0");
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($3,s3)));
	kodProgramu.push_back("SUB "+to_string(zwrocIndeks($1,s1)));
	kodProgramu.push_back("ADD 0");
	nrLinii+=6;}
| PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS ROZNY PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS {
	if(!czyZmiennaZainicjowana($1)||!czyZmiennaZainicjowana($3)||!czyZmiennaZainicjowana($6)||!czyZmiennaZainicjowana($8)){
		cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	if(!czyTab($1)||!czyTab($6)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako tablica."<<endl;exit(1);}
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($1,0)))) dajNum(to_string(zwrocIndeks($1,0)));
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($6,0)))) dajNum(to_string(zwrocIndeks($6,0)));
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($1,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($3,0)));
	kodProgramu.push_back("STORE 0");
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($6,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($8,0)));
	kodProgramu.push_back("STORE 1");
	kodProgramu.push_back("LOADI 0");
	kodProgramu.push_back("SUBI 1");
	kodProgramu.push_back("STORE 2");
	kodProgramu.push_back("LOADI 1");
	kodProgramu.push_back("SUBI 0");
	kodProgramu.push_back("ADD 2");
	nrLinii+=12;}
| value ROZNY PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS {
	if(!czyZmiennaZainicjowana($1)||!czyZmiennaZainicjowana($3)||!czyZmiennaZainicjowana($5)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	if(!czyTab($3)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako tablica."<<endl;exit(1);}
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($3,0)))) dajNum(to_string(zwrocIndeks($3,0)));
	int s1=0;
	if(czyTab($1)){s1=dodanieDoTab.back();dodanieDoTab.pop_back();}
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($3,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($5,0)));
	kodProgramu.push_back("STORE 0");
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($1,s1)));
	kodProgramu.push_back("SUBI 0");
	kodProgramu.push_back("STORE 1");
	kodProgramu.push_back("LOADI 0");
	kodProgramu.push_back("SUB "+to_string(zwrocIndeks($1,s1)));
	kodProgramu.push_back("ADD 1");
	nrLinii+=9;}
| PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS ROZNY value {
	if(!czyZmiennaZainicjowana($1)||!czyZmiennaZainicjowana($3)||!czyZmiennaZainicjowana($6)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	if(!czyTab($1)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako tablica."<<endl;exit(1);}
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($1,0)))) dajNum(to_string(zwrocIndeks($1,0)));
	int s6=0;
	if(czyTab($6)){s6=dodanieDoTab.back();dodanieDoTab.pop_back();}
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($1,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($3,0)));
	kodProgramu.push_back("STORE 0");
	kodProgramu.push_back("LOADI 0");
	kodProgramu.push_back("SUB "+to_string(zwrocIndeks($6,s6)));
	kodProgramu.push_back("STORE 1");
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($6,s6)));
	kodProgramu.push_back("SUBI 0");
	kodProgramu.push_back("ADD 1");
	nrLinii+=9;}
//MNIEJSZY
| value MNIEJSZY value {
	if(!czyZmiennaZainicjowana($1)||!czyZmiennaZainicjowana($3)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	int s1=0,s3=0;
	if(czyTab($3)){s3=dodanieDoTab.back();dodanieDoTab.pop_back();}
	if(czyTab($1)){s1=dodanieDoTab.back();dodanieDoTab.pop_back();}
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($3,s3)));
	kodProgramu.push_back("SUB "+to_string(zwrocIndeks($1,s1)));
	nrLinii+=2;}
| PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS MNIEJSZY PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS {
	if(!czyZmiennaZainicjowana($1)||!czyZmiennaZainicjowana($3)||!czyZmiennaZainicjowana($6)||!czyZmiennaZainicjowana($8)){
		cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	if(!czyTab($1)||!czyTab($6)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako tablica."<<endl;exit(1);}
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($1,0)))) dajNum(to_string(zwrocIndeks($1,0)));
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($6,0)))) dajNum(to_string(zwrocIndeks($6,0)));
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($1,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($3,0)));
	kodProgramu.push_back("STORE 0");
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($6,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($8,0)));
	kodProgramu.push_back("STORE 1");
	kodProgramu.push_back("LOADI 1");
	kodProgramu.push_back("SUBI 0");
	nrLinii+=8;}
| value MNIEJSZY PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS {
	if(!czyZmiennaZainicjowana($1)||!czyZmiennaZainicjowana($3)||!czyZmiennaZainicjowana($5)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	if(!czyTab($3)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako tablica."<<endl;exit(1);}
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($3,0)))) dajNum(to_string(zwrocIndeks($3,0)));
	int s1=0;
	if(czyTab($1)){s1=dodanieDoTab.back();dodanieDoTab.pop_back();}
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($3,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($5,0)));
	kodProgramu.push_back("STORE 0");
	kodProgramu.push_back("LOADI 0");
	kodProgramu.push_back("SUB "+to_string(zwrocIndeks($1,s1)));
	nrLinii+=5;}
| PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS MNIEJSZY value {
	if(!czyZmiennaZainicjowana($1)||!czyZmiennaZainicjowana($3)||!czyZmiennaZainicjowana($6)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	if(!czyTab($1)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako tablica."<<endl;exit(1);}
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($1,0)))) dajNum(to_string(zwrocIndeks($1,0)));
	int s6=0;
	if(czyTab($6)){s6=dodanieDoTab.back();dodanieDoTab.pop_back();}
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($1,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($3,0)));
	kodProgramu.push_back("STORE 0");
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($6,s6)));
	kodProgramu.push_back("SUBI 0");
	nrLinii+=5;}
//WIEKSZY
| value WIEKSZY value {
	if(!czyZmiennaZainicjowana($1)||!czyZmiennaZainicjowana($3)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	int s1=0,s3=0;
	if(czyTab($3)){s3=dodanieDoTab.back();dodanieDoTab.pop_back();}
	if(czyTab($1)){s1=dodanieDoTab.back();dodanieDoTab.pop_back();}
	if($3=="0"){ kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($1,s1)));nrLinii++;}
	else{
		kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($1,s1)));
		kodProgramu.push_back("SUB "+to_string(zwrocIndeks($3,s3)));
		nrLinii+=2;}
	}
| PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS WIEKSZY PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS {
	if(!czyZmiennaZainicjowana($1)||!czyZmiennaZainicjowana($3)||!czyZmiennaZainicjowana($6)||!czyZmiennaZainicjowana($8)){
		cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	if(!czyTab($1)||!czyTab($6)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako tablica."<<endl;exit(1);}
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($1,0)))) dajNum(to_string(zwrocIndeks($1,0)));
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($6,0)))) dajNum(to_string(zwrocIndeks($6,0)));
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($1,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($3,0)));
	kodProgramu.push_back("STORE 0");
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($6,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($8,0)));
	kodProgramu.push_back("STORE 1");
	kodProgramu.push_back("LOADI 0");
	kodProgramu.push_back("SUBI 1");
	nrLinii+=8;}
| value WIEKSZY PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS {
	if(!czyZmiennaZainicjowana($1)||!czyZmiennaZainicjowana($3)||!czyZmiennaZainicjowana($5)){
		cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	if(!czyTab($3)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako tablica."<<endl;exit(1);}
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($3,0)))) dajNum(to_string(zwrocIndeks($3,0)));
	int s1=0;
	if(czyTab($1)){s1=dodanieDoTab.back();dodanieDoTab.pop_back();}
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($3,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($5,0)));
	kodProgramu.push_back("STORE 0");
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($1,s1)));
	kodProgramu.push_back("SUBI 0");
	nrLinii+=5;}
| PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS WIEKSZY value {
	if(!czyZmiennaZainicjowana($1)||!czyZmiennaZainicjowana($3)||!czyZmiennaZainicjowana($6)){
		cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	if(!czyTab($1)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako tablica."<<endl;exit(1);}
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($1,0)))) dajNum(to_string(zwrocIndeks($1,0)));
	int s6=0;
	if(czyTab($6)){s6=dodanieDoTab.back();dodanieDoTab.pop_back();}
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($1,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($3,0)));
	kodProgramu.push_back("STORE 0");//TU SIE KONCZY ZMIANY
	kodProgramu.push_back("LOADI 0");
	kodProgramu.push_back("SUB "+to_string(zwrocIndeks($6,s6)));
	nrLinii+=5;
	}
//MNIEJSZY RÓWNY
| value MNIEJSZYROWNY value {
	if(!czyZmiennaZainicjowana($1)||!czyZmiennaZainicjowana($3)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	int s1=0,s3=0;
	if(czyTab($3)){s3=dodanieDoTab.back();dodanieDoTab.pop_back();}
	if(czyTab($1)){s1=dodanieDoTab.back();dodanieDoTab.pop_back();}
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($3,s3)));
	kodProgramu.push_back("INC");
	kodProgramu.push_back("SUB "+to_string(zwrocIndeks($1,s1)));
	nrLinii+=3;}
| PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS MNIEJSZYROWNY PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS {
	if(!czyZmiennaZainicjowana($1)||!czyZmiennaZainicjowana($3)||!czyZmiennaZainicjowana($6)||!czyZmiennaZainicjowana($8)){
		cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	if(!czyTab($1)||!czyTab($6)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako tablica."<<endl;exit(1);}
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($1,0)))) dajNum(to_string(zwrocIndeks($1,0)));
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($6,0)))) dajNum(to_string(zwrocIndeks($6,0)));
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($1,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($3,0)));
	kodProgramu.push_back("STORE 0");
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($6,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($8,0)));
	kodProgramu.push_back("STORE 1");
	kodProgramu.push_back("LOADI 1");
	kodProgramu.push_back("INC");
	kodProgramu.push_back("SUBI 0");
	nrLinii+=9;}
| value MNIEJSZYROWNY PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS {
	if(!czyZmiennaZainicjowana($1)||!czyZmiennaZainicjowana($3)||!czyZmiennaZainicjowana($5)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	if(!czyTab($3)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako tablica."<<endl;exit(1);}
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($3,0)))) dajNum(to_string(zwrocIndeks($3,0)));
	int s1=0;
	if(czyTab($1)){s1=dodanieDoTab.back();dodanieDoTab.pop_back();}
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($3,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($5,0)));
	kodProgramu.push_back("STORE 0");
	kodProgramu.push_back("LOADI 0");
	kodProgramu.push_back("INC");
	kodProgramu.push_back("SUB "+to_string(zwrocIndeks($1,s1)));
	nrLinii+=6;}
| PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS MNIEJSZYROWNY value {
	if(!czyZmiennaZainicjowana($1)||!czyZmiennaZainicjowana($3)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	if(!czyTab($1)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako tablica."<<endl;exit(1);}
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($1,0)))) dajNum(to_string(zwrocIndeks($1,0)));
	int s6=0;
	if(czyTab($6)){s6=dodanieDoTab.back();dodanieDoTab.pop_back();}
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($1,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($3,0)));
	kodProgramu.push_back("STORE 0");//TU SIE KONCZY ZMIANY
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($6,s6)));
	kodProgramu.push_back("INC");
	kodProgramu.push_back("SUBI 0");
	nrLinii+=6;}
//WIĘKSZY RÓWNY
| PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS WIEKSZYROWNY PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS {
	if(!czyZmiennaZainicjowana($1)||!czyZmiennaZainicjowana($3)||!czyZmiennaZainicjowana($6)||!czyZmiennaZainicjowana($8)){
		cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	if(!czyTab($1)||!czyTab($6)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako tablica."<<endl;exit(1);}
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($1,0)))) dajNum(to_string(zwrocIndeks($1,0)));
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($6,0)))) dajNum(to_string(zwrocIndeks($6,0)));
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($1,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($3,0)));
	kodProgramu.push_back("STORE 0");
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($6,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($8,0)));
	kodProgramu.push_back("STORE 1");
	kodProgramu.push_back("LOADI 0");
	kodProgramu.push_back("INC");
	kodProgramu.push_back("SUBI 1");
	nrLinii+=9;}
| value WIEKSZYROWNY PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS {
	if(!czyZmiennaZainicjowana($1)||!czyZmiennaZainicjowana($3)||!czyZmiennaZainicjowana($5)){
		cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	if(!czyTab($3)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako tablica."<<endl;exit(1);}
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($3,0)))) dajNum(to_string(zwrocIndeks($3,0)));
	int s1=0;
	if(czyTab($1)){s1=dodanieDoTab.back();dodanieDoTab.pop_back();}
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($3,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($5,0)));
	kodProgramu.push_back("STORE 0");
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($1,s1)));
	kodProgramu.push_back("INC");
	kodProgramu.push_back("SUBI 0");
	nrLinii+=6;}
| PIDENTIFIER LEWYNAWIAS PIDENTIFIER PRAWYNAWIAS WIEKSZYROWNY value {
	if(!czyZmiennaZainicjowana($1)||!czyZmiennaZainicjowana($3)||!czyZmiennaZainicjowana($6)){
		cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	if(!czyTab($1)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako tablica."<<endl;exit(1);}
	if(!czyZmiennaIstnieje(to_string(zwrocIndeks($1,0)))) dajNum(to_string(zwrocIndeks($1,0)));
	int s6=0;
	if(czyTab($6)){s6=dodanieDoTab.back();dodanieDoTab.pop_back();}
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks(to_string(zwrocIndeks($1,0)),0)));
	kodProgramu.push_back("ADD "+to_string(zwrocIndeks($3,0)));
	kodProgramu.push_back("STORE 0");
	kodProgramu.push_back("LOADI 0");
	kodProgramu.push_back("INC");
	kodProgramu.push_back("SUB "+to_string(zwrocIndeks($6,s6)));
	nrLinii+=6;}
| value WIEKSZYROWNY value {
	if(!czyZmiennaZainicjowana($1)||!czyZmiennaZainicjowana($3)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna niezainicjowana/niezadeklarowana."<<endl;exit(1);}
	int s1=0,s3=0;
	if(czyTab($3)){s3=dodanieDoTab.back();dodanieDoTab.pop_back();}
	if(czyTab($1)){s1=dodanieDoTab.back();dodanieDoTab.pop_back();}
	kodProgramu.push_back("LOAD "+to_string(zwrocIndeks($1,s1)));
	kodProgramu.push_back("INC");
	kodProgramu.push_back("SUB "+to_string(zwrocIndeks($3,s3)));
	nrLinii+=3;}
;

value
: NUM {	dajNum($1);
	}
| identifier {}
;

identifier
: PIDENTIFIER {
	if(czyTab($1)){cerr<<"Blad w linijce "<<yylineno<<". Tablica nie moze zostac uzyta jako zmienna."<<endl;exit(1);}
	}
| PIDENTIFIER LEWYNAWIAS NUM PRAWYNAWIAS {
	if(!czyTab($1)){cerr<<"Blad w linijce "<<yylineno<<". Zmienna nie moze zostac uzyta jako tablica."<<endl;exit(1);}
	dodanieDoTab.push_back(stoi($3));}
;

%%
void dzielenie(){
	kodProgramu.push_back("STORE 2");
	kodProgramu.push_back("ZERO");
	kodProgramu.push_back("STORE 0");
	kodProgramu.push_back("LOAD 1");
	kodProgramu.push_back("INC");
	kodProgramu.push_back("SUB 2");
	kodProgramu.push_back("JZERO "+to_string(nrLinii+15));
	kodProgramu.push_back("LOAD 2");
	kodProgramu.push_back("SHL");
	kodProgramu.push_back("STORE 2");
	kodProgramu.push_back("JUMP "+to_string(nrLinii+7));
	kodProgramu.push_back("LOAD 2");
	kodProgramu.push_back("SUB 1");
	kodProgramu.push_back("JZERO "+to_string(nrLinii+22));
	kodProgramu.push_back("LOAD 0");
	kodProgramu.push_back("SHL");
	kodProgramu.push_back("STORE 0");
	kodProgramu.push_back("JUMP "+to_string(nrLinii+29));
	kodProgramu.push_back("LOAD 1");
	kodProgramu.push_back("SUB 2");
	kodProgramu.push_back("STORE 1");
	kodProgramu.push_back("LOAD 0");
	kodProgramu.push_back("SHL");
	kodProgramu.push_back("INC");
	kodProgramu.push_back("STORE 0");
	kodProgramu.push_back("LOAD 2");
	kodProgramu.push_back("SHR");
	kodProgramu.push_back("STORE 2");
}
void modulo(){
	kodProgramu.push_back("STORE 2");
	kodProgramu.push_back("LOAD 1");
	kodProgramu.push_back("INC");
	kodProgramu.push_back("SUB 2");
	kodProgramu.push_back("JZERO "+to_string(nrLinii+13));
	kodProgramu.push_back("LOAD 2");
	kodProgramu.push_back("SHL");
	kodProgramu.push_back("STORE 2");
	kodProgramu.push_back("JUMP "+to_string(nrLinii+5));
	kodProgramu.push_back("LOAD 2");
	kodProgramu.push_back("SUB 1");
	kodProgramu.push_back("JZERO "+to_string(nrLinii+17));
	kodProgramu.push_back("JUMP "+to_string(nrLinii+20));
	kodProgramu.push_back("LOAD 1");
	kodProgramu.push_back("SUB 2");
	kodProgramu.push_back("STORE 1");
	kodProgramu.push_back("LOAD 2");
	kodProgramu.push_back("SHR");
	kodProgramu.push_back("STORE 2");
}
void mnozenie(){
	kodProgramu.push_back("STORE 2");
	kodProgramu.push_back("ZERO");
	kodProgramu.push_back("STORE 0");
	kodProgramu.push_back("LOAD 2");
	kodProgramu.push_back("INC");
	kodProgramu.push_back("JODD "+to_string(nrLinii+20));
	kodProgramu.push_back("LOAD 0");
	kodProgramu.push_back("ADD 1");
	kodProgramu.push_back("STORE 0");
	kodProgramu.push_back("LOAD 2");
	kodProgramu.push_back("SHR");
	kodProgramu.push_back("JZERO "+to_string(nrLinii+28));
	kodProgramu.push_back("STORE 2");
	kodProgramu.push_back("LOAD 1");
	kodProgramu.push_back("SHL");
	kodProgramu.push_back("STORE 1");
	kodProgramu.push_back("JUMP "+to_string(nrLinii+14));
	kodProgramu.push_back("LOAD 0");
}
void dajNum(string nazwa){//wygenerowana wartosc zostaje w rejestrze
	if(czyZmiennaIstnieje(nazwa)){
		string wynik, zero="0";
		kodProgramu.push_back("ZERO");
		nrLinii++;
		wynik=dajBin(nazwa);
		for( int i = 0; i < wynik.length()-1; i++ ){
			if(wynik[i]=='1'){ kodProgramu.push_back("INC"); nrLinii++;}
			kodProgramu.push_back("SHL");
			nrLinii++;
		}
		if(wynik[wynik.length()-1]=='1'){ kodProgramu.push_back("INC"); nrLinii++;}
		kodProgramu.push_back("STORE "+to_string(zwrocIndeks(nazwa,0)));
		nrLinii++;	
	}
	else{
		string wynik, zero="0";
		kodProgramu.push_back("ZERO");
		nrLinii++;
		wynik=dajBin(nazwa);
		for( int i = 0; i < wynik.length()-1; i++ ){
			if(wynik[i]=='1'){ kodProgramu.push_back("INC"); nrLinii++;}
			kodProgramu.push_back("SHL");
			nrLinii++;
		}
		if(wynik[wynik.length()-1]=='1'){ kodProgramu.push_back("INC"); nrLinii++;}
		Zmienna zmienna;
		zmienna.nazwaZmiennej=nazwa;
		zmienna.nrKomorkiWPamieci=nrWolnejKomorkiWPamieci;
		zmienna.dlugoscTablicy=1;
		zmienna.isPartOfArray=false;
		zmienna.isIterator=false;
		zmienna.czyZainicjowana=true;
		nrWolnejKomorkiWPamieci++;
		tablicaZmiennych.push_back(zmienna);
		kodProgramu.push_back("STORE "+to_string(zwrocIndeks(nazwa,0)));
		nrLinii++;	
	}
}
int zwrocIndeks(string nazwaZmiennejT, int dod){
	for( int i = 0; i < tablicaZmiennych.size(); i++ ){
		if(tablicaZmiennych[i].nazwaZmiennej == nazwaZmiennejT){
			if(tablicaZmiennych[i].isPartOfArray==true) return tablicaZmiennych[i].nrKomorkiWPamieci+dod;
			else return tablicaZmiennych[i].nrKomorkiWPamieci;
		} 
	}
	cerr<<"Błąd w linijce "<<yylineno<<". Zmienna niezadeklarowana."<<endl;
	exit(1);
	return 0;
}
bool czyZmiennaIstnieje(string nazwaZmiennejT){
	for( int i = 0; i < tablicaZmiennych.size(); i++ ){
		if(tablicaZmiennych[i].nazwaZmiennej == nazwaZmiennejT) return true;
	}
	return false;
}
bool czyTab(string nazwaZmiennejT){
	for( int i = 0; i < tablicaZmiennych.size(); i++ ){
		if(tablicaZmiennych[i].nazwaZmiennej == nazwaZmiennejT) return tablicaZmiennych[i].isPartOfArray;
	}
	cerr<<"Błąd w linijce "<<yylineno<<". Zmienna niezadeklarowana."<<endl;
	exit(1);
	return false;
}
string dajBin(string liczba){
	unsigned long long licz = stoi(liczba);
	string wynik="";
	string zero="0";
	string jeden="1";
	if(licz==0) return zero;
	while(licz>0){
		if(licz%2==0) wynik=zero+wynik;
		else wynik=jeden+wynik;
		licz /=2;
	}
	return wynik;
}
void usunIterator(string nazwaIteratora){
	int indeks;
	for( int i = 0; i < tablicaZmiennych.size(); i++ ){
		if(tablicaZmiennych[i].nazwaZmiennej == nazwaIteratora) indeks=i;
	}
	tablicaZmiennych.erase(tablicaZmiennych.begin() + indeks);
}
bool czyIterator(string nazwaIteratora){
	for( int i = 0; i < tablicaZmiennych.size(); i++ ){
		if(tablicaZmiennych[i].nazwaZmiennej == nazwaIteratora) return tablicaZmiennych[i].isIterator;
	}
	//cerr<<"Błąd w linijce "<<yylineno<<". Zmienna niezadeklarowana."<<endl;
	//exit(1);
	return false;
}
bool czyZmiennaZainicjowana(string nazwaZmiennejT){
	for( int i = 0; i < tablicaZmiennych.size(); i++ ){
		if(tablicaZmiennych[i].nazwaZmiennej == nazwaZmiennejT) return tablicaZmiennych[i].czyZainicjowana;
	}
	return false;
	//cerr<<"Błąd w linijce "<<yylineno<<". Zmienna niezadeklarowana."<<endl;
	//exit(1);
}
void zainicjuj(string nazwaZmiennejT){
	for( int i = 0; i < tablicaZmiennych.size(); i++ ){
		if(tablicaZmiennych[i].nazwaZmiennej == nazwaZmiennejT) tablicaZmiennych[i].czyZainicjowana=true;
	}
}
void yyerror(char *s){
	cerr<<"Blad w linijce "<<yylineno<<". Blad leksykalny lub skladniowy."<<endl;
	exit(1);
}
int main(void){
	fstream plik;
	yyparse();
	for( int i = 0; i < skokDoPrzoduEdycja.size(); i++ ){
		kodProgramu[skokDoPrzoduEdycja[i].nrLinijkiDoEdycji] = skokDoPrzoduEdycja[i].tekstLinijki;
	}
	plik.open( "program.txt", std::ios::out );
	if( plik.good() == true ){
		for( int i = 0; i < kodProgramu.size(); i++ ) plik<<kodProgramu[i]<<endl;
		plik.close();
	}
	cout<<"Kompilacja zakonczona sukcesem"<<endl;
	return 0;
}

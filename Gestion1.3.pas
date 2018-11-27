Program ejb;
Uses crt;

const
  M=20;
  centinelaMat='ZZZZZ';

type
   str3=string[3];
   str5=string[5];
   str20=string[20];

     TramVec=Record
	   codTramite:str3;
	   estado:byte;
	 end;

   tramiteAlum=Record
     matricula:str5;
     totalAbiertos:word;
     totalCerrados:word;
     UltC:str3;
     UltE:byte;
     end;

    TVT=array[1..M] of TramVec;

    alumno=Record
     matricula:str5;
     nomyAp:str20;
     tramitesA:TVT;
     N:byte;
     end;

   tramite=Record
     codTramite:str3;
     desc:str20;
     end;

   tramiteCons=Record
     matricula:str5;
     codTramite:str3;
     estado:byte;
     end;




   TVL=array[1..M] of word;
   //TVA=array[1..M] of word;
   TVTabla=array[1..M] of tramite;

   TarchAlum=file of alumno;
   TarchTram= file of tramite;
   TarchTramCons= file of tramiteCons;
   TarchTramAlum= file of tramiteAlum;



{Procedimiento Cargar Tabla Tramites}
Procedure cargarTabla(var Tabla:TVTabla;Var M:byte;var archTram:TarchTram);
var
T:tramite;
Begin
M:=0;
reset(archTram);
Read(archTram,T);
While not eof(archTram) do
  Begin
  M:=M+1;
  Tabla[M]:=T;
  Read(archTram,T);
  end;
end;


 procedure insertaEnVector(var alum:alumno;codTramite:str3);
 var
 i:byte;
 begin
      alum.N:=alum.N+1;
       i:=alum.N;
      alum.tramitesA[i].codTramite:=codTramite;
      alum.tramitesA[i].estado:=0;
 end;

procedure EliminaVector(var alum:alumno;j:byte);
begin
alum.tramitesA[j]:=Alum.tramitesA[alum.N];
alum.N:=Alum.N-1;
end;

Procedure IniciaVector(Var TotalCod:TVL;M:byte);
Var
i:byte;
Begin
For i:=1 to M do
TotalCod[i]:=0;
end;

Function BuscaCodigoEnVectorAlumnos(alum:alumno;Codigo:str3):byte;
var
i:byte;
Begin
i:=1;
while (i<=Alum.N) and (codigo<>Alum.tramitesA[i].codtramite) do
i:=i+1;
If Codigo=Alum.tramitesA[i].codtramite then
BuscaCodigoEnVectorAlumnos:=i else
BuscaCodigoEnVectorAlumnos:=0;
end;

Procedure MostrarTabla(tabla:TVtabla;M:byte;totalcod:TVL);
Var
i:byte;
Begin
For i:=1 to M do
Writeln(Tabla[i].Codtramite,'  ',Tabla[i].desc,'  ',totalcod[i]);
end;

Function Busco(Tabla:TVtabla;M:byte;Codigo:str3):byte;
var
i:byte;
Begin
i:=1;
while (i<=M) and (Tabla[i].codtramite<>Codigo) do
i:=i+1;
if tabla[i].codtramite=codigo then
Busco:=i else
Busco:=0;
end;


procedure Gestion(centinelaMat:str5;var archAlum:TarchAlum;var archTram:TarchTram;
var archTramCons:TarchTramCons;var archTramAlum:TarchTramAlum);

var
  archtemp:TarchAlum;
  tramCons:tramiteCons;
  tramAlum:tramiteAlum;
  alum:alumno;
  tram:tramite;
  cantAbiertos,cantCerrados,totalTramites,CantAlumnos,TramitesErroneos,AlumSinConsulta:word;
  Raux:tramitecons;
  j,M:byte;
  TotalCod:TVL;
  tabla:TVTabla;
begin
  cantAbiertos:=0;  cantCerrados:=0;   totalTramites:=0;
   cantAlumnos:=0;    TramitesErroneos:=0; AlumSinConsulta:=0;
  assign(ArchTemp,'archtemp.dat');
  reset(archAlum);
  reset(archTram);
  reset(archTramCons);
  rewrite(ArchtramAlum);   rewrite(archTemp);
  cargarTabla(tabla,M,archTram);
  IniciaVector(TotalCod,M);
  read(archTramCons,tramCons); read(archAlum,alum);
  while not eof(archAlum) or not eof(archtramCons)  do
  begin
    if tramCons.matricula < alum.matricula then     {matricula incorrecta}
    begin
    TramitesErroneos:=TramitesErroneos+1;
    read(archTramCons,tramCons);
    end
    else
      if tramCons.matricula > alum.matricula then
      begin
       writeln('Alumno sin consultas: ',alum.nomyAp);
        AlumSinConsulta:=AlumSinConsulta+1;
        write(archTemp,alum);
        cantAlumnos:=cantAlumnos+1;
        read(archAlum,alum);
      end
      else
      begin
      TramAlum.TotalCerrados:=0;
        with alum do
        begin
          if (tramCons.matricula<>centinelaMat) then
          begin
            while (tramCons.matricula=alum.matricula)  do
            begin
            j:=busco(tabla,m,tramcons.codtramite);
           If j<>0 then
           totalcod[j]:=totalcod[j]+1;
            totalTramites:=totalTramites+1;
            // ACA VA PUNTO B
            //  insertaEnListado(totalCod,tramites,M,tramCons.desc);//HACER //inserta la cantidad en el listado
	      j:=BuscaCodigoEnVectorAlumnos(alum,tramCons.codTramite);
              if tramCons.estado=1 then
                Begin
                  cantCerrados:=cantCerrados+1;
                  TramAlum.TotalCerrados:=TramAlum.TotalCerrados+1;
                 If (j<>0) then
                  eliminaVector(alum,j);
	        end
                else
                    if (tramCons.estado=0) then
		    begin
                     cantAbiertos:=cantAbiertos+1;
                     if j=0 then
		     insertaEnVector(alum,tramCons.codTramite);
		    end;
              Raux:=tramCons; // REGISTRO AUXILIAR PUNTO B
              read(archTramCons,tramCons);
            end;
            TramAlum.Matricula:=Raux.matricula;
            Tramalum.TotalAbiertos:=Alum.N;
            TramAlum.UltC:=Raux.codtramite;
            TramAlum.UltE:=Raux.estado;
            Write(archtramalum,TramAlum);
            write(archTemp,alum);
            cantAlumnos:=cantAlumnos+1;
          read(archAlum,alum);
          end;

        end;
      end;
  end;
  write(archTemp,alum); // escribe centinela
  close(archAlum);
  close(archTram);
  close(archTramCons);
  close(archTramAlum);
 { erase(archAlum);
  rename(ArchTemp,'ALUMNOS.dat');}

{ reset(archtramAlum);
  while not eof(archtramalum) do
  Begin
  read(archtramalum,tramalum);
  with tramalum do
  Begin
  write('Matricula ',Matricula);
  write(' A',totalabiertos);
  write(' C ',TotalCerrados);
  writeln('cod',ultC,' estado ',UltE);
  end;
  end;
  MostrarTabla(tabla,m,totalcod);
  ordenaVector(tabla,totalCod,M); //HACER
  imprimeListado(tabla,totalCod,M);//punto C  }
  writeln('Promedio de tramites por alumno ',totalTramites/cantAlumnos:8:2);
  writeln('total de tramites registrados ',totalTramites);
  if totalTramites > 0 then
  begin
    writeln((cantAbiertos/totalTramites)*100:4:2, '% de tramites ABIERTOS');
    writeln((cantCerrados/totalTramites)*100:4:2, '% de tramites CERRADOS');
  end;
  Writeln('Cantidad de Tramites Erroneos ',TramitesErroneos);
end;


var
  archAlum:TarchAlum;
  archTramCons:TarchTramCons;
  archTramAlum:TarchTramAlum;
  archTram:TarchTram;
BEGIN
  clrscr;
  assign(archAlum,'C:\FPC\2.6.4\bin\i386-win32\ALUMNOS.dat');
  assign(archTram,'C:\FPC\2.6.4\bin\i386-win32\TRAMITES.dat');
  assign(archTramCons,'C:\FPC\2.6.4\bin\i386-win32\TRAMITES_CONSULTA.dat');
  assign(archTramAlum,'C:\FPC\2.6.4\bin\i386-win32\TRAMITES_DE_ALUMNOS.dat');
  Gestion(centinelaMat,archAlum,ArchTram,ArchTramCons,ArchTramAlum);
  readln;
END.



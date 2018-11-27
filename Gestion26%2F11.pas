Program ejb;
Uses crt;

const
  M=20;

type
   str3=string[3];
   str5=string[5];
   str20=string[20];


   tramiteAlum=Record
     matricula:str5;
     totalAbiertos:word;
     totalCerrados:word;
     codTramite:str3;
     estado:byte;
     end;

    TramVec=Record
      codTramite:str3;
      estado:byte;
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


procedure insertaEnVector(var tramitesA:TVT;var N:byte;codTramite:str3);
 var
 i:byte;
 begin
       N:=N+1;
       i:=N;
       tramitesA[i].codTramite:=codTramite;
	   tramitesA[i].estado:=0;
 end;

Procedure iniciaVector(Var TotalCod:TVL;M:byte);
Var
  i:byte;

Begin
  For i:=1 to M do
  TotalCod[i]:=0;
end;

Function BuscaCodigoEnVectorAlumnos(tramitesA:TVT;N:byte;codigo:str3):byte;
var
i:byte;
Begin
  i:=1;
  while (i<=N) and (codigo<>tramitesA[i].codtramite) do
    i:=i+1;

  If codigo=tramitesA[i].codtramite then
    BuscaCodigoEnVectorAlumnos:=i
  else
    BuscaCodigoEnVectorAlumnos:=0;
end;


procedure Gestion(var archAlum:TarchAlum;var archTram:TarchTram;
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
  iniciaVector(TotalCod,M);
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
        AlumSinConsulta:=AlumSinConsulta+1;
        write(archTemp,alum);
        read(archAlum,alum);
      end
      else
      begin
        with alum do
        begin
            while (tramCons.matricula=alum.matricula)  do
            begin
            //ACA VA PUNTO B
              insertaEnListado(totalCod,tabla,M,tramCons.codTramite); //inserta la cantidad en el listado
              totalTramites:=totalTramites+1;  // contando todos los tramites
	      j:=BuscaCodigoEnVectorAlumnos(tramitesA,N,tramCons.codTramite);
              if (tramCons.estado=1) then
              begin
                 if  (j<>0) then    // si esta y esta cerrado
	           eliminaDeVector(tramitesA,N,j); //elimina del vector el contenido de pos j
	        cantCerrados:=cantCerrados+1; // cuenta solo cerrados
	      end
              else
	        if tramCons.estado <> 0 then
		begin
		  if j<>0 then
		    insertaEnVector(tramitesA,N,tramCons.codTramite); //inserta nuevo si no se encuentra

		  cantAbiertos:=cantAbiertos+1;  // cuenta solo abiertos
		end;
              Raux:=tramCons; // REGISTRO AUXILIAR PUNTO B
              read(archTramCons,tramCons);
            end;
          //escribo en archivo punto B
            write(archTemp,alum);
            cantAlumnos:=cantAlumnos+1; // cuenta cantidad de alumnos
            read(archAlum,alum);
        end;
      end;
  end;
  write(archTemp,alum); // escribe centinela
  close(archAlum);
  close(archTram);
  close(archTramCons);
  close(archTramAlum);
  {erase(archAlum);
  rename(ArchTemp,'ALUMNOS.dat');
  ordenaVector(totalCod,N); // PREGUNTAR
  imprimeListado(tabla,totalCod,M);//punto C  }
  writeln('Promedio de tramites por alumno ',totalTramites/cantAlumnos:8:2);
  writeln('total de tramites registrados ',totalTramites);
  if totalTramites > 0 then
  begin
    writeln((cantAbiertos/totalTramites)*100:4:2, '% de tramites ABIERTOS');
    writeln((cantCerrados/totalTramites)*100:4:2, '% de tramites CERRADOS');
  end;
end;

procedure insertaEnListado(var totalCod:TVL,tabla:TVTabla,M:byte,cod:str3);
var
  i:byte;
begin
  i:=1;
  while (i<=M) and (tramites[i].codTramite <> cod) do
    i:=i+1;
   if (tramites[i].codTramite = cod) then
     totalCod[i]:= totalCod[i] +1;
end;


procedure eliminaDeVector(var tramitesA:TVT;var N:byte;pos:byte);
var
  i:byte;
begin
 N:=N-1;
 for i:pos to N do
  tramitesA[i]:=tramitesA[i+1];
end;




procedure ordenaVector(var tabla:TVTabla;var totalCod:TVL;M:byte);
var
  aux1:word;
  aux2:tramite;
  i,j:byte;
begin
  for i:=2 to N do
  begin
    j:=i-1;
    aux1:=totalCod[i];
    aux2:=tabla[i];
    while (j>0) and (aux > totalCod[j]) do
    begin
      totalCod[j+1]:= totalCod[j];
      tabla[j+1]:=tabla[j];
      j:=j-1;
    end;
    totalCod[j+1]:=aux1;
    tabla[i]:=aux2;
  end;
end;

procedure imprimeListado(tramites:TVTabla,totalCod:TVL,N:byte);
var i:byte;
begin
  writeln('Cod. de Tramite      Descripcion     Total');
  for i:=1 to N do
    writeln(tramites[i].codTramite,'    ',tramites[i].desc,'    ',totalCod[i]);
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


